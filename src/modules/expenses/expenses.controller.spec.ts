import { Test, TestingModule } from '@nestjs/testing';
import { ExpensesController } from './expenses.controller';
import { ExpensesService } from './expenses.service';

const mockExpensesService = {
  createCategory: jest.fn(),
  getCategories: jest.fn(),
  updateCategory: jest.fn(),
  deleteCategory: jest.fn(),
  createExpense: jest.fn(),
  getExpenses: jest.fn(),
  getExpenseSummary: jest.fn(),
  getExpenseById: jest.fn(),
  updateExpense: jest.fn(),
  deleteExpense: jest.fn(),
};

describe('ExpensesController', () => {
  let controller: ExpensesController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExpensesController],
      providers: [{ provide: ExpensesService, useValue: mockExpensesService }],
    }).compile();

    controller = module.get<ExpensesController>(ExpensesController);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
