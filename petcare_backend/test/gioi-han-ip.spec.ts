import { HttpException } from '@nestjs/common';
import type { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type Redis from 'ioredis';
import {
  CUA_SO_IP_MS,
  TRAN_IP_MOI_PHUT,
} from '../src/common/gioi-han-ip/gioi-han-ip.constants';
import { IpThrottlerGuard } from '../src/common/gioi-han-ip/ip-throttler.guard';
import { ThrottlerRedisStorage } from '../src/common/gioi-han-ip/throttler-redis.storage';

// Hàng rào theo IP (bộ luật mục 12), vỡ là mất tầng chặn quét dải email

function dungRedisGia(soLan: number, ttlConLaiMs: number) {
  return {
    incr: jest.fn().mockResolvedValue(soLan),
    pttl: jest.fn().mockResolvedValue(ttlConLaiMs),
    pexpire: jest.fn().mockResolvedValue(1),
  };
}

function demMotLan(redis: ReturnType<typeof dungRedisGia>) {
  const storage = new ThrottlerRedisStorage(redis as unknown as Redis);
  return storage.increment(
    '1.2.3.4',
    CUA_SO_IP_MS,
    TRAN_IP_MOI_PHUT,
    0,
    'default',
  );
}

describe('ThrottlerRedisStorage', () => {
  it('lần đếm đầu đặt hạn cho khoá và chưa chặn', async () => {
    const redis = dungRedisGia(1, -1);
    const ketQua = await demMotLan(redis);
    expect(redis.pexpire).toHaveBeenCalledWith(
      'ip-limit:default:1.2.3.4',
      CUA_SO_IP_MS,
    );
    expect(ketQua).toEqual({
      totalHits: 1,
      timeToExpire: 60,
      isBlocked: false,
      timeToBlockExpire: 0,
    });
  });

  it('chạm đúng trần vẫn cho qua', async () => {
    const redis = dungRedisGia(TRAN_IP_MOI_PHUT, 45_000);
    const ketQua = await demMotLan(redis);
    expect(ketQua.isBlocked).toBe(false);
  });

  it('vượt trần thì chặn tới hết cửa sổ và không đặt lại hạn', async () => {
    const redis = dungRedisGia(TRAN_IP_MOI_PHUT + 1, 30_000);
    const ketQua = await demMotLan(redis);
    expect(redis.pexpire).not.toHaveBeenCalled();
    expect(ketQua.isBlocked).toBe(true);
    expect(ketQua.timeToBlockExpire).toBe(30);
  });

  it('khoá mất hạn giữa chừng thì được đặt hạn lại, không đếm vĩnh viễn', async () => {
    const redis = dungRedisGia(7, -1);
    const ketQua = await demMotLan(redis);
    expect(redis.pexpire).toHaveBeenCalled();
    expect(ketQua.timeToExpire).toBe(60);
  });
});

describe('IpThrottlerGuard', () => {
  function dungGuard() {
    return new IpThrottlerGuard([], {} as never, new Reflector());
  }

  it('bỏ qua ngữ cảnh websocket, chỉ đếm HTTP', async () => {
    const nguCanh = { getType: () => 'ws' } as unknown as ExecutionContext;
    await expect(dungGuard().canActivate(nguCanh)).resolves.toBe(true);
  });

  it('vượt trần ném 429 với mã QUA_NHIEU_YEU_CAU', () => {
    const guard = dungGuard() as unknown as {
      throwThrottlingException: () => void;
    };
    let loi: HttpException | undefined;
    try {
      guard.throwThrottlingException();
    } catch (e) {
      loi = e as HttpException;
    }
    expect(loi).toBeInstanceOf(HttpException);
    expect(loi?.getStatus()).toBe(429);
    expect(loi?.getResponse()).toMatchObject({ code: 'QUA_NHIEU_YEU_CAU' });
  });
});
