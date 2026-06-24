import { Test, TestingModule } from '@nestjs/testing';
import { CreditsService } from './credits.service';
import { PrismaService } from '../../common/prisma/prisma.service';
import { CashBoxService } from '../cash-box/cash-box.service';
import { BadRequestException, NotFoundException } from '@nestjs/common';

const mockPrisma = {
  sale: {
    findMany: jest.fn(),
    findFirst: jest.fn(),
    update: jest.fn(),
    aggregate: jest.fn(),
  },
  creditPayment: {
    create: jest.fn(),
  },
  $transaction: jest.fn((ops: any[]) => Promise.all(ops)),
};

const mockCashBox = {
  createEntry: jest.fn(),
};

describe('CreditsService', () => {
  let service: CreditsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CreditsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: CashBoxService, useValue: mockCashBox },
      ],
    }).compile();
    service = module.get<CreditsService>(CreditsService);
    jest.clearAllMocks();
  });

  describe('recordPayment', () => {
    it('throws NotFoundException when sale not found', async () => {
      mockPrisma.sale.findFirst.mockResolvedValue(null);
      await expect(
        service.recordPayment('tenant1', 'user1', 'sale1', { amount: 100 }),
      ).rejects.toThrow(NotFoundException);
    });

    it('throws BadRequestException when amount exceeds dueAmount', async () => {
      mockPrisma.sale.findFirst.mockResolvedValue({
        id: 'sale1',
        dueAmount: 50,
        amountPaid: 0,
        customerName: 'Test',
        customerPhone: '01700000000',
      });
      await expect(
        service.recordPayment('tenant1', 'user1', 'sale1', { amount: 100 }),
      ).rejects.toThrow(BadRequestException);
    });

    it('creates payment and updates sale dueAmount', async () => {
      const sale = {
        id: 'sale1',
        dueAmount: 200,
        amountPaid: 100,
        customerName: 'Rofique',
        customerPhone: '01957047953',
      };
      mockPrisma.sale.findFirst.mockResolvedValue(sale);
      mockPrisma.creditPayment.create.mockResolvedValue({ id: 'pay1', amount: 50 });
      mockPrisma.sale.update.mockResolvedValue({});
      mockCashBox.createEntry.mockResolvedValue({});

      const result = await service.recordPayment('tenant1', 'user1', 'sale1', { amount: 50 });

      expect(result).toEqual({ id: 'pay1', amount: 50 });
      expect(mockPrisma.sale.update).toHaveBeenCalledWith({
        where: { id: 'sale1' },
        data: { dueAmount: 150, amountPaid: 150 },
      });
      expect(mockCashBox.createEntry).toHaveBeenCalledWith(
        'tenant1',
        'user1',
        expect.objectContaining({ amount: 50, entryType: 'SALE_IN' }),
      );
    });
  });
});
