import {
  Controller,
  Get,
  Inject,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { SkipThrottle } from '@nestjs/throttler';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../../common/redis/redis.module';
import { PrismaService } from '../../prisma/prisma.service';

type TinhTrang = { db: boolean; redis: boolean };

// Nằm ngoài tiền tố api/v1 và ngoài Swagger, healthcheck gọi được mà không dựng trang tài liệu
@ApiExcludeController()
@SkipThrottle()
@Controller('health')
export class HealthController {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
  ) {}

  @Get()
  async kiemTra() {
    const [db, redis] = await Promise.all([
      song(() => this.prisma.$queryRaw`SELECT 1`),
      song(() => this.redis.ping()),
    ]);
    const tinhTrang: TinhTrang = { db, redis };
    if (!db || !redis) {
      throw new ServiceUnavailableException({
        code: 'PHU_THUOC_KHONG_SAN_SANG',
        message: 'Máy chủ chưa nối được đủ dịch vụ phụ thuộc',
        ...tinhTrang,
      });
    }
    return { status: 'ok', ...tinhTrang };
  }
}

async function song(goi: () => Promise<unknown>): Promise<boolean> {
  try {
    await goi();
    return true;
  } catch {
    return false;
  }
}
