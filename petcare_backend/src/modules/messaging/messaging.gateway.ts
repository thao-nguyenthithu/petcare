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
import { tinTheoVai, type TinDb, type VaiChat } from './messaging.mapper';
import { MessagingService } from './messaging.service';
import { nguonChoPhep } from '../../common/cors';

@WebSocketGateway({ namespace: '/chat', cors: { origin: nguonChoPhep() } })
export class MessagingGateway implements OnGatewayConnection {
  @WebSocketServer() server!: Namespace;

  constructor(
    private readonly jwt: JwtService,
    private readonly messaging: MessagingService,
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
      client.emit('chat:error', {
        code: 'TOKEN_KHONG_HOP_LE',
        message: 'Phiên đăng nhập không hợp lệ',
      });
      client.disconnect(true);
    }
  }

  private tenRoom(conversationId: string): string {
    return `chat:${conversationId}`;
  }

  @SubscribeMessage('chat:join')
  async vao(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { conversationId?: string },
  ): Promise<void> {
    const userId = client.data.userId as string | undefined;
    const conversationId = payload?.conversationId;
    if (!userId || typeof conversationId !== 'string') {
      client.disconnect(true);
      return;
    }
    const vai = await this.messaging.duocVaoHoiThoai(userId, conversationId);
    if (!vai) {
      client.emit('chat:error', {
        code: 'KHONG_PHAI_HOI_THOAI_CUA_BAN',
        message: 'Bạn không thuộc hội thoại này',
      });
      client.disconnect(true);
      return;
    }
    const vaiTheoHoiThoai = (client.data.vaiTheoHoiThoai ??= {}) as Record<
      string,
      VaiChat
    >;
    vaiTheoHoiThoai[conversationId] = vai;
    await client.join(this.tenRoom(conversationId));
    client.emit('chat:joined', { conversationId });
  }

  @SubscribeMessage('chat:leave')
  async roi(
    @ConnectedSocket() client: Socket,
    @MessageBody() payload: { conversationId?: string },
  ): Promise<void> {
    const conversationId = payload?.conversationId;
    if (typeof conversationId === 'string') {
      await client.leave(this.tenRoom(conversationId));
    }
  }

  async phatTinMoi(
    conversationId: string,
    tin: TinDb,
    kyAnh?: ReadonlyMap<string, string>,
  ): Promise<void> {
    const sockets = await this.server
      ?.in(this.tenRoom(conversationId))
      .fetchSockets();
    for (const s of sockets ?? []) {
      const userId = s.data.userId as string | undefined;
      if (!userId) continue;
      const vai = (
        (s.data.vaiTheoHoiThoai ?? {}) as Record<string, VaiChat | undefined>
      )[conversationId];
      if (!vai) continue;
      s.emit('message:new', {
        conversationId,
        message: tinTheoVai(tin, vai, userId, kyAnh),
      });
    }
  }

  phatDaDoc(conversationId: string, userId: string): void {
    this.server?.to(this.tenRoom(conversationId)).emit('message:read', {
      conversationId,
      userId,
    });
  }
}
