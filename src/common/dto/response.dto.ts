/**
 * Standard Response DTO layer
 * Implements: Interface Segregation Principle (ISP), Consistency/POLA
 * Ensures controllers never return raw Prisma types - only cleaned DTOs
 */

/**
 * Generic API Response wrapper for all endpoints
 * Provides consistent response format
 */
export class ApiResponse<T> {
  constructor(
    public success: boolean,
    public data?: T,
    public message?: string,
    public pagination?: PaginationMeta,
    public errors?: any[]
  ) {}

  static ok<T>(data: T, message?: string): ApiResponse<T> {
    return new ApiResponse(true, data, message);
  }

  static okWithPagination<T>(
    data: T[],
    pagination: PaginationMeta,
    message?: string
  ): ApiResponse<T[]> {
    return new ApiResponse(true, data, message, pagination);
  }

  static error(message: string, errors?: any[]): ApiResponse<null> {
    return new ApiResponse(false, null, message, undefined, errors);
  }
}

/**
 * Pagination metadata
 */
export class PaginationMeta {
  constructor(public skip: number, public take: number, public total: number) {}

  get page(): number {
    return Math.floor(this.skip / this.take) + 1;
  }

  get totalPages(): number {
    return Math.ceil(this.total / this.take);
  }

  get hasMore(): boolean {
    return this.skip + this.take < this.total;
  }
}

/**
 * Base class for response DTOs - all domain DTOs should extend this
 * Ensures small, focused response objects (ISP)
 */
export abstract class BaseResponseDto {
  id: string;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Common User Response DTO (never expose sensitive fields like password)
 */
export class UserResponseDto extends BaseResponseDto {
  email: string;
  fullName: string;
  role: string;
  tenantId: string;
  isActive: boolean;
}

/**
 * Inventory Item Response DTO
 */
export class InventoryItemResponseDto extends BaseResponseDto {
  tenantId: string;
  itemName: string;
  variantId: string;
  quantity: number;
  purchasePrice: number;
  retailPrice: number;
  batchNo: string;
  expiryDate?: Date;
  notes?: string;
}

/**
 * Product Response DTO
 */
export class ProductResponseDto extends BaseResponseDto {
  tenantId: string;
  name: string;
  description?: string;
  categoryId: string;
  brandId: string;
  productType: string;
}

/**
 * Product Variant Response DTO
 */
export class ProductVariantResponseDto extends BaseResponseDto {
  productId: string;
  tenantId: string;
  variantName: string;
  sku: string;
  retailPrice: number;
  description?: string;
}

/**
 * Sale Response DTO
 */
export class SaleResponseDto extends BaseResponseDto {
  tenantId: string;
  saleNumber: string;
  totalAmount: number;
  totalProfit: number;
  paymentMethod: string;
  status: string;
  items: SaleItemResponseDto[];
}

/**
 * Sale Item Response DTO
 */
export class SaleItemResponseDto {
  inventoryId: string;
  itemName: string;
  quantity: number;
  unitPrice: number;
  discount: number;
  lineTotal: number;
  profit: number;
}

/**
 * CashBox Entry Response DTO
 */
export class CashBoxEntryResponseDto extends BaseResponseDto {
  tenantId: string;
  entryType: string;
  amount: number;
  balance: number;
  referenceId?: string;
  note?: string;
}

/**
 * Category Response DTO
 */
export class CategoryResponseDto extends BaseResponseDto {
  tenantId: string;
  name: string;
  description?: string;
}

/**
 * Brand Response DTO
 */
export class BrandResponseDto extends BaseResponseDto {
  tenantId: string;
  name: string;
  description?: string;
}
