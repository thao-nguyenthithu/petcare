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
        'Chưa cấu hình đủ FIREBASE_CLIENT_EMAIL/FIREBASE_PRIVATE_KEY trong .env — đăng nhập Google/Facebook sẽ không hoạt động',
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

  async verifyIdToken(idToken: string) {
    if (!this.daKhoiTao) {
      throw new ServiceUnavailableException(
        'Đăng nhập mạng xã hội chưa được cấu hình trên server',
      );
    }
    try {
      const decoded = await admin.auth().verifyIdToken(idToken);
      return {
        firebaseUid: decoded.uid,
        email: decoded.email ?? null,
        fullName: (decoded.name as string | undefined) ?? null,
        avatarUrl: decoded.picture ?? null,
      };
    } catch {
      throw new UnauthorizedException(
        'Token đăng nhập không hợp lệ hoặc đã hết hạn',
      );
    }
  }
}
