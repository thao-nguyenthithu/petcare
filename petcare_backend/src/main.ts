import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { RedisIoAdapter } from './common/redis/redis-io.adapter';
import { nguonChoPhep } from './common/cors';

// Môi trường thật mà còn cổng mock thì chặn khởi động
function chanCauHinhNguyHiem(config: ConfigService) {
  if (process.env.NODE_ENV !== 'production') return;
  if (config.get<string>('payment.gateway') === 'mock') {
    throw new Error(
      'Môi trường production không được dùng cổng thanh toán mock, đặt PAYMENT_GATEWAY=vnpay',
    );
  }
}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('Bootstrap');
  chanCauHinhNguyHiem(app.get(ConfigService));

  app.useGlobalFilters(new AllExceptionsFilter());

  // Socket.io qua Redis adapter
  const redisIoAdapter = new RedisIoAdapter(app);
  await redisIoAdapter.ketNoiRedis(app.get(ConfigService));
  app.useWebSocketAdapter(redisIoAdapter);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  app.enableCors({ origin: nguonChoPhep(), credentials: true });

  app.setGlobalPrefix('api/v1');

  const config = new DocumentBuilder()
    .setTitle('Smart Pet Care API')
    .setDescription('REST API cho Smart Pet Care Service Platform')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port);
  logger.log(`Application running on http://localhost:${port}/api/v1`);
  logger.log(`Swagger UI available at http://localhost:${port}/api/docs`);
}
void bootstrap();
