import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class InventoryService {
  constructor(private prisma: PrismaService) { }

  async findAll(tenantId: string, q?: string) {
    // Allow filtering by query string for POS search/typeahead. We match itemName, variant SKU, variant name, and product name.
    const where: any = { tenantId };
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
      return items.map((item) => ({
        ...item,
        itemName: item.variant?.product
          ? `${item.variant.product.name}${item.variant.variantName ? ' - ' + item.variant.variantName : ''}`
          : item.itemName,
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
    return items.map((item) => ({
      ...item,
      itemName: item.variant?.product
        ? `${item.variant.product.name}${item.variant.variantName ? ' - ' + item.variant.variantName : ''}`
        : item.itemName,
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

    // We'll auto-generate batch number if not provided, but the generation
    // needs to be performed after we determine the variantId/derivedItemName
    // so we can make the incremental number per product/variant per date.

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

    // Determine derived itemName from variant/product so inventory refers to catalog
    let derivedItemName = itemName;
    if (variantId) {
      const variant = await this.prisma.productVariant.findUnique({
        where: { id: variantId },
        include: { product: true },
      });
      if (variant) {
        derivedItemName = `${variant.product.name}${variant.variantName ? ' - ' + variant.variantName : ''}`;
      }
    }

    // Auto-generate batch number if not provided, using format `BATCH-dd-mm-yyyy-n`.
    // Increment `n` for each batch for the same product/variant on the same date (start with 1).
    let batchNo = providedBatchNo;
    if (!batchNo) {
      const now = new Date();
      const dd = String(now.getDate()).padStart(2, '0');
      const mm = String(now.getMonth() + 1).padStart(2, '0');
      const yyyy = String(now.getFullYear());
      const dateKey = `${dd}-${mm}-${yyyy}`;
      const prefix = `BATCH-${dateKey}-`;

      // Find existing batches for same variant (or same derivedItemName if variant not present) on this date
      const existingItems = variantId
        ? await this.prisma.inventoryItem.findMany({
            where: { tenantId, variantId, batchNo: { startsWith: prefix } },
          })
        : await this.prisma.inventoryItem.findMany({
            where: { tenantId, itemName: derivedItemName, batchNo: { startsWith: prefix } },
          });

      // Extract sequence numbers and compute max
      let maxSeq = 0;
      for (const item of existingItems) {
        const bn = item.batchNo || '';
        // Expect format BATCH-dd-mm-yyyy-n
        const parts = bn.split('-');
        const seqStr = parts[parts.length - 1];
        const seqNum = Number(seqStr);
        if (Number.isFinite(seqNum) && seqNum > maxSeq) maxSeq = seqNum;
      }
      const seq = maxSeq + 1;
      batchNo = `${prefix}${seq}`;
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

      const targetItem = existingItems.find((item) => {
        const itemExpiry = item.expiryDate
          ? new Date(item.expiryDate).toISOString().split('T')[0]
          : null;
        const newExpiry = expiryDate
          ? new Date(expiryDate).toISOString().split('T')[0]
          : null;
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
            itemName: derivedItemName,
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
        itemName: derivedItemName, // Persist derived catalog name
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

    const { maxDiscount, variantId: newVariantId, itemName: clientItemName, ...rest } = data;
    const updateData: any = { ...rest };
    if (maxDiscount !== undefined) {
      updateData.maxDiscountRate = maxDiscount;
    }

    // If client changes variantId, recompute itemName using catalog data
    if (newVariantId && newVariantId !== item.variantId) {
      const variant = await this.prisma.productVariant.findUnique({
        where: { id: newVariantId },
        include: { product: true },
      });
      if (variant) {
        updateData.itemName = `${variant.product.name}${variant.variantName ? ' - ' + variant.variantName : ''}`;
        updateData.variantId = newVariantId;
      }
    }

    // If variantId unchanged but client sent itemName, ignore it and ensure itemName is derived from variant
    if (!newVariantId && item.variantId) {
      const variant = await this.prisma.productVariant.findUnique({
        where: { id: item.variantId },
        include: { product: true },
      });
      if (variant) {
        updateData.itemName = `${variant.product.name}${variant.variantName ? ' - ' + variant.variantName : ''}`;
      }
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
    const items = await this.prisma.inventoryItem.findMany({
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
    return items.map((item) => ({
      ...item,
      itemName: item.variant?.product
        ? `${item.variant.product.name}${item.variant.variantName ? ' - ' + item.variant.variantName : ''}`
        : item.itemName,
      maxDiscount: item.maxDiscountRate,
    }));
  }

  async getExpiring(tenantId: string, days: number = 30) {
    const today = new Date();
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + Number(days));

    const items = await this.prisma.inventoryItem.findMany({
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
    return items.map((item) => ({
      ...item,
      itemName: item.variant?.product
        ? `${item.variant.product.name}${item.variant.variantName ? ' - ' + item.variant.variantName : ''}`
        : item.itemName,
      maxDiscount: item.maxDiscountRate,
    }));
  }
  async getExpired(tenantId: string) {
    const items = await this.prisma.inventoryItem.findMany({
      where: {
        tenantId,
        expiryDate: {
          lt: new Date(),
        },
      },
      include: {
        variant: { include: { product: true } },
      },
    });
    return items.map((item) => ({
      ...item,
      itemName: item.variant?.product
        ? `${item.variant.product.name}${item.variant.variantName ? ' - ' + item.variant.variantName : ''}`
        : item.itemName,
      maxDiscount: item.maxDiscountRate,
    }));
  }
}
