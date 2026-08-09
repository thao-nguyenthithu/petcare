import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import Redis from 'ioredis';
import { ServerOptions } from 'socket.io';
import { tuyChonRedis } from './redis-ket-noi';

const HAN_NOI_MS = 10_000;
const logger = new Logger('RedisIoAdapter');

// Adapter Socket.io qua Redis pub/sub
export class RedisIoAdapter extends IoAdapter {
  private adapterConstructor?: ReturnType<typeof createAdapter>;

  async ketNoiRedis(config: ConfigService): Promise<void> {
    const pubClient = new Redis(tuyChonRedis(config));
    const subClient = pubClient.duplicate();
    try {
      await Promise.all([sanSang(pubClient), sanSang(subClient)]);
    } catch (loi) {
      pubClient.disconnect();
      subClient.disconnect();
      throw loi;
    }
    this.adapterConstructor = createAdapter(pubClient, subClient);
  }

  override createIOServer(port: number, options?: ServerOptions): unknown {
    const server = super.createIOServer(port, options) as {
      adapter: (a: ReturnType<typeof createAdapter>) => void;
    };
    if (this.adapterConstructor) {
      server.adapter(this.adapterConstructor);
    }
    return server;
  }
}

// Không còn chỗ nhận sự kiện error là ioredis ném thẳng ra process
function nhanLoiVeSau(client: Redis) {
  client.on('error', (loi: Error) => logger.error(`Redis lỗi: ${loi.message}`));
}

// ioredis thử lại vô hạn và không bao giờ reject, chờ trần thì máy chủ đứng im
function sanSang(client: Redis): Promise<void> {
  return new Promise((resolve, reject) => {
    let loiCuoi = '';
    const ghiLoi = (loi: Error) => {
      loiCuoi = loi.message;
    };
    const hen = setTimeout(() => {
      client.off('error', ghiLoi);
      nhanLoiVeSau(client);
      const kem = loiCuoi ? `: ${loiCuoi}` : '';
      reject(
        new Error(
          `Không nối được Redis sau ${HAN_NOI_MS / 1000} giây${kem}. Kiểm tra REDIS_URL hoặc container petcare_redis`,
        ),
      );
    }, HAN_NOI_MS);
    client.on('error', ghiLoi);
    client.once('ready', () => {
      clearTimeout(hen);
      client.off('error', ghiLoi);
      nhanLoiVeSau(client);
      resolve();
    });
  });
}
