import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { RedisIoAdapter } from './common/redis/redis-io.adapter';
import { nguonChoPhep } from './common/cors';

// Môi trường thật mà còn cấu hình của máy dev thì chặn khởi động
function chanCauHinhNguyHiem(config: ConfigService) {
  if (process.env.NODE_ENV !== 'production') return;
  if (config.get<string>('payment.gateway') === 'mock') {
    throw new Error(
      'Môi trường production không được dùng cổng thanh toán mock, đặt PAYMENT_GATEWAY=vnpay',
    );
  }
  const returnUrl = config.get<string>('payment.vnpay.returnUrl') ?? '';
  if (/localhost|127\.0\.0\.1/.test(returnUrl)) {
    throw new Error(
      'VNPAY_RETURN_URL còn trỏ localhost, người dùng trả tiền xong sẽ không quay lại được',
    );
  }
}

function moSwagger(): boolean {
  if (process.env.SWAGGER_ENABLED === 'true') return true;
  return process.env.NODE_ENV !== 'production';
}

function inCauHinhDangChay(config: ConfigService, logger: Logger) {
  const moiTruong = process.env.NODE_ENV ?? 'chưa đặt';
  const cong = config.get<string>('payment.gateway');
  const nguon = nguonChoPhep();
  const moTaCors = Array.isArray(nguon)
    ? nguon.join(', ')
    : nguon
      ? 'MỞ CHO MỌI NGUỒN'
      : 'chặn mọi trình duyệt';
  logger.log(
    `NODE_ENV=${moiTruong}, cổng thanh toán=${cong}, CORS=${moTaCors}`,
  );
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');
  const config = app.get(ConfigService);
  chanCauHinhNguyHiem(config);
  inCauHinhDangChay(config, logger);

  app.useGlobalFilters(new AllExceptionsFilter());

  // Socket.io qua Redis adapter
  const redisIoAdapter = new RedisIoAdapter(app);
  await redisIoAdapter.ketNoiRedis(config);
  app.useWebSocketAdapter(redisIoAdapter);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.enableCors({ origin: nguonChoPhep(), credentials: true });

  app.setGlobalPrefix('api/v1', { exclude: ['health'] });

  if (moSwagger()) {
    const cauHinhSwagger = new DocumentBuilder()
      .setTitle('Smart Pet Care API')
      .setDescription('REST API cho Smart Pet Care Service Platform')
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    const document = SwaggerModule.createDocument(app, cauHinhSwagger);
    SwaggerModule.setup('api/docs', app, document);
  }

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`Application running on http://localhost:${port}/api/v1`);
  logger.log(
    moSwagger()
      ? `Swagger UI available at http://localhost:${port}/api/docs`
      : 'Swagger tắt ở môi trường này, đặt SWAGGER_ENABLED=true nếu cần mở',
  );
}
void bootstrap().catch((loi: Error) => {
  new Logger('Bootstrap').error(`Máy chủ không khởi động được: ${loi.message}`);
  process.exit(1);
});
