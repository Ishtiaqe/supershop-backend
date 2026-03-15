/**
 * Response Mapper Utility
 * Implements: Interface Segregation Principle (ISP)
 * Provides methods to map database models to response DTOs
 * Ensures we never return raw Prisma objects (which expose all fields)
 */

import {
  UserResponseDto,
  InventoryItemResponseDto,
  ProductResponseDto,
  ProductVariantResponseDto,
  SaleResponseDto,
  SaleItemResponseDto,
  CashBoxEntryResponseDto,
  CategoryResponseDto,
  BrandResponseDto,
} from '../dto/response.dto';

/**
 * Response mapper for various database models
 * Each method extracts only necessary fields, implementing ISP
 */
export class ResponseMapper {
  /**
   * Map user to safe response DTO (excludes password)
   */
  static mapUserToResponse(user: any): UserResponseDto {
    return {
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      role: user.role,
      tenantId: user.tenantId,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    };
  }

  /**
   * Map inventory item to response DTO
   */
  static mapInventoryItemToResponse(item: any): InventoryItemResponseDto {
    return {
      id: item.id,
      tenantId: item.tenantId,
      itemName: item.itemName,
      variantId: item.variantId,
      quantity: item.quantity,
      purchasePrice: item.purchasePrice,
      retailPrice: item.retailPrice,
      batchNo: item.batchNo,
      expiryDate: item.expiryDate,
      notes: item.notes,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    };
  }

  /**
   * Map product to response DTO
   */
  static mapProductToResponse(product: any): ProductResponseDto {
    return {
      id: product.id,
      tenantId: product.tenantId,
      name: product.name,
      description: product.description,
      categoryId: product.categoryId,
      brandId: product.brandId,
      productType: product.productType,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    };
  }

  /**
   * Map product variant to response DTO
   */
  static mapProductVariantToResponse(variant: any): ProductVariantResponseDto {
    return {
      id: variant.id,
      productId: variant.productId,
      tenantId: variant.tenantId,
      variantName: variant.variantName,
      sku: variant.sku,
      retailPrice: variant.retailPrice,
      description: variant.description,
      createdAt: variant.createdAt,
      updatedAt: variant.updatedAt,
    };
  }

  /**
   * Map sale item to response DTO
   */
  static mapSaleItemToResponse(item: any): SaleItemResponseDto {
    return {
      inventoryId: item.inventoryId,
      itemName: item.inventoryName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      discount: item.discountAmount || 0,
      lineTotal: item.lineTotal,
      profit: item.profit,
    };
  }

  /**
   * Map sale to response DTO
   */
  static mapSaleToResponse(sale: any): SaleResponseDto {
    return {
      id: sale.id,
      tenantId: sale.tenantId,
      saleNumber: sale.saleNumber,
      totalAmount: sale.totalAmount,
      totalProfit: sale.totalProfit,
      paymentMethod: sale.paymentMethod,
      status: sale.status,
      items: (sale.items || []).map((item: any) =>
        this.mapSaleItemToResponse(item)
      ),
      createdAt: sale.createdAt,
      updatedAt: sale.updatedAt,
    };
  }

  /**
   * Map cash box entry to response DTO
   */
  static mapCashBoxEntryToResponse(entry: any): CashBoxEntryResponseDto {
    return {
      id: entry.id,
      tenantId: entry.tenantId,
      entryType: entry.entryType,
      amount: entry.amount,
      balance: entry.balance,
      referenceId: entry.referenceId,
      note: entry.note,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    };
  }

  /**
   * Map category to response DTO
   */
  static mapCategoryToResponse(category: any): CategoryResponseDto {
    return {
      id: category.id,
      tenantId: category.tenantId,
      name: category.name,
      description: category.description,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    };
  }

  /**
   * Map brand to response DTO
   */
  static mapBrandToResponse(brand: any): BrandResponseDto {
    return {
      id: brand.id,
      tenantId: brand.tenantId,
      name: brand.name,
      description: brand.description,
      createdAt: brand.createdAt,
      updatedAt: brand.updatedAt,
    };
  }

  /**
   * Map array of items
   */
  static mapArray<T>(items: any[], mapper: (item: any) => T): T[] {
    return items.map(mapper);
  }
}
