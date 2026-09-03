import {
  Injectable,
  Logger,
  OnModuleInit,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as admin from 'firebase-admin';

// Cầu nối Firebase: verify ID Token do Flutter gửi lên sau khi đăng nhập Google/Facebook
@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);
  private daKhoiTao = false;
  private daCanhBaoPush = false;

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    if (admin.apps.length > 0) {
      this.daKhoiTao = true;
      return;
    }

    const projectId = this.config.get<string>('firebase.projectId');
    const clientEmail = this.config.get<string>('firebase.clientEmail');
    const privateKey = this.config.get<string>('firebase.privateKey');

    const chuaCauHinh =
      !projectId || !clientEmail || !privateKey || privateKey.includes('...');
    if (chuaCauHinh) {
      this.logger.warn(
        'Chưa cấu hình đủ FIREBASE_CLIENT_EMAIL/FIREBASE_PRIVATE_KEY trong .env — đăng nhập Google/Facebook và push đều không hoạt động',
      );
      return;
    }

    try {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey,
        }),
      });
      this.daKhoiTao = true;
    } catch (error) {
      this.logger.error(
        `Khởi tạo Firebase Admin thất bại: ${(error as Error).message}`,
      );
    }
  }

  // Đẩy push tới nhiều thiết bị của cùng một người
  async guiPush(
    tokens: string[],
    tin: { title: string; body: string; data?: Record<string, string> },
  ): Promise<string[]> {
    if (tokens.length === 0) return [];
    if (!this.daKhoiTao) {
      if (!this.daCanhBaoPush) {
        this.daCanhBaoPush = true;
        this.logger.warn(
          'Firebase Admin chưa khởi tạo nên mọi push đang bị bỏ qua',
        );
      }
      return [];
    }
    try {
      const ketQua = await admin.messaging().sendEachForMulticast({
        tokens,
        notification: { title: tin.title, body: tin.body },
        data: tin.data,
      });
      const tokenChet: string[] = [];
      ketQua.responses.forEach((r, i) => {
        if (r.success) return;
        const ma = (r.error as { code?: string } | undefined)?.code ?? '';
        if (
          ma === 'messaging/registration-token-not-registered' ||
          ma === 'messaging/invalid-registration-token' ||
          ma === 'messaging/invalid-argument'
        ) {
          tokenChet.push(tokens[i]);
        }
      });
      return tokenChet;
    } catch (error) {
      this.logger.error(`Gửi push thất bại: ${(error as Error).message}`);
      return [];
    }
  }

  async verifyIdToken(idToken: string) {
    if (!this.daKhoiTao) {
      throw new ServiceUnavailableException({
        code: 'SOCIAL_NOT_CONFIGURED',
        message: 'Đăng nhập mạng xã hội chưa được cấu hình trên server',
      });
    }
    try {
      const decoded = await admin.auth().verifyIdToken(idToken);
      let email = decoded.email ?? null;
      let fullName = (decoded.name as string | undefined) ?? null;
      let avatarUrl = decoded.picture ?? null;
      // Bật liên kết nhiều tài khoản mỗi email thì Firebase bỏ trống email ở hồ sơ gốc, chỉ provider còn giữ
      if (!email) {
        const hoSo = await admin.auth().getUser(decoded.uid);
        const nhaCungCap = hoSo.providerData.find((p) => p.email);
        email = nhaCungCap?.email ?? null;
        fullName =
          fullName ?? hoSo.displayName ?? nhaCungCap?.displayName ?? null;
        avatarUrl = avatarUrl ?? hoSo.photoURL ?? nhaCungCap?.photoURL ?? null;
      }
      return { firebaseUid: decoded.uid, email, fullName, avatarUrl };
    } catch {
      throw new UnauthorizedException({
        code: 'INVALID_SOCIAL_TOKEN',
        message: 'Token đăng nhập không hợp lệ hoặc đã hết hạn',
      });
    }
  }
}
