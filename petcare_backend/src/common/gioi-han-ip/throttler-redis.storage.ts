import type { ThrottlerStorage } from '@nestjs/throttler';
import type Redis from 'ioredis';

type BanGhiDem = {
  totalHits: number;
  timeToExpire: number;
  isBlocked: boolean;
  timeToBlockExpire: number;
};

// Bộ đếm cửa sổ cố định đặt ở Redis để nhiều máy chủ cùng thấy một con số (bộ luật mục 12)
export class ThrottlerRedisStorage implements ThrottlerStorage {
  constructor(private readonly redis: Redis) {}

  async increment(
    key: string,
    ttl: number,
    limit: number,
    _blockDuration: number,
    throttlerName: string,
  ): Promise<BanGhiDem> {
    const khoa = `ip-limit:${throttlerName}:${key}`;
    const soLan = await this.redis.incr(khoa);
    let conLaiMs = await this.redis.pttl(khoa);
    // Khoá chưa có hạn thì đặt ngay, kẻo chết giữa hai lệnh là bộ đếm sống vĩnh viễn
    if (conLaiMs < 0) {
      await this.redis.pexpire(khoa, ttl);
      conLaiMs = ttl;
    }
    const conLaiGiay = Math.ceil(conLaiMs / 1000);
    const biChan = soLan > limit;
    return {
      totalHits: soLan,
      timeToExpire: conLaiGiay,
      isBlocked: biChan,
      timeToBlockExpire: biChan ? conLaiGiay : 0,
    };
  }
}
