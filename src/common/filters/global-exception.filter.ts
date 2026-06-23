import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import {Response} from 'express';
import {AppException, ErrorResponse} from '../exceptions/app.exception';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorResponse: ErrorResponse | any = {
      code: 'COMMON_006',
      message: 'Internal Server Error',
      timestamp: new Date().toISOString(),
      path: request.url,
    };

    // Handle custom AppException
    if (exception instanceof AppException) {
      status = exception.statusCode;
      errorResponse = {
        code: exception.code,
        message: exception.message,
        details: exception.details,
        timestamp: new Date().toISOString(),
        path: request.url,
      };

      this.logger.warn(
        `AppException: ${exception.code} - ${exception.message}`
      );
    }
    // Handle NestJS HttpException
    else if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        errorResponse = {
          code: this.getErrorCodeFromStatus(status),
          message: exceptionResponse,
          timestamp: new Date().toISOString(),
          path: request.url,
        };
      } else if (typeof exceptionResponse === 'object') {
        errorResponse = {
          ...exceptionResponse,
          timestamp: new Date().toISOString(),
          path: request.url,
        };
      }

      this.logger.warn(`HttpException: ${status} - ${exception.message}`);
    }
    // Handle generic errors
    else if (exception instanceof Error) {
      this.logger.error(exception.message, exception.stack);

      errorResponse = {
        code: 'COMMON_006',
        message: exception.message || 'Internal Server Error',
        timestamp: new Date().toISOString(),
        path: request.url,
      };

      // Only expose error details in development
      if (process.env.NODE_ENV !== 'production') {
        errorResponse.stack = exception.stack;
      }
    }

    if (status >= 500) {
      this.logger.error(
        `Server error at ${request.url} ${request.method}`,
        exception as Error
      );
    }

    response.status(status).json(errorResponse);
  }

  /**
   * Map HTTP status code to error code
   */
  private getErrorCodeFromStatus(status: number): string {
    const statusToCode: Record<number, string> = {
      400: 'COMMON_003', // INVALID_INPUT
      401: 'COMMON_004', // UNAUTHORIZED
      403: 'COMMON_005', // FORBIDDEN
      404: 'COMMON_001', // RESOURCE_NOT_FOUND
      409: 'COMMON_002', // RESOURCE_ALREADY_EXISTS
      500: 'COMMON_006', // INTERNAL_SERVER_ERROR
    };

    return statusToCode[status] || 'COMMON_006';
  }
}
