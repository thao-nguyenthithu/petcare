import { forwardRef, Inject } from '@nestjs/common';
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
import { JwtPayload } from '../../auth/strategies/jwt.strategy';
import { SU_KIEN_QUET_XONG, tenRoomDon } from './checkin-scan.constants';
import { PetSafetyScanService } from './pet-safety-scan.service';
import { nguonChoPhep } from '../../../common/cors';

// Kết quả chấm ảnh bắn về đúng room của đơn, không phát ra ngoài
@WebSocketGateway({ namespace: '/checkin', cors: { origin: nguonChoPhep() } })
export class CheckinScanGateway implements OnGatewayConnection {
  @WebSocketServer() server!: Namespace;

  constructor(
    private readonly jwt: JwtService,
    @Inject(forwardRef(() => PetSafetyScanService))
    private readonly scan: PetSafetyScanService,
  ) {}

  // Xác thực ngay lúc handshake để không cho treo kết nối nặc danh nghe ngóng
  handleConnection(client: Socket): void {
    try {
      const token =
        (client.handshake.auth?.token as string | undefined) ??
        client.handshake.headers.authorization?.replace(/^Bearer /, '');
      if (!token) throw new Error('thieu token');
      const payload = this.jwt.verify<JwtPayload>(token);
      client.data.userId = payload.sub;
    } catch {
      client.emit('checkin:error', {
        code: 'TOKEN_KHONG_HOP_LE',
        message: 'Phiên đăng nhập không hợp lệ',
      });
      client.disconnect(true);
    }
  }

  // Quyền kiểm bằng truy vấn DB vì payload client chỉ là lời khai
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
    if (!(await this.scan.duocVaoRoom(userId, bookingId))) {
      client.emit('checkin:error', {
        code: 'KHONG_PHAI_DON_CUA_BAN',
        message: 'Bạn không giữ đơn này',
      });
      client.disconnect(true);
      return;
    }
    await client.join(tenRoomDon(bookingId));
    client.emit('booking:joined', { bookingId });
  }

  // Rớt socket thì app đọc lại bằng endpoint lô, sự kiện này chỉ để nhanh hơn
  banKetQua(bookingId: string, du: Record<string, unknown>): void {
    this.server?.to(tenRoomDon(bookingId)).emit(SU_KIEN_QUET_XONG, du);
  }
}
