import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../common/prisma/prisma.service';

@Injectable()
export class CatalogService {
  constructor(private prisma: PrismaService) { }

  /**
   * Search catalog items (products and variants) by name
   * Used for autocomplete when adding inventory
   */
  async searchCatalog(tenantId: string, query: string) {
    if (!query || query.length < 2) {
      return [];
    }

    // Search for variants whose product name or variant name matches the query
    const variants = await this.prisma.productVariant.findMany({
      where: {
        tenantId,
        OR: [
          {
            product: {
              name: {
                contains: query,
                mode: 'insensitive',
              },
            },
          },
          {
            variantName: {
              contains: query,
              mode: 'insensitive',
            },
          },
        ],
      },
      include: {
        product: {
          select: {
            id: true,
            name: true,
            description: true,
            productType: true,
            genericName: true,
            manufacturerName: true,
          },
        },
        inventoryItems: {
          where: { tenantId },
          orderBy: { createdAt: 'desc' },
          take: 1,
          select: {
            purchasePrice: true,
          },
        },
      },
      take: 10,
    });

    return variants.map((variant) => ({
      variantId: variant.id,
      productId: variant.product.id,
      productName: variant.product.name,
      variantName: variant.variantName,
      sku: variant.sku,
      retailPrice: variant.retailPrice,
      purchasePrice: variant.inventoryItems[0]?.purchasePrice || 0,
      description: variant.product.description,
      productType: variant.product.productType,
      genericName: variant.product.genericName,
      manufacturerName: variant.product.manufacturerName,
    }));
  }

  /**
   * Get all catalog items (for the catalog management page)
   */
  async getCatalogItems(tenantId: string) {
    const variants = await this.prisma.productVariant.findMany({
      where: { tenantId },
      include: {
        product: {
          select: {
            id: true,
            name: true,
            description: true,
            category: true,
            brand: true,
          },
        },
        inventoryItems: {
          where: { tenantId },
          select: {
            quantity: true,
            purchasePrice: true,
            retailPrice: true,
          },
        },
      },
      orderBy: {
        product: {
          name: 'asc',
        },
      },
    });

    return variants.map((variant) => {
      const totalStock = variant.inventoryItems.reduce(
        (sum, item) => sum + item.quantity,
        0
      );

      return {
        variantId: variant.id,
        productId: variant.product.id,
        productName: variant.product.name,
        variantName: variant.variantName,
        sku: variant.sku,
        retailPrice: variant.retailPrice,
        description: variant.product.description,
        category: variant.product.category?.name,
        brand: variant.product.brand?.name,
        currentStock: totalStock,
      };
    });
  }

  /**
   * Find or create a product by name
   */
  async getOrCreateProduct(tenantId: string, name: string, description?: string) {
    // Try to find existing product (case-insensitive) for this tenant
    let product = await this.prisma.product.findFirst({
      where: {
        tenantId,
        name: {
          equals: name,
          mode: 'insensitive',
        },
      },
    });

    if (!product) {
      product = await this.prisma.product.create({
        data: {
          tenantId,
          name,
          description,
        },
      });
    }

    return product;
  }

  /**
   * Find or create a product variant
   */
  async getOrCreateVariant(
    productId: string,
    variantName: string,
    sku: string,
    retailPrice: number
  ) {
    // Get the product to get tenantId
    const product = await this.prisma.product.findUnique({
      where: { id: productId },
      select: { tenantId: true }
    });

    if (!product) {
      throw new Error('Product not found');
    }

    // Try to find existing variant for this product
    let variant = await this.prisma.productVariant.findFirst({
      where: {
        productId,
        variantName: {
          equals: variantName,
          mode: 'insensitive',
        },
      },
    });

    if (!variant) {
      variant = await this.prisma.productVariant.create({
        data: {
          productId,
          tenantId: product.tenantId,
          variantName,
          sku,
          retailPrice,
        },
      });
    }

    return variant;
  }

  /**
   * Create a new catalog item (product + variant)
   */
  async createCatalogItem(tenantId: string, data: {
    productName: string;
    variantName: string;
    sku: string;
    retailPrice: number;
    description?: string;
  }) {
    const product = await this.getOrCreateProduct(tenantId, data.productName, data.description);

    const variant = await this.getOrCreateVariant(
      product.id,
      data.variantName,
      data.sku,
      data.retailPrice
    );

    return {
      variantId: variant.id,
      productId: product.id,
      productName: product.name,
      variantName: variant.variantName,
      sku: variant.sku,
      retailPrice: variant.retailPrice,
      description: product.description,
    };
  }

  /**
   * Update a catalog item (variant)
   */
  async updateCatalogItem(
    variantId: string,
    data: {
      variantName?: string;
      sku?: string;
      retailPrice?: number;
    }
  ) {
    const variant = await this.prisma.productVariant.update({
      where: { id: variantId },
      data,
      include: {
        product: true,
      },
    });

    return {
      variantId: variant.id,
      productId: variant.product.id,
      productName: variant.product.name,
      variantName: variant.variantName,
      sku: variant.sku,
      retailPrice: variant.retailPrice,
      description: variant.product.description,
    };
  }

  /**
   * Delete a catalog item (variant)
   * Only delete if no inventory items reference it
   */
  async deleteCatalogItem(variantId: string) {
    // Check if any inventory items reference this variant
    const inventoryCount = await this.prisma.inventoryItem.count({
      where: { variantId },
    });

    if (inventoryCount > 0) {
      throw new Error(
        'Cannot delete catalog item with existing inventory. Remove inventory first.'
      );
    }

    await this.prisma.productVariant.delete({
      where: { id: variantId },
    });

    return { success: true };
  }

  // ===== Category Management =====

  async getAllCategories(tenantId: string) {
    return this.prisma.category.findMany({
      where: { tenantId },
      include: {
        _count: {
          select: { products: true },
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  async createCategory(tenantId: string, name: string) {
    return this.prisma.category.create({
      data: { tenantId, name },
    });
  }

  async updateCategory(id: string, name: string) {
    return this.prisma.category.update({
      where: { id },
      data: { name },
    });
  }

  async deleteCategory(id: string) {
    // Check if any products use this category
    const productCount = await this.prisma.product.count({
      where: { categoryId: id },
    });

    if (productCount > 0) {
      throw new Error(
        `Cannot delete category with ${productCount} products. Reassign products first.`
      );
    }

    await this.prisma.category.delete({
      where: { id },
    });

    return { success: true };
  }

  // ===== Brand Management =====

  async getAllBrands(tenantId: string) {
    return this.prisma.brand.findMany({
      where: { tenantId },
      include: {
        _count: {
          select: { products: true },
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  async createBrand(tenantId: string, name: string) {
    return this.prisma.brand.create({
      data: { tenantId, name },
    });
  }

  async updateBrand(id: string, name: string) {
    return this.prisma.brand.update({
      where: { id },
      data: { name },
    });
  }

  async deleteBrand(id: string) {
    // Check if any products use this brand
    const productCount = await this.prisma.product.count({
      where: { brandId: id },
    });

    if (productCount > 0) {
      throw new Error(
        `Cannot delete brand with ${productCount} products. Reassign products first.`
      );
    }

    await this.prisma.brand.delete({
      where: { id },
    });

    return { success: true };
  }
}
