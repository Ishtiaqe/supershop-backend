export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  pagination?: PaginationMeta;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface ApiError {
  success: false;
  error: string;
  message?: string;
  statusCode: number;
  timestamp: string;
  path: string;
}

export class ResponseHelper {
  static success<T>(
    data: T,
    message?: string,
    pagination?: PaginationMeta
  ): ApiResponse<T> {
    return {
      success: true,
      data,
      message,
      pagination,
    };
  }

  static error(
    error: string,
    message?: string,
    statusCode: number = 500
  ): ApiError {
    return {
      success: false,
      error,
      message,
      statusCode,
      timestamp: new Date().toISOString(),
      path: '', // This should be set by interceptor
    };
  }

  static paginated<T>(
    data: T[],
    page: number,
    limit: number,
    total: number
  ): ApiResponse<T[]> {
    const totalPages = Math.ceil(total / limit);
    return {
      success: true,
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages,
        hasNext: page < totalPages,
        hasPrev: page > 1,
      },
    };
  }
}

// Decorator for standardizing responses
export function StandardResponse() {
  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      try {
        const result = await originalMethod.apply(this, args);

        // If result is already standardized, return as-is
        if (result && typeof result === 'object' && 'success' in result) {
          return result;
        }

        // Otherwise, wrap in standard response
        return ResponseHelper.success(result);
      } catch (error) {
        const statusCode = error.status || 500;
        const message = error.message || 'Internal server error';
        throw ResponseHelper.error(
          message,
          error.response?.data?.message,
          statusCode
        );
      }
    };

    return descriptor;
  };
}
