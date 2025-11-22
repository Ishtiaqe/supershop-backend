import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class SalesService {
  constructor(private prisma: PrismaService) { }

  async create(tenantId: string, employeeId: string, data: any) {
    const { items, ...saleData } = data;

    // Calculate total
    let totalAmount = 0;
    let totalProfit = 0;

    for (const item of items) {
      const inventory = await this.prisma.inventoryItem.findUnique({
        where: { id: item.inventoryId },
      });

      if (!inventory || inventory.tenantId !== tenantId) {
        throw new BadRequestException('Invalid inventory item');
      }

      if (inventory.quantity < item.quantity) {
        throw new BadRequestException('Insufficient stock');
      }

      const discountPercent = item.discount || 0;
      if (discountPercent < 0 || discountPercent > 100) {
        throw new BadRequestException('Discount must be between 0 and 100%');
      }

      const effectivePrice = item.unitPrice * (1 - discountPercent / 100);
      const profit = effectivePrice - inventory.purchasePrice;
      const minProfit = 0.04 * inventory.purchasePrice;
      if (profit < minProfit) {
        throw new BadRequestException('Discount exceeds allowed limit (must maintain at least 4% profit on purchase price)');
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

    // Create sale with items
    const sale = await this.prisma.sale.create({
      data: {
        ...saleData,
        tenantId,
        employeeId,
        totalAmount,
        totalProfit,
        receiptNumber: `RCP-${Date.now()}`,
        items: {
          create: items.map((item: any) => ({
            inventoryId: item.inventoryId,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            discount: item.discount || 0, // percentage
            subtotal: (item.unitPrice * (1 - (item.discount || 0) / 100)) * item.quantity,
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
        where: { id: item.inventoryId },
        data: {
          quantity: {
            decrement: item.quantity,
          },
        },
      });
    }

    return sale;
  }

  async findAll(tenantId: string) {
    return this.prisma.sale.findMany({
      where: { tenantId },
      include: {
        employee: {
          select: { id: true, fullName: true },
        },
      },
      orderBy: { saleTime: 'desc' },
    });
  }

  async findOne(id: string, tenantId: string) {
    return this.prisma.sale.findFirst({
      where: { id, tenantId },
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
          select: { id: true, fullName: true },
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
        saleTime: { gte: today },
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

  async getOverallStatistics(tenantId: string) {
    const sales = await this.prisma.sale.findMany({
      where: { tenantId },
    });

    const ordersCount = sales.length;
    const totalRevenue = sales.reduce((sum, sale) => sum + sale.totalAmount, 0);
    const totalProfit = sales.reduce((sum, sale) => sum + sale.totalProfit, 0);

    return {
      ordersCount,
      totalRevenue,
      totalProfit,
    };
  }

  async getAssetValue(tenantId: string) {
    const items = await this.prisma.inventoryItem.findMany({
      where: { tenantId },
      select: { quantity: true, purchasePrice: true },
    });

    const totalAssetValue = items.reduce(
      (sum, item) => sum + item.quantity * item.purchasePrice,
      0,
    );

    return { totalAssetValue };
  }

  async getGraphData(tenantId: string, period: string = '30d') {
    const days = period === '7d' ? 7 : period === '90d' ? 90 : 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
    startDate.setHours(0, 0, 0, 0);

    const sales = await this.prisma.sale.findMany({
      where: {
        tenantId,
        saleTime: { gte: startDate },
      },
      orderBy: { saleTime: 'asc' },
    });

    // Initialize map with all dates in range
    const grouped = new Map<string, { date: string; sales: number; profit: number }>();
    for (let i = 0; i < days; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      grouped.set(dateStr, { date: dateStr, sales: 0, profit: 0 });
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
      a.date.localeCompare(b.date),
    );
  }
}
