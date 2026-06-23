import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CashBoxService } from '../cash-box/cash-box.service';
import { CreateCreditPaymentDto } from './dto/credits.dto';

@Injectable()
export class CreditsService {
  constructor(
    private prisma: PrismaService,
    private cashBoxService: CashBoxService,
  ) {}

  async getCreditCustomers(tenantId: string) {
    const creditSales = await this.prisma.sale.findMany({
      where: { tenantId, paymentMethod: 'CREDIT' as any, dueAmount: { gt: 0 } },
      include: { creditPayments: true },
      orderBy: { saleTime: 'asc' },
    });

    const customerMap = new Map<string, any>();
    for (const sale of creditSales) {
      const key = sale.customerPhone || 'unknown';
      if (!customerMap.has(key)) {
        customerMap.set(key, {
          customerName: sale.customerName,
          customerPhone: sale.customerPhone,
          totalDue: 0,
          salesCount: 0,
          oldestDueDate: sale.saleTime,
          lastPaymentDate: null as Date | null,
        });
      }
      const customer = customerMap.get(key);
      customer.totalDue += sale.dueAmount ?? 0;
      customer.salesCount += 1;
      if (sale.saleTime < customer.oldestDueDate) {
        customer.oldestDueDate = sale.saleTime;
      }
      const sorted = (sale.creditPayments ?? []).sort(
        (a: any, b: any) =>
          new Date(b.paymentDate).getTime() - new Date(a.paymentDate).getTime(),
      );
      const last = sorted[0];
      if (last && (!customer.lastPaymentDate || last.paymentDate > customer.lastPaymentDate)) {
        customer.lastPaymentDate = last.paymentDate;
      }
    }

    return Array.from(customerMap.values()).sort((a, b) => b.totalDue - a.totalDue);
  }

  async getCreditsByPhone(tenantId: string, phone: string) {
    return this.prisma.sale.findMany({
      where: { tenantId, customerPhone: phone, paymentMethod: 'CREDIT' as any },
      include: {
        creditPayments: { orderBy: { paymentDate: 'desc' } },
        items: { include: { inventory: true } },
      },
      orderBy: { saleTime: 'desc' },
    });
  }

  async recordPayment(
    tenantId: string,
    userId: string,
    saleId: string,
    dto: CreateCreditPaymentDto,
  ) {
    const sale = await this.prisma.sale.findFirst({
      where: { id: saleId, tenantId, paymentMethod: 'CREDIT' as any },
    });

    if (!sale) throw new NotFoundException('Credit sale not found');
    if ((sale.dueAmount ?? 0) <= 0)
      throw new BadRequestException('No outstanding due on this sale');
    if (dto.amount > (sale.dueAmount ?? 0))
      throw new BadRequestException('Payment exceeds outstanding due');

    const payment = await this.prisma.creditPayment.create({
      data: {
        tenantId,
        saleId,
        amount: dto.amount,
        note: dto.note,
        createdById: userId,
      },
    });

    await this.prisma.sale.update({
      where: { id: saleId },
      data: {
        dueAmount: Math.max(0, (sale.dueAmount ?? 0) - dto.amount),
        amountPaid: (sale.amountPaid ?? 0) + dto.amount,
      },
    });

    try {
      await this.cashBoxService.createEntry(tenantId, userId, {
        entryType: 'SALE_IN' as any,
        amount: dto.amount,
        note: `Credit payment — ${sale.customerName} (${sale.customerPhone})`,
        referenceId: payment.id,
      });
    } catch (err: any) {
      console.error('[CashBox] Failed to create credit payment SALE_IN:', err?.message);
    }

    return payment;
  }

  async getCreditSummary(tenantId: string) {
    const result = await this.prisma.sale.aggregate({
      where: { tenantId, paymentMethod: 'CREDIT' as any, dueAmount: { gt: 0 } },
      _sum: { dueAmount: true },
      _count: true,
    });
    return {
      totalOutstanding: result._sum.dueAmount ?? 0,
      customersWithDues: result._count,
    };
  }
}
