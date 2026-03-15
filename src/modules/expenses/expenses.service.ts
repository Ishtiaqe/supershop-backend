import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import {
  CreateExpenseCategoryDto,
  UpdateExpenseCategoryDto,
  CreateExpenseDto,
  UpdateExpenseDto,
  GetExpensesFilterDto,
} from './dto/expenses.dto';
import { CashBoxService } from '../cash-box/cash-box.service';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class ExpensesService {
  constructor(
    private prisma: PrismaService,
    private cashBoxService: CashBoxService,
  ) {}

  // --- Expense Categories ---

  async createCategory(tenantId: string, dto: CreateExpenseCategoryDto) {
    const existing = await this.prisma.expenseCategory.findUnique({
      where: {
        name_tenantId: {
          name: dto.name,
          tenantId,
        },
      },
    });

    if (existing) {
      throw new ConflictException(`Category with name '${dto.name}' already exists.`);
    }

    return this.prisma.expenseCategory.create({
      data: {
        ...dto,
        tenantId,
      },
    });
  }

  async getCategories(tenantId: string) {
    return this.prisma.expenseCategory.findMany({
      where: { tenantId },
      orderBy: { name: 'asc' },
    });
  }

  async updateCategory(tenantId: string, id: string, dto: UpdateExpenseCategoryDto) {
    const category = await this.prisma.expenseCategory.findFirst({
      where: { id, tenantId },
    });

    if (!category) {
      throw new NotFoundException('Expense category not found');
    }

    if (dto.name && dto.name !== category.name) {
      const existing = await this.prisma.expenseCategory.findUnique({
        where: {
          name_tenantId: {
            name: dto.name,
            tenantId,
          },
        },
      });

      if (existing) {
        throw new ConflictException(`Category with name '${dto.name}' already exists.`);
      }
    }

    return this.prisma.expenseCategory.update({
      where: { id },
      data: dto,
    });
  }

  async deleteCategory(tenantId: string, id: string) {
    const category = await this.prisma.expenseCategory.findFirst({
      where: { id, tenantId },
      include: {
        _count: {
          select: { expenses: true },
        },
      },
    });

    if (!category) {
      throw new NotFoundException('Expense category not found');
    }

    if (category._count.expenses > 0) {
      throw new ConflictException('Cannot delete category because it has associated expenses.');
    }

    await this.prisma.expenseCategory.delete({
      where: { id },
    });

    return { success: true };
  }

  // --- Expenses ---

  async createExpense(tenantId: string, employeeId: string, dto: CreateExpenseDto) {
    // Verify category exists and belongs to tenant
    const category = await this.prisma.expenseCategory.findFirst({
      where: { id: dto.categoryId, tenantId },
    });

    if (!category) {
      throw new NotFoundException('Expense category not found or does not belong to this tenant');
    }

    const expense = await this.prisma.expense.create({
      data: {
        ...dto,
        expenseDate: dto.expenseDate ? new Date(dto.expenseDate) : new Date(),
        tenantId,
        employeeId,
      },
      include: {
        category: true,
        employee: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
      },
    });

    // Auto-create a cash box EXPENSE_OUT entry
    try {
      await this.cashBoxService.createEntry(tenantId, employeeId, {
        entryType: 'EXPENSE_OUT' as any,
        amount: expense.amount,
        note: `Expense: ${category.name}${expense.description ? ` — ${expense.description}` : ''}`,
        referenceId: expense.id,
        entryDate: expense.expenseDate,
      });
    } catch (err) {
      console.error('[CashBox] Failed to create EXPENSE_OUT entry:', err?.message);
    }

    return expense;
  }

  async getExpenses(tenantId: string, filterDto: GetExpensesFilterDto) {
    const { startDate, endDate, categoryId, page = '1', limit = '10' } = filterDto;
    const skip = (Number(page) - 1) * Number(limit);

    const where: any = { tenantId };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    if (startDate || endDate) {
      where.expenseDate = {};
      if (startDate) where.expenseDate.gte = new Date(startDate);
      if (endDate) where.expenseDate.lte = new Date(endDate);
    }

    const [data, total] = await Promise.all([
      this.prisma.expense.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { expenseDate: 'desc' },
        include: {
          category: true,
          employee: {
            select: {
              id: true,
              fullName: true,
              email: true,
            },
          },
        },
      }),
      this.prisma.expense.count({ where }),
    ]);

    return {
      data,
      meta: {
        total,
        page: Number(page),
        limit: Number(limit),
        totalPages: Math.ceil(total / Number(limit)),
      },
    };
  }

  async getExpenseSummary(tenantId: string, filterDto: GetExpensesFilterDto) {
    const { startDate, endDate } = filterDto;
    
    const where: any = { tenantId };
    
    if (startDate || endDate) {
      where.expenseDate = {};
      if (startDate) where.expenseDate.gte = new Date(startDate);
      if (endDate) where.expenseDate.lte = new Date(endDate);
    }

    const expenses = await this.prisma.expense.findMany({
      where,
      include: {
        category: true,
      },
    });

    let totalAmount = 0;
    const categorySummary: Record<string, { name: string; amount: number; count: number }> = {};

    expenses.forEach((expense) => {
      totalAmount += expense.amount;
      
      const catId = expense.categoryId;
      if (!categorySummary[catId]) {
        categorySummary[catId] = {
          name: expense.category.name,
          amount: 0,
          count: 0,
        };
      }
      
      categorySummary[catId].amount += expense.amount;
      categorySummary[catId].count += 1;
    });

    return {
      totalAmount,
      totalCount: expenses.length,
      categorySummary: Object.values(categorySummary).sort((a, b) => b.amount - a.amount),
    };
  }

  async getExpenseById(tenantId: string, id: string) {
    const expense = await this.prisma.expense.findFirst({
      where: { id, tenantId },
      include: {
        category: true,
        employee: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
      },
    });

    if (!expense) {
      throw new NotFoundException('Expense not found');
    }

    return expense;
  }

  async updateExpense(tenantId: string, id: string, dto: UpdateExpenseDto) {
    const expense = await this.prisma.expense.findFirst({
      where: { id, tenantId },
    });

    if (!expense) {
      throw new NotFoundException('Expense not found');
    }

    if (dto.categoryId && dto.categoryId !== expense.categoryId) {
      const category = await this.prisma.expenseCategory.findFirst({
        where: { id: dto.categoryId, tenantId },
      });

      if (!category) {
        throw new NotFoundException('Expense category not found or does not belong to this tenant');
      }
    }

    return this.prisma.expense.update({
      where: { id },
      data: {
        ...dto,
        expenseDate: dto.expenseDate ? new Date(dto.expenseDate) : undefined,
      },
      include: {
        category: true,
      },
    });
  }

  async deleteExpense(tenantId: string, id: string) {
    const expense = await this.prisma.expense.findFirst({
      where: { id, tenantId },
    });

    if (!expense) {
      throw new NotFoundException('Expense not found');
    }

    await this.prisma.expense.delete({
      where: { id },
    });

    return { success: true };
  }
}
