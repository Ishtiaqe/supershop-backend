/**
 * Reusable business logic validators
 * Implements: DRY (Don't Repeat Yourself) principle
 * Centralizes validation logic used across multiple services
 */

import {
  BadRequestException,
  SalesValidationException,
  InventoryValidationException,
  ErrorCode,
} from '../exceptions/app.exception';

/**
 * Price validation logic
 * Used in: InventoryService, CatalogService, SalesService
 */
export class PriceValidator {
  /**
   * Validate that retail price >= purchase price
   */
  static validateRetailVsPurchase(
    retailPrice: number,
    purchasePrice: number
  ): void {
    if (retailPrice < purchasePrice) {
      throw new InventoryValidationException(
        `Retail price (${retailPrice}) cannot be lower than purchase price (${purchasePrice})`,
        ErrorCode.INV_RETAIL_BELOW_PURCHASE
      );
    }
  }

  /**
   * Validate price is positive
   */
  static validatePositive(price: number, fieldName: string): void {
    if (price <= 0) {
      throw new BadRequestException(
        `${fieldName} must be greater than 0`,
        ErrorCode.INVALID_INPUT
      );
    }
  }

  /**
   * Validate price is non-negative
   */
  static validateNonNegative(price: number, fieldName: string): void {
    if (price < 0) {
      throw new BadRequestException(
        `${fieldName} cannot be negative`,
        ErrorCode.INVALID_INPUT
      );
    }
  }
}

/**
 * Discount validation logic
 * Used in: SalesService, PriceCalculationService
 */
export class DiscountValidator {
  /**
   * Validate discount percentage is between 0 and 100
   */
  static validateDiscountPercent(discount: number | undefined): void {
    if (discount === undefined || discount === null) {
      return; // Optional field
    }

    if (discount < 0 || discount > 100) {
      throw new SalesValidationException(
        `Discount must be between 0 and 100%, received: ${discount}%`,
        ErrorCode.SALE_INVALID_DISCOUNT_PERCENT
      );
    }
  }

  /**
   * Validate discount doesn't exceed maximum allowed
   */
  static validateMaxDiscount(
    discount: number | undefined,
    maxAllowed: number | undefined
  ): void {
    if (!discount || !maxAllowed) return;

    if (discount > maxAllowed) {
      throw new SalesValidationException(
        `Discount (${discount}%) exceeds maximum allowed (${maxAllowed}%)`,
        ErrorCode.SALE_DISCOUNT_EXCEEDS_MAXIMUM,
        {requested: discount, maximum: maxAllowed}
      );
    }
  }

  /**
   * Validate that profit margin meets minimum requirements
   */
  static validateMinProfitMargin(
    salePrice: number,
    purchasePrice: number,
    minMarginPercent: number = 4
  ): void {
    const profit = salePrice - purchasePrice;
    const minProfit = (minMarginPercent / 100) * purchasePrice;

    if (profit < minProfit) {
      throw new SalesValidationException(
        `Sale price results in insufficient profit. Minimum margin: ${minMarginPercent}%, Current: ${(
          (profit / purchasePrice) *
          100
        ).toFixed(2)}%`,
        ErrorCode.SALE_INSUFFICIENT_PROFIT_MARGIN,
        {
          salePrice,
          purchasePrice,
          minimumMarginPercent: minMarginPercent,
          currentMarginPercent: (profit / purchasePrice) * 100,
        }
      );
    }
  }
}

/**
 * Inventory quantity validation
 * Used in: SalesService, InventoryService
 */
export class QuantityValidator {
  /**
   * Validate quantity is positive
   */
  static validatePositive(quantity: number, fieldName = 'Quantity'): void {
    if (!Number.isInteger(quantity) || quantity <= 0) {
      throw new BadRequestException(
        `${fieldName} must be a positive integer`,
        ErrorCode.INVALID_INPUT
      );
    }
  }

  /**
   * Validate sufficient stock available
   */
  static validateSufficientStock(available: number, required: number): void {
    if (available < required) {
      throw new SalesValidationException(
        `Insufficient stock. Available: ${available}, Required: ${required}`,
        ErrorCode.SALE_INSUFFICIENT_STOCK,
        {available, required}
      );
    }
  }
}

/**
 * String/name validation
 */
export class NameValidator {
  /**
   * Validate name is not empty and reasonable length
   */
  static validateName(name: string | undefined, fieldName = 'Name'): void {
    if (!name || name.trim().length === 0) {
      throw new BadRequestException(
        `${fieldName} cannot be empty`,
        ErrorCode.INVALID_INPUT
      );
    }

    if (name.length > 255) {
      throw new BadRequestException(
        `${fieldName} cannot exceed 255 characters`,
        ErrorCode.INVALID_INPUT
      );
    }
  }

  /**
   * Validate SKU format
   */
  static validateSku(sku: string | undefined): void {
    if (!sku || sku.trim().length === 0) {
      throw new BadRequestException('SKU is required', ErrorCode.INVALID_INPUT);
    }

    if (sku.length > 50) {
      throw new BadRequestException(
        'SKU cannot exceed 50 characters',
        ErrorCode.INVALID_INPUT
      );
    }
  }
}

/**
 * Pagination validation
 */
export class PaginationValidator {
  private static readonly MAX_PAGE_SIZE = 100;
  private static readonly MIN_PAGE_SIZE = 1;

  /**
   * Validate and normalize pagination parameters
   */
  static validate(skip?: number, take?: number): {skip: number; take: number} {
    const normalizedSkip = Math.max(skip || 0, 0);
    const normalizedTake = Math.min(
      Math.max(take || 20, this.MIN_PAGE_SIZE),
      this.MAX_PAGE_SIZE
    );

    return {skip: normalizedSkip, take: normalizedTake};
  }
}
