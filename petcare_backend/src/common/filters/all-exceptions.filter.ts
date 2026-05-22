import {
  ExceptionFilter, Catch, ArgumentsHost,
  HttpException, HttpStatus, Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx      = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request  = ctx.getRequest<Request>();

    const status = exception instanceof HttpException
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    // Xử lý message — ưu tiên lấy mảng lỗi chi tiết từ ValidationPipe
    let message: string | string[];
    if (exception instanceof HttpException) {
      const res = exception.getResponse() as Record<string, unknown>;
      message = (res['message'] as string | string[]) ?? exception.message;
    } else {
      message = 'Internal server error';
    }

    // Log lỗi 500 để debug
    if (status === HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(exception);
    }

    response.status(status).json({
      success:    false,
      statusCode: status,
      message,           // string hoặc string[] tùy loại lỗi
      path:       request.url,
      timestamp:  new Date().toISOString(),
    });
  }
}
