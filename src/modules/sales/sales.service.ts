import {Injectable, BadRequestException} from '@nestjs/common';
import {randomBytes} from 'crypto';
import {PrismaService} from '../../common/prisma/prisma.service';
import {ShortListService} from '../shortlist/shortlist.service';
import {CashBoxService} from '../cash-box/cash-box.service';

@Injectable()
export class SalesService {
  constructor(
    private prisma: PrismaService,
    private shortListService: ShortListService,
    private cashBoxService: CashBoxService
  ) {}

  async create(tenantId: string, employeeId: string, data: any) {
    const {items, ...saleData} = data;

    // Validate CREDIT sales basic fields
    if (saleData.paymentMethod === 'CREDIT') {
      if (!saleData.customerName?.trim() || !saleData.customerPhone?.trim()) {
        throw new BadRequestException(
          'Customer name and phone are required for credit sales'
        );
      }
      const paid = saleData.amountPaid ?? 0;
      if (paid < 0)
        throw new BadRequestException('amountPaid cannot be negative');
    }

    // Calculate total
    let totalAmount = 0;
    let totalProfit = 0;

    for (const item of items) {
      // Defence-in-depth: use findFirst with tenantId to avoid cross-tenant access
      // even if the manual tenantId check below were ever removed.
      const inventory = await this.prisma.inventoryItem.findFirst({
        where: {id: item.inventoryId, tenantId},
      });

      if (!inventory) {
        throw new BadRequestException('Invalid inventory item');
      }

      if (inventory.quantity < item.quantity) {
        throw new BadRequestException('Insufficient stock');
      }

      // Validate unit price matches inventory retail price
      if (Math.abs(item.unitPrice - inventory.retailPrice) > 0.01) {
        throw new BadRequestException(
          'Unit price does not match inventory retail price'
        );
      }

      const discountPercent = item.discount || 0;
      if (discountPercent < 0 || discountPercent > 100) {
        throw new BadRequestException('Discount must be between 0 and 100%');
      }

      // Check against inventory max discount rate
      if (
        inventory.maxDiscountRate &&
        discountPercent > inventory.maxDiscountRate
      ) {
        throw new BadRequestException(
          `Discount exceeds maximum allowed for this item (${inventory.maxDiscountRate}%)`
        );
      }

      if (!inventory.purchasePrice || inventory.purchasePrice <= 0) {
        throw new BadRequestException(
          'Invalid purchase price for inventory item'
        );
      }

      const effectivePrice = item.unitPrice * (1 - discountPercent / 100);
      const profit = effectivePrice - inventory.purchasePrice;
      const minProfit = 0.04 * inventory.purchasePrice;
      if (profit < minProfit) {
        throw new BadRequestException(
          'Discount exceeds allowed limit (must maintain at least 4% profit on purchase price)'
        );
      }

      totalAmount += effectivePrice * item.quantity;
      totalProfit += profit * item.quantity;
    }

    // Apply overall discount if any
    if (saleData.discountType === 'percentage') {
      totalAmount -= (totalAmount * saleData.discountValue) / 100;
    } else if (saleData.discountType === 'fixed') {
      totalAmount -= saleData.discountValue;
    }

    // Validate amountPaid does not exceed totalAmount (MINOR 10)
    if (saleData.paymentMethod === 'CREDIT') {
      const paid = saleData.amountPaid ?? 0;
      if (paid > totalAmount) {
        throw new BadRequestException('amountPaid cannot exceed totalAmount');
      }
    }

    // Create sale with items
    const sale = await this.prisma.sale.create({
      data: {
        ...saleData,
        tenantId,
        employeeId,
        totalAmount,
        totalProfit,
        receiptNumber: `${Date.now()}`,
        amountPaid:
          saleData.paymentMethod === 'CREDIT' ? saleData.amountPaid ?? 0 : null,
        dueAmount:
          saleData.paymentMethod === 'CREDIT'
            ? Math.max(0, totalAmount - (saleData.amountPaid ?? 0))
            : null,
        items: {
          create: items.map((item: any) => ({
            inventoryId: item.inventoryId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            discount: item.discount || 0, // percentage
            subtotal:
              item.unitPrice * (1 - (item.discount || 0) / 100) * item.quantity,
          })),
        },
      },
      include: {
        items: {
          include: {
            inventory: true,
          },
        },
      },
    });

    // Update inventory quantities
    for (const item of items) {
      await this.prisma.inventoryItem.update({
        where: {id: item.inventoryId},
        data: {
          quantity: {
            decrement: item.quantity,
          },
        },
      });

      // Update last moved date and trigger short list check
      await this.shortListService.updateLastMoved(item.inventoryId);
      await this.shortListService.autoCheckAndAdd(item.inventoryId, tenantId);
    }

    // Auto-create a cash box SALE_IN entry for all payment methods
    const cashReceivedNow =
      saleData.paymentMethod === 'CREDIT'
        ? saleData.amountPaid ?? 0
        : sale.totalAmount;

    if (cashReceivedNow > 0) {
      try {
        await this.cashBoxService.createEntry(tenantId, employeeId, {
          entryType: 'SALE_IN' as any,
          amount: cashReceivedNow,
          note: `Sale #${sale.receiptNumber} — ${
            saleData.paymentMethod ?? 'CASH'
          }`,
          referenceId: sale.id,
          entryDate: sale.saleTime,
        });
      } catch (err: any) {
        console.error(
          '[CashBox] Failed to create SALE_IN entry:',
          err?.message
        );
      }
    }

    return sale;
  }

  async findAll(tenantId: string) {
    return this.prisma.sale.findMany({
      where: {tenantId},
      include: {
        employee: {
          select: {id: true, fullName: true},
        },
      },
      orderBy: {saleTime: 'desc'},
    });
  }

  async findOne(id: string, tenantId: string) {
    return this.prisma.sale.findFirst({
      where: {id, tenantId},
      include: {
        items: {
          include: {
            inventory: {
              include: {
                variant: {
                  include: {
                    product: true,
                  },
                },
              },
            },
          },
        },
        employee: {
          select: {id: true, fullName: true},
        },
      },
    });
  }

  async getTodaySummary(tenantId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const sales = await this.prisma.sale.findMany({
      where: {
        tenantId,
        saleTime: {gte: today},
      },
    });

    const totalSales = sales.length;
    const totalRevenue = sales.reduce((sum, sale) => sum + sale.totalAmount, 0);
    const totalProfit = sales.reduce((sum, sale) => sum + sale.totalProfit, 0);

    return {
      totalSales,
      totalRevenue,
      totalProfit,
      averageOrderValue: totalSales > 0 ? totalRevenue / totalSales : 0,
    };
  }

  async getOverallStatistics(tenantId: string, startDate?: Date) {
    const where: any = {tenantId};
    if (startDate) {
      where.saleTime = {gte: startDate};
    }

    const result = await this.prisma.sale.aggregate({
      where,
      _count: true,
      _sum: {totalAmount: true, totalProfit: true},
    });

    return {
      ordersCount: result._count,
      totalRevenue: result._sum.totalAmount ?? 0,
      totalProfit: result._sum.totalProfit ?? 0,
    };
  }

  async getAssetValue(tenantId: string) {
    const items = await this.prisma.inventoryItem.findMany({
      where: {tenantId},
      select: {quantity: true, purchasePrice: true, retailPrice: true},
    });

    const totalAssetValue = items.reduce(
      (sum, item) => sum + item.quantity * item.purchasePrice,
      0
    );
    const totalInventorySellingValue = items.reduce(
      (sum, item) => sum + item.quantity * item.retailPrice,
      0
    );

    // totalAssetValue kept for back-compat; it is current stock at purchase price
    return {totalAssetValue, totalInventorySellingValue};
  }

  async getGraphData(tenantId: string, period: string = '30d') {
    const days = period === '7d' ? 7 : period === '90d' ? 90 : 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const sales = await this.prisma.sale.findMany({
      where: {
        tenantId,
        saleTime: {gte: startDate},
      },
      orderBy: {saleTime: 'asc'},
    });

    // Initialize map with all dates in range
    const grouped = new Map<
      string,
      {date: string; sales: number; profit: number}
    >();
    for (let i = 0; i < days; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      grouped.set(dateStr, {date: dateStr, sales: 0, profit: 0});
    }

    // Aggregate sales
    sales.forEach((sale) => {
      const dateStr = sale.saleTime.toISOString().split('T')[0];
      if (grouped.has(dateStr)) {
        const curr = grouped.get(dateStr)!;
        curr.sales += sale.totalAmount;
        curr.profit += sale.totalProfit;
      }
    });

    // Convert to array and sort by date
    return Array.from(grouped.values()).sort((a, b) =>
      a.date.localeCompare(b.date)
    );
  }
}
