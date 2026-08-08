import { Injectable, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import {
  OnGatewayConnection,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Namespace, Socket } from 'socket.io';
import { nguonChoPhep } from '../../common/cors';
import { JwtPayload } from '../auth/strategies/jwt.strategy';

export interface TinPhat {
  id: string;
  type: string;
  role: string;
  title: string;
  body: string;
  targetId?: string | null;
}

// Kênh báo tin tới thẳng máy đang mở, không đợi push của Firebase
@Injectable()
@WebSocketGateway({ namespace: '/notify', cors: { origin: nguonChoPhep() } })
export class NotificationsGateway implements OnGatewayConnection {
  private readonly logger = new Logger(NotificationsGateway.name);

  @WebSocketServer() server!: Namespace;

  constructor(private readonly jwt: JwtService) {}

  async handleConnection(client: Socket): Promise<void> {
    try {
      const token =
        (client.handshake.auth?.token as string | undefined) ??
        client.handshake.headers.authorization?.replace(/^Bearer /, '');
      if (!token) throw new Error('thieu token');
      const payload = this.jwt.verify<JwtPayload>(token);
      client.data.userId = payload.sub;
      await client.join(this.tenRoom(payload.sub));
    } catch {
      client.emit('notify:error', {
        code: 'TOKEN_KHONG_HOP_LE',
        message: 'Phiên đăng nhập không hợp lệ',
      });
      client.disconnect(true);
    }
  }

  private tenRoom(userId: string): string {
    return `user:${userId}`;
  }

  phatTinMoi(userId: string, tin: TinPhat): void {
    try {
      this.server?.to(this.tenRoom(userId)).emit('notify:new', {
        id: tin.id,
        type: tin.type,
        role: tin.role,
        title: tin.title,
        body: tin.body,
        targetId: tin.targetId ?? null,
      });
    } catch (error) {
      this.logger.error(
        `Phát tin realtime thất bại: ${(error as Error).message}`,
      );
    }
  }
}
