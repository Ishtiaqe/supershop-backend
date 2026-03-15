import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';
import { Prisma } from '@prisma/client';

@Injectable()
export class ShortListService {
  constructor(private prisma: PrismaService) {}

  /**
   * Check if item meets 50% rule: current_quantity < (last_restock_quantity / 2)
   */
  private async checkFiftyPercentRule(inventoryId: string): Promise<boolean> {
    const item = await this.prisma.inventoryItem.findUnique({
      where: { id: inventoryId },
    });

    if (!item) {
      return false;
    }

    // Backward compatibility: if lastRestockQty is not set, use current quantity as the baseline
    const lastRestockQty = item.lastRestockQty ?? item.quantity;

    if (!lastRestockQty || lastRestockQty === 0) {
      return false;
    }

    const threshold = lastRestockQty / 2;
    return item.quantity < threshold;
  }

  /**
   * Check if item is slow (no sales for 30+ days)
   */
  private async checkSlowItem(inventoryId: string): Promise<boolean> {
    const item = await this.prisma.inventoryItem.findUnique({
      where: { id: inventoryId },
    });

    if (!item || !item.lastMovedDate) {
      return false;
    }

    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    return item.lastMovedDate < thirtyDaysAgo;
  }

  /**
   * Auto-add item to short list if it meets 50% rule
   * Called automatically after inventory changes
   */
  async autoCheckAndAdd(
    inventoryId: string,
    tenantId: string,
  ): Promise<any> {
    const inventory = await this.prisma.inventoryItem.findUnique({
      where: { id: inventoryId },
    });

    if (!inventory || inventory.tenantId !== tenantId) {
      return null;
    }

    const meetsRule = await this.checkFiftyPercentRule(inventoryId);
    const isSlow = await this.checkSlowItem(inventoryId);

    if (!meetsRule && !isSlow) {
      return null;
    }

    // Check if already in short list
    const existing = await this.prisma.shortList.findUnique({
      where: { inventoryId },
    });

    if (existing) {
      return existing;
    }

    // Add to short list
    return await this.prisma.shortList.create({
      data: {
        inventoryId,
        tenantId,
        isSlowItem: isSlow,
        reason: meetsRule ? '50% rule' : 'slow_item',
        addedBy: 'system',
      },
      include: {
        inventory: true,
      },
    });
  }

  /**
   * Manually toggle item on short list
   */
  async toggle(
    inventoryId: string,
    tenantId: string,
    userId?: string,
  ): Promise<any> {
    const inventory = await this.prisma.inventoryItem.findUnique({
      where: { id: inventoryId },
    });

    if (!inventory || inventory.tenantId !== tenantId) {
      throw new BadRequestException('Inventory item not found or does not belong to your tenant');
    }

    const existing = await this.prisma.shortList.findUnique({
      where: { inventoryId },
    });

    if (existing) {
      // Remove from short list
      return await this.prisma.shortList.delete({
        where: { inventoryId },
      });
    }

    // Add to short list manually
    return await this.prisma.shortList.create({
      data: {
        inventoryId,
        tenantId,
        isSlowItem: await this.checkSlowItem(inventoryId),
        reason: 'manual',
        addedBy: userId || 'manual',
      },
      include: {
        inventory: true,
      },
    });
  }

  /**
   * Get all short list items for a tenant
   */
  async findAll(
    tenantId: string,
    options?: {
      skip?: number;
      take?: number;
      sortBy?: 'quantity' | 'addedAt' | 'name';
      sortOrder?: 'asc' | 'desc';
      filterSlow?: boolean;
    },
  ): Promise<any> {
    const where: Prisma.ShortListWhereInput = { tenantId };

    if (options?.filterSlow !== undefined) {
      where.isSlowItem = options.filterSlow;
    }

    const items = await this.prisma.shortList.findMany({
      where,
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
      skip: options?.skip || 0,
      take: options?.take || 100,
      orderBy:
        options?.sortBy === 'quantity'
          ? { inventory: { quantity: options?.sortOrder || 'asc' } }
          : options?.sortBy === 'name'
            ? { inventory: { itemName: options?.sortOrder || 'asc' } }
            : { addedAt: options?.sortOrder || 'desc' },
    });

    const total = await this.prisma.shortList.count({ where });

    return {
      data: items,
      total,
      skip: options?.skip || 0,
      take: options?.take || 100,
    };
  }

  /**
   * Get short list item by ID
   */
  async findOne(id: string, tenantId: string): Promise<any> {
    const item = await this.prisma.shortList.findUnique({
      where: { inventoryId: id },
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
    });

    if (!item || item.tenantId !== tenantId) {
      throw new BadRequestException('Short list item not found');
    }

    return item;
  }

  /**
   * Mark item as slow (30+ days without sales)
   */
  async markAsSlow(inventoryId: string, tenantId: string): Promise<any> {
    const inventory = await this.prisma.inventoryItem.findUnique({
      where: { id: inventoryId },
    });

    if (!inventory || inventory.tenantId !== tenantId) {
      return null;
    }

    const item = await this.prisma.shortList.findUnique({
      where: { inventoryId },
    });

    if (!item) {
      return await this.prisma.shortList.create({
        data: {
          inventoryId,
          tenantId,
          isSlowItem: true,
          reason: 'slow_item',
          addedBy: 'system',
        },
        include: { inventory: true },
      });
    }

    return await this.prisma.shortList.update({
      where: { inventoryId },
      data: { isSlowItem: true },
      include: { inventory: true },
    });
  }

  /**
   * Update lastMovedDate when item is sold
   */
  async updateLastMoved(inventoryId: string): Promise<void> {
    await this.prisma.inventoryItem.update({
      where: { id: inventoryId },
      data: { lastMovedDate: new Date() },
    });
  }

  /**
   * Update lastRestockQty and lastRestockDate when item is restocked
   */
  async updateRestock(
    inventoryId: string,
    newQuantity: number,
  ): Promise<void> {
    await this.prisma.inventoryItem.update({
      where: { id: inventoryId },
      data: {
        lastRestockQty: newQuantity,
        lastRestockDate: new Date(),
      },
    });
  }

  /**
   * Get short list statistics for a tenant
   */
  async getStats(tenantId: string): Promise<any> {
    const total = await this.prisma.shortList.count({
      where: { tenantId },
    });

    const slowItems = await this.prisma.shortList.count({
      where: { tenantId, isSlowItem: true },
    });

    const manualItems = await this.prisma.shortList.count({
      where: {
        tenantId,
        reason: 'manual',
      },
    });

    const autoRuleItems = await this.prisma.shortList.count({
      where: {
        tenantId,
        reason: '50% rule',
      },
    });

    // Get all short list inventory IDs then aggregate
    const shortListItems = await this.prisma.shortList.findMany({
      where: { tenantId },
      select: { inventoryId: true },
    });

    const inventoryIds = shortListItems.map(item => item.inventoryId);

    const totalQuantity = await this.prisma.inventoryItem.aggregate({
      where: {
        id: { in: inventoryIds },
      },
      _sum: { quantity: true },
    });

    return {
      total,
      slowItems,
      manualItems,
      autoRuleItems,
      totalQuantity: totalQuantity._sum.quantity || 0,
    };
  }

  /**
   * Remove item from short list
   */
  async remove(inventoryId: string, tenantId: string): Promise<void> {
    const item = await this.prisma.shortList.findUnique({
      where: { inventoryId },
    });

    if (!item || item.tenantId !== tenantId) {
      throw new BadRequestException('Short list item not found');
    }

    await this.prisma.shortList.delete({
      where: { inventoryId },
    });
  }
}
