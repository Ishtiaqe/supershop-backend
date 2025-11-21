import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class InventoryService {
  constructor(private prisma: PrismaService) { }

  async findAll(tenantId: string, q?: string) {
    // Allow filtering by query string for POS search/typeahead. We match itemName, variant SKU, variant name, and product name.
    const where: any = { tenantId }
    if (q && q.length > 0) {
      where.AND = [
        {
          OR: [
            { itemName: { contains: q, mode: 'insensitive' } },
            { variant: { sku: { contains: q, mode: 'insensitive' } } },
            { variant: { variantName: { contains: q, mode: 'insensitive' } } },
            { variant: { product: { name: { contains: q, mode: 'insensitive' } } } },
          ],
        },
      ];
    }

    // Limit results for typeahead performance
    if (q && q.length > 0) {
      const items = await this.prisma.inventoryItem.findMany({
        where,
        include: {
          variant: {
            include: { product: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        take: 20,
      });
      return items.map(item => ({
        ...item,
        maxDiscount: item.maxDiscountRate,
      }));
    }

    const items = await this.prisma.inventoryItem.findMany({
      where,
      include: {
        variant: {
          include: {
            product: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
    return items.map(item => ({
      ...item,
      maxDiscount: item.maxDiscountRate,
    }));
  }

  async create(tenantId: string, data: any) {
    const {
      maxDiscount,
      variantId: providedVariantId,
      expiryDate,
      mfgDate,
      productType,
      genericName,
      manufacturerName,
      itemName,
      batchNo: providedBatchNo,
      ...rest
    } = data;

    // Auto-generate batch number if not provided
    const batchNo = providedBatchNo || `BATCH-${Date.now()}`;

    let variantId = providedVariantId;

    // If no variantId but we have itemName, create a new Product and Variant (Auto-cataloging)
    if (!variantId && itemName) {
      // 1. Create Product
      const product = await this.prisma.product.create({
        data: {
          tenantId,
          name: itemName,
          productType: productType || 'GENERAL',
          genericName: genericName,
          manufacturerName: manufacturerName,
        },
      });

      // 2. Create Variant (Default 1 unit)
      const variant = await this.prisma.productVariant.create({
        data: {
          tenantId,
          productId: product.id,
          variantName: 'Standard', // Default variant name
          sku: `SKU-${Date.now()}`, // Simple auto-generated SKU
          retailPrice: rest.retailPrice || 0,
        },
      });

      variantId = variant.id;
    }

    // If variantId is present (either provided or just created), try to find existing item to merge
    // Merge only if variantId, expiryDate, AND batchNo all match
    if (variantId) {
      const existingItems = await this.prisma.inventoryItem.findMany({
        where: {
          tenantId,
          variantId,
          batchNo, // Include batch number in query
        },
      });

      const targetItem = existingItems.find(item => {
        const itemExpiry = item.expiryDate ? new Date(item.expiryDate).toISOString().split('T')[0] : null;
        const newExpiry = expiryDate ? new Date(expiryDate).toISOString().split('T')[0] : null;
        return itemExpiry === newExpiry;
      });

      if (targetItem) {
        // Merge with existing item (same variant, expiry, and batch)
        const result = await this.prisma.inventoryItem.update({
          where: { id: targetItem.id },
          data: {
            quantity: targetItem.quantity + (rest.quantity || 0),
            purchasePrice: rest.purchasePrice,
            retailPrice: rest.retailPrice,
            maxDiscountRate: maxDiscount,
            mfgDate: mfgDate,
            updatedAt: new Date(),
          },
        });
        return {
          ...result,
          maxDiscount: result.maxDiscountRate,
        };
      }
    }

    // Create new item if no match found
    // Each unique batch is stored separately
    // IMPORTANT: Filter out product-related fields that are not in InventoryItem model
    const result = await this.prisma.inventoryItem.create({
      data: {
        quantity: rest.quantity,
        purchasePrice: rest.purchasePrice,
        retailPrice: rest.retailPrice,
        batchNo: batchNo, // Store batch number
        itemName: itemName, // Keep itemName for ad-hoc reference if needed, though we prefer variantId
        variantId,
        expiryDate,
        mfgDate,
        maxDiscountRate: maxDiscount,
        tenantId,
      },
    });
    return {
      ...result,
      maxDiscount: result.maxDiscountRate,
    };
  }

  async update(id: string, tenantId: string, data: any) {
    const item = await this.prisma.inventoryItem.findFirst({
      where: { id, tenantId },
    });

    if (!item) {
      throw new NotFoundException('Inventory item not found');
    }

    const { maxDiscount, ...rest } = data;
    const updateData: any = { ...rest };
    if (maxDiscount !== undefined) {
      updateData.maxDiscountRate = maxDiscount;
    }

    const result = await this.prisma.inventoryItem.update({
      where: { id },
      data: updateData,
    });
    return {
      ...result,
      maxDiscount: result.maxDiscountRate,
    };
  }

  async delete(id: string, tenantId: string) {
    const item = await this.prisma.inventoryItem.findFirst({
      where: { id, tenantId },
    });

    if (!item) {
      throw new NotFoundException('Inventory item not found');
    }

    await this.prisma.inventoryItem.delete({ where: { id } });
    return { message: 'Inventory item deleted successfully' };
  }

  async getLowStock(tenantId: string, threshold: number = 20) {
    return this.prisma.inventoryItem.findMany({
      where: {
        tenantId,
        quantity: { lte: Number(threshold) },
      },
      include: {
        variant: {
          include: { product: true },
        },
      },
      orderBy: {
        quantity: 'asc',
      },
    });
  }

  async getExpiring(tenantId: string, days: number = 30) {
    const today = new Date();
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + Number(days));

    return this.prisma.inventoryItem.findMany({
      where: {
        tenantId,
        expiryDate: {
          lte: futureDate,
          gte: today,
        },
        quantity: {
          gt: 0, // Only show items that are actually in stock
        },
      },
      include: {
        variant: {
          include: { product: true },
        },
      },
      orderBy: {
        expiryDate: 'asc',
      },
    });
  }

  async getExpired(tenantId: string) {
    return this.prisma.inventoryItem.findMany({
      where: {
        tenantId,
        expiryDate: {
          lt: new Date(),
        },
      },
    });
  }
}
