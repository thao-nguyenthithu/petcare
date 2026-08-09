import { ServiceUnavailableException } from '@nestjs/common';
import Redis from 'ioredis';
import { HealthController } from '../src/modules/health/health.controller';
import { PrismaService } from '../src/prisma/prisma.service';

// Railway trỏ healthcheck vào route này, vỡ là cả lượt deploy bị đánh trượt

function dungController(dbSong: boolean, redisSong: boolean) {
  const prisma = {
    $queryRaw: () =>
      dbSong
        ? Promise.resolve([{ x: 1 }])
        : Promise.reject(new Error('mất kết nối')),
  } as unknown as PrismaService;
  const redis = {
    ping: () =>
      redisSong
        ? Promise.resolve('PONG')
        : Promise.reject(new Error('ECONNREFUSED')),
  } as unknown as Redis;
  return new HealthController(prisma, redis);
}

describe('GET /health', () => {
  it('cả hai dịch vụ sống thì trả ok', async () => {
    await expect(dungController(true, true).kiemTra()).resolves.toEqual({
      status: 'ok',
      db: true,
      redis: true,
    });
  });

  it('mất database thì trả 503 và chỉ đúng chỗ hỏng', async () => {
    const loi = await dungController(false, true)
      .kiemTra()
      .catch((e: ServiceUnavailableException) => e);
    expect(loi).toBeInstanceOf(ServiceUnavailableException);
    expect((loi as ServiceUnavailableException).getResponse()).toMatchObject({
      code: 'PHU_THUOC_KHONG_SAN_SANG',
      db: false,
      redis: true,
    });
  });

  it('mất Redis thì trả 503', async () => {
    const loi = await dungController(true, false)
      .kiemTra()
      .catch((e: ServiceUnavailableException) => e);
    expect(loi).toBeInstanceOf(ServiceUnavailableException);
    expect((loi as ServiceUnavailableException).getResponse()).toMatchObject({
      db: true,
      redis: false,
    });
  });
});
