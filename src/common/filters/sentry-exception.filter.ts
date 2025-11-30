import { ExceptionFilter, Catch, ArgumentsHost, HttpException, HttpStatus, Logger } from '@nestjs/common';
import * as Sentry from '@sentry/node';

@Catch()
export class SentryExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(SentryExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    try {
      // Send the error to Sentry; safe even if Sentry not initialized
      Sentry.captureException(exception as Error);
    } catch (e) {
      this.logger.error('Failed to capture exception with Sentry', e as Error);
    }

    const ctx = host.switchToHttp();
    const response = ctx.getResponse();
    const status = exception instanceof HttpException ? exception.getStatus() : HttpStatus.INTERNAL_SERVER_ERROR;
    const message = (exception as any)?.message || 'Internal server error';

    try {
      response.status(status).json({ message });
    } catch (err) {
      // If response is not present (e.g., GraphQL), just log
      this.logger.error('Failed to send response', err as Error);
    }
  }
}
