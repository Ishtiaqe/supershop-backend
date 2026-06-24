import {Injectable} from '@nestjs/common';
import {CashBoxEntryType, Prisma} from '@prisma/client';
import {CreateCashBoxEntryDto} from './dto/create-cash-box-entry.dto';
import {GetCashBoxEntriesDto} from './dto/get-cash-box-entries.dto';
import {PrismaService} from '../../common/prisma/prisma.service';

@Injectable()
export class CashBoxService {
  constructor(private prisma: PrismaService) {}

  /** Create an entry — called manually or automatically from Sales/Expenses */
  async createEntry(
    tenantId: string,
    createdById: string,
    data: {
      entryType: CashBoxEntryType;
      amount: number;
      note?: string;
      referenceId?: string;
      entryDate?: Date;
    }
  ) {
    return this.prisma.cashBoxEntry.create({
      data: {
        tenantId,
        createdById,
        entryType: data.entryType,
        amount: data.amount,
        note: data.note,
        referenceId: data.referenceId,
        entryDate: data.entryDate ?? new Date(),
      },
    });
  }

  /** Create a manual IN/OUT entry from the API */
  async createManualEntry(
    tenantId: string,
    userId: string,
    dto: CreateCashBoxEntryDto
  ) {
    return this.createEntry(tenantId, userId, {
      entryType: dto.entryType,
      amount: dto.amount,
      note: dto.note,
      entryDate: dto.entryDate ? new Date(dto.entryDate) : undefined,
    });
  }

  /** Paginated list of entries */
  async getEntries(tenantId: string, dto: GetCashBoxEntriesDto) {
    const {page = 1, limit = 50, startDate, endDate, entryType} = dto;
    const skip = (page - 1) * limit;

    const where: Prisma.CashBoxEntryWhereInput = {tenantId};

    if (startDate || endDate) {
      where.entryDate = {};
      if (startDate) where.entryDate.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.entryDate.lte = end;
      }
    }

    if (entryType) where.entryType = entryType;

    const [entries, total] = await Promise.all([
      this.prisma.cashBoxEntry.findMany({
        where,
        orderBy: {entryDate: 'desc'},
        skip,
        take: limit,
        include: {
          createdBy: {select: {id: true, fullName: true}},
        },
      }),
      this.prisma.cashBoxEntry.count({where}),
    ]);

    return {data: entries, total, page, limit};
  }

  /** Aggregate summary for a date range */
  async getSummary(tenantId: string, startDate?: string, endDate?: string) {
    const where: Prisma.CashBoxEntryWhereInput = {tenantId};

    if (startDate || endDate) {
      where.entryDate = {};
      if (startDate) where.entryDate.gte = new Date(startDate);
      if (endDate) {
        const end = new Date(endDate);
        end.setHours(23, 59, 59, 999);
        where.entryDate.lte = end;
      }
    }

    const [inAgg, outAgg] = await Promise.all([
      this.prisma.cashBoxEntry.aggregate({
        where: {
          ...where,
          entryType: {
            in: [
              CashBoxEntryType.SALE_IN,
              CashBoxEntryType.MANUAL_IN,
              CashBoxEntryType.NEW_INVESTMENT_IN,
              CashBoxEntryType.LOAN_IN,
            ],
          },
        },
        _sum: {amount: true},
      }),
      this.prisma.cashBoxEntry.aggregate({
        where: {
          ...where,
          entryType: {
            in: [
              CashBoxEntryType.EXPENSE_OUT,
              CashBoxEntryType.MANUAL_OUT,
              CashBoxEntryType.INVENTORY_OUT,
            ],
          },
        },
        _sum: {amount: true},
      }),
    ]);

    // Running balance = all-time total regardless of date filter
    const [allTimeIn, allTimeOut] = await Promise.all([
      this.prisma.cashBoxEntry.aggregate({
        where: {
          tenantId,
          entryType: {
            in: [
              CashBoxEntryType.SALE_IN,
              CashBoxEntryType.MANUAL_IN,
              CashBoxEntryType.NEW_INVESTMENT_IN,
              CashBoxEntryType.LOAN_IN,
            ],
          },
        },
        _sum: {amount: true},
      }),
      this.prisma.cashBoxEntry.aggregate({
        where: {
          tenantId,
          entryType: {
            in: [
              CashBoxEntryType.EXPENSE_OUT,
              CashBoxEntryType.MANUAL_OUT,
              CashBoxEntryType.INVENTORY_OUT,
            ],
          },
        },
        _sum: {amount: true},
      }),
    ]);

    const cashIn = inAgg._sum.amount ?? 0;
    const cashOut = outAgg._sum.amount ?? 0;
    const currentBalance =
      (allTimeIn._sum.amount ?? 0) - (allTimeOut._sum.amount ?? 0);

    return {cashIn, cashOut, currentBalance};
  }

  /** Delete a manual entry (only MANUAL_IN / MANUAL_OUT) */
  async deleteEntry(tenantId: string, id: string) {
    // Ensure only manual entries can be deleted
    return this.prisma.cashBoxEntry.deleteMany({
      where: {
        id,
        tenantId,
        entryType: {
          in: [CashBoxEntryType.MANUAL_IN, CashBoxEntryType.MANUAL_OUT],
        },
      },
    });
  }
}
