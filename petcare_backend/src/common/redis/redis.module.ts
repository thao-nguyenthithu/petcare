import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { tuyChonRedis } from './redis-ket-noi';

// Token client Redis dùng chung lưu OTP, cooldown
export const REDIS_CLIENT = 'REDIS_CLIENT';

@Global()
@Module({
  providers: [
    {
      provide: REDIS_CLIENT,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => new Redis(tuyChonRedis(config)),
    },
  ],
  exports: [REDIS_CLIENT],
})
export class RedisModule {}
