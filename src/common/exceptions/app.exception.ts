/**
 * Application-wide error codes and error hierarchy
 * Implements: Fail Fast principle, Consistency/POLA
 * Allows structured error responses with codes, making debugging easier
 */

/**
 * Error codes organized by domain/context
 * Format: DOMAIN_SEQUENCE (e.g., SALE_001, INV_001)
 */
export enum ErrorCode {
  // General/Common
  RESOURCE_NOT_FOUND = 'COMMON_001',
  RESOURCE_ALREADY_EXISTS = 'COMMON_002',
  INVALID_INPUT = 'COMMON_003',
  UNAUTHORIZED = 'COMMON_004',
  FORBIDDEN = 'COMMON_005',
  INTERNAL_SERVER_ERROR = 'COMMON_006',

  // Sales (SALE_xxx)
  SALE_INVALID_INVENTORY = 'SALE_001',
  SALE_INSUFFICIENT_STOCK = 'SALE_002',
  SALE_DISCOUNT_EXCEEDS_MAXIMUM = 'SALE_003',
  SALE_INVALID_DISCOUNT_PERCENT = 'SALE_004',
  SALE_INSUFFICIENT_PROFIT_MARGIN = 'SALE_005',
  SALE_CREATE_FAILED = 'SALE_006',

  // Inventory (INV_xxx)
  INV_INVALID_PURCHASE_PRICE = 'INV_001',
  INV_INVALID_RETAIL_PRICE = 'INV_002',
  INV_RETAIL_BELOW_PURCHASE = 'INV_003',
  INV_INSUFFICIENT_QUANTITY = 'INV_004',
  INV_CREATE_FAILED = 'INV_005',
  INV_UPDATE_FAILED = 'INV_006',

  // Catalog (CAT_xxx)
  CAT_PRODUCT_NOT_FOUND = 'CAT_001',
  CAT_VARIANT_NOT_FOUND = 'CAT_002',
  CAT_CATEGORY_NOT_FOUND = 'CAT_003',
  CAT_BRAND_NOT_FOUND = 'CAT_004',
  CAT_CREATE_FAILED = 'CAT_005',

  // Auth (AUTH_xxx)
  AUTH_INVALID_CREDENTIALS = 'AUTH_001',
  AUTH_USER_NOT_FOUND = 'AUTH_002',
  AUTH_USER_ALREADY_EXISTS = 'AUTH_003',
  AUTH_INVALID_TOKEN = 'AUTH_004',
  AUTH_TOKEN_EXPIRED = 'AUTH_005',
  AUTH_PERMISSION_DENIED = 'AUTH_006',

  // Tenant (TEN_xxx)
  TEN_TENANT_NOT_FOUND = 'TEN_001',
  TEN_INVALID_SETUP = 'TEN_002',

  // ShortList (SL_xxx)
  SL_ITEM_NOT_FOUND = 'SL_001',
  SL_ADD_FAILED = 'SL_002',

  // CashBox (CB_xxx)
  CB_ENTRY_CREATE_FAILED = 'CB_001',
  CB_INVALID_AMOUNT = 'CB_002',
}

/**
 * Standardized error response structure
 */
export interface ErrorResponse {
  code: ErrorCode;
  message: string;
  details?: Record<string, any>;
  timestamp: string;
  path?: string;
}

/**
 * Custom exception class extending NestJS HttpException
 * Provides structured error responses with codes
 */
export class AppException extends Error {
  constructor(
    public code: ErrorCode,
    public message: string,
    public statusCode: number = 400,
    public details?: Record<string, any>
  ) {
    super(message);
    this.name = 'AppException';
    Object.setPrototypeOf(this, AppException.prototype);
  }

  toJSON(): ErrorResponse {
    return {
      code: this.code,
      message: this.message,
      details: this.details,
      timestamp: new Date().toISOString(),
    };
  }
}

/**
 * NOT_FOUND - 404
 */
export class NotFoundException extends AppException {
  constructor(resource: string, details?: Record<string, any>) {
    super(ErrorCode.RESOURCE_NOT_FOUND, `${resource} not found`, 404, details);
    Object.setPrototypeOf(this, NotFoundException.prototype);
  }
}

/**
 * BAD_REQUEST - 400
 */
export class BadRequestException extends AppException {
  constructor(
    message: string,
    code: ErrorCode = ErrorCode.INVALID_INPUT,
    details?: Record<string, any>
  ) {
    super(code, message, 400, details);
    Object.setPrototypeOf(this, BadRequestException.prototype);
  }
}

/**
 * CONFLICT - 409
 */
export class ConflictException extends AppException {
  constructor(resource: string, details?: Record<string, any>) {
    super(
      ErrorCode.RESOURCE_ALREADY_EXISTS,
      `${resource} already exists`,
      409,
      details
    );
    Object.setPrototypeOf(this, ConflictException.prototype);
  }
}

/**
 * UNAUTHORIZED - 401
 */
export class UnauthorizedException extends AppException {
  constructor(message = 'Unauthorized', details?: Record<string, any>) {
    super(ErrorCode.UNAUTHORIZED, message, 401, details);
    Object.setPrototypeOf(this, UnauthorizedException.prototype);
  }
}

/**
 * FORBIDDEN - 403
 */
export class ForbiddenException extends AppException {
  constructor(message = 'Forbidden', details?: Record<string, any>) {
    super(ErrorCode.FORBIDDEN, message, 403, details);
    Object.setPrototypeOf(this, ForbiddenException.prototype);
  }
}

/**
 * Domain-specific exceptions for business logic validation
 */

/**
 * Sales validation error
 */
export class SalesValidationException extends BadRequestException {
  constructor(message: string, code: ErrorCode, details?: Record<string, any>) {
    super(message, code, details);
    Object.setPrototypeOf(this, SalesValidationException.prototype);
  }
}

/**
 * Inventory validation error
 */
export class InventoryValidationException extends BadRequestException {
  constructor(message: string, code: ErrorCode, details?: Record<string, any>) {
    super(message, code, details);
    Object.setPrototypeOf(this, InventoryValidationException.prototype);
  }
}

/**
 * Catalog validation error
 */
export class CatalogValidationException extends BadRequestException {
  constructor(message: string, code: ErrorCode, details?: Record<string, any>) {
    super(message, code, details);
    Object.setPrototypeOf(this, CatalogValidationException.prototype);
  }
}
