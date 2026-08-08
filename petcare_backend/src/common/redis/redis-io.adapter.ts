import { ConfigService } from '@nestjs/config';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import Redis from 'ioredis';
import { ServerOptions } from 'socket.io';
import { tuyChonRedis } from './redis-ket-noi';

// Adapter Socket.io qua Redis pub/sub
export class RedisIoAdapter extends IoAdapter {
  private adapterConstructor?: ReturnType<typeof createAdapter>;

  async ketNoiRedis(config: ConfigService): Promise<void> {
    const pubClient = new Redis(tuyChonRedis(config));
    const subClient = pubClient.duplicate();
    // Chờ cả hai kết nối sẵn sàng rồi mới cho server nhận socket
    await Promise.all([
      new Promise((resolve) => pubClient.once('ready', resolve)),
      new Promise((resolve) => subClient.once('ready', resolve)),
    ]);
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
