/**
 * Transform Response Interceptor
 * Implements: Consistency/POLA, Interface Segregation Principle
 * Ensures all successful responses follow standard ApiResponse format
 */

import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiResponse } from '../dto/response.dto';

@Injectable()
export class TransformResponseInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map((data) => {
        // If already an ApiResponse, return as-is
        if (data instanceof ApiResponse) {
          return data;
        }

        // If null/undefined, return success with null data
        if (data === null || data === undefined) {
          return ApiResponse.ok(null);
        }

        // If it's a string or primitive, wrap in ApiResponse
        if (typeof data !== 'object') {
          return ApiResponse.ok(data);
        }

        // Check if it has pagination metadata
        if (data.items && data.total !== undefined && data.pagination) {
          return ApiResponse.okWithPagination(
            data.items,
            data.pagination,
            data.message
          );
        }

        // Otherwise wrap in ApiResponse
        return ApiResponse.ok(data);
      })
    );
  }
}
