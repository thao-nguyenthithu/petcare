import { JwtService } from '@nestjs/jwt';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Namespace, Socket } from 'socket.io';
import { JwtPayload } from '../auth/strategies/jwt.strategy';
import { GpsService } from './gps.service';
import { nguonChoPhep } from '../../common/cors';

// Toạ độ là dữ liệu riêng tư
@WebSocketGateway({ namespace: '/gps', cors: { origin: nguonChoPhep() } })
export class GpsGateway implements OnGatewayConnection {
  @WebSocketServer() server!: Namespace;

  constructor(
    private readonly jwt: JwtService,
    private readonly gpsService: GpsService,
  ) {}

  handleConnection(client: Socket): void {
    try {
      const token =
        (client.handshake.auth?.token as string | undefined) ??
        client.handshake.headers.authorization?.replace(/^Bearer /, '');
      if (!token) throw new Error('thieu token');
      const payload = this.jwt.verify<JwtPayload>(token);
      client.data.userId = payload.sub;
    } catch {
      client.emit('gps:error', {
        code: 'TOKEN_KHONG_HOP_LE',
        message: 'Phiên đăng nhập không hợp lệ',
      });
      client.disconnect(true);
    }
  }

  private tenRoom(bookingId: string): string {
    return `booking:${bookingId}`;
  }

  @SubscribeMessage('booking:join')
  async join(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { bookingId?: string },
  ): Promise<void> {
    const userId = client.data.userId as string | undefined;
    const bookingId = payload?.bookingId;
    if (!userId || typeof bookingId !== 'string') {
      client.disconnect(true);
      return;
    }
    const duocVao = await this.gpsService.duocVaoRoom(userId, bookingId);
    if (!duocVao) {
      client.emit('gps:error', {
        code: 'KHONG_PHAI_DON_CUA_BAN',
        message: 'Bạn không thuộc đơn này',
      });
      client.disconnect(true);
      return;
    }
    await client.join(this.tenRoom(bookingId));
    client.emit('booking:joined', { bookingId });
  }

  @SubscribeMessage('gps:update')
  async capNhat(
    @ConnectedSocket() client: Socket,
    @MessageBody()
    payload: { bookingId?: string; lat?: number; lng?: number },
  ): Promise<void> {
    const userId = client.data.userId as string | undefined;
    const bookingId = payload?.bookingId;
    const { lat, lng } = payload ?? {};
    if (
      !userId ||
      typeof bookingId !== 'string' ||
      typeof lat !== 'number' ||
      typeof lng !== 'number' ||
      !Number.isFinite(lat) ||
      !Number.isFinite(lng) ||
      Math.abs(lat) > 90 ||
      Math.abs(lng) > 180
    ) {
      return;
    }
    if (!client.rooms.has(this.tenRoom(bookingId))) return;
    const duocPhat = await this.gpsService.duocPhatViTri(userId, bookingId);
    if (!duocPhat) return;
    client.to(this.tenRoom(bookingId)).emit('gps:updated', {
      bookingId,
      lat,
      lng,
      serverTs: Date.now(),
    });
  }
}
