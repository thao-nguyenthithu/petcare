import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
} from '@nestjs/common';
import { createHash, randomBytes, randomInt } from 'crypto';
import Redis from 'ioredis';
import { REDIS_CLIENT } from '../../common/redis/redis.module';
import { MailService, OtpPurpose } from '../mail/mail.service';
import {
  KHOA_DANG_NHAP_PHUT,
  OTP_MOI_GIO,
  SAI_MAT_KHAU_TOI_DA,
} from './auth.constants';

export type GoiDangKy = {
  fullName: string;
  email: string;
  phone: string;
  passwordHash: string;
};

// Cấu hình OTP
export const OTP_TTL_SECONDS = 5 * 60;
export const MAX_ATTEMPTS = 5;
export const RESEND_COOLDOWN_SECONDS = 30;
export const LOCK_SECONDS = 5 * 60;
export const RESET_TOKEN_TTL_SECONDS = 10 * 60;

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(
    @Inject(REDIS_CLIENT) private readonly redis: Redis,
    private readonly mailService: MailService,
  ) {}

  private otpKey(purpose: OtpPurpose, email: string) {
    return `otp:${purpose}:${email}`;
  }
  private attemptsKey(purpose: OtpPurpose, email: string) {
    return `otp:att:${purpose}:${email}`;
  }
  private cooldownKey(purpose: OtpPurpose, email: string) {
    return `otp:cd:${purpose}:${email}`;
  }
  private lockKey(purpose: OtpPurpose, email: string) {
    return `otp:lock:${purpose}:${email}`;
  }
  private quotaKey(email: string) {
    return `otp:quota:${email}`;
  }
  private pendingKey(email: string) {
    return `dangky:${email}`;
  }

  private hash(otp: string) {
    return createHash('sha256').update(otp).digest('hex');
  }

  private async assertNotLocked(email: string, purpose: OtpPurpose) {
    const lockTtl = await this.redis.ttl(this.lockKey(purpose, email));
    if (lockTtl > 0) {
      const phut = Math.ceil(lockTtl / 60);
      throw new BadRequestException({
        code: 'OTP_LOCKED',
        message: `Bạn đã nhập sai quá ${MAX_ATTEMPTS} lần. Vui lòng thử lại sau ${phut} phút`,
        meta: { minutes: phut, seconds: lockTtl, attempts: MAX_ATTEMPTS },
      });
    }
  }

  // Sinh OTP 6 số, lưu hash vào Redis rồi đẩy job gửi email
  async generateAndSend(email: string, purpose: OtpPurpose) {
    await this.assertNotLocked(email, purpose);

    const daGuiGanDay = await this.redis.exists(
      this.cooldownKey(purpose, email),
    );
    if (daGuiGanDay) {
      throw new BadRequestException({
        code: 'OTP_COOLDOWN',
        message: 'Vui lòng chờ 30 giây trước khi gửi lại mã',
      });
    }

    const daGui = await this.redis.incr(this.quotaKey(email));
    if (daGui === 1) await this.redis.expire(this.quotaKey(email), 3600);
    if (daGui > OTP_MOI_GIO) {
      const conLai = await this.redis.ttl(this.quotaKey(email));
      throw new BadRequestException({
        code: 'OTP_QUA_NHIEU',
        message: `Email này đã nhận ${OTP_MOI_GIO} mã trong một giờ, vui lòng thử lại sau`,
        meta: { seconds: conLai > 0 ? conLai : 3600, limit: OTP_MOI_GIO },
      });
    }

    const otp = randomInt(0, 1000000).toString().padStart(6, '0');
    await this.redis.set(
      this.otpKey(purpose, email),
      this.hash(otp),
      'EX',
      OTP_TTL_SECONDS,
    );
    await this.redis.expire(this.pendingKey(email), OTP_TTL_SECONDS);
    await this.redis.del(this.attemptsKey(purpose, email));
    await this.redis.set(
      this.cooldownKey(purpose, email),
      '1',
      'EX',
      RESEND_COOLDOWN_SECONDS,
    );

    await this.mailService.queueOtpEmail(email, otp, purpose);

    if (process.env.NODE_ENV !== 'production') {
      this.logger.debug(`OTP (${purpose}) cho ${email}: ${otp}`);
    }
  }

  async verify(email: string, purpose: OtpPurpose, otp: string) {
    await this.assertNotLocked(email, purpose);

    const hashDaLuu = await this.redis.get(this.otpKey(purpose, email));
    if (!hashDaLuu) {
      throw new BadRequestException({
        code: 'OTP_EXPIRED',
        message:
          'Mã xác minh đã hết hạn hoặc không tồn tại, vui lòng gửi lại mã',
      });
    }

    const soLanThu = await this.redis.incr(this.attemptsKey(purpose, email));
    await this.redis.expire(this.attemptsKey(purpose, email), OTP_TTL_SECONDS);
    if (soLanThu > MAX_ATTEMPTS) {
      await this.redis.del(
        this.otpKey(purpose, email),
        this.attemptsKey(purpose, email),
        this.cooldownKey(purpose, email),
      );
      await this.redis.set(
        this.lockKey(purpose, email),
        '1',
        'EX',
        LOCK_SECONDS,
      );
      const phut = Math.ceil(LOCK_SECONDS / 60);
      throw new BadRequestException({
        code: 'OTP_LOCKED',
        message: `Bạn đã nhập sai quá ${MAX_ATTEMPTS} lần. Tài khoản tạm khóa ${phut} phút`,
        meta: { minutes: phut, seconds: LOCK_SECONDS, attempts: MAX_ATTEMPTS },
      });
    }

    if (this.hash(otp) !== hashDaLuu) {
      throw new BadRequestException({
        code: 'OTP_INVALID',
        message: 'Mã xác minh không đúng',
      });
    }

    await this.redis.del(
      this.otpKey(purpose, email),
      this.attemptsKey(purpose, email),
    );
  }

  async luuDangKyCho(email: string, goi: GoiDangKy) {
    await this.redis.set(
      this.pendingKey(email),
      JSON.stringify(goi),
      'EX',
      OTP_TTL_SECONDS,
    );
  }

  async docDangKyCho(email: string): Promise<GoiDangKy | null> {
    const chuoi = await this.redis.get(this.pendingKey(email));
    return chuoi ? (JSON.parse(chuoi) as GoiDangKy) : null;
  }

  async xoaDangKyCho(email: string) {
    await this.redis.del(this.pendingKey(email));
  }

  private loginLockKey(email: string) {
    return `login:lock:${email}`;
  }
  private loginFailKey(email: string) {
    return `login:fail:${email}`;
  }

  async chanNeuDangBiKhoa(email: string) {
    const conLai = await this.redis.ttl(this.loginLockKey(email));
    if (conLai > 0) {
      const phut = Math.ceil(conLai / 60);
      throw new BadRequestException({
        code: 'DANG_NHAP_BI_KHOA',
        message: `Bạn đã nhập sai quá ${SAI_MAT_KHAU_TOI_DA} lần. Vui lòng thử lại sau ${phut} phút`,
        meta: { minutes: phut, seconds: conLai },
      });
    }
  }

  async ghiNhanSaiMatKhau(email: string): Promise<number> {
    const soLan = await this.redis.incr(this.loginFailKey(email));
    await this.redis.expire(this.loginFailKey(email), KHOA_DANG_NHAP_PHUT * 60);
    if (soLan >= SAI_MAT_KHAU_TOI_DA) {
      await this.redis.set(
        this.loginLockKey(email),
        '1',
        'EX',
        KHOA_DANG_NHAP_PHUT * 60,
      );
      await this.redis.del(this.loginFailKey(email));
      return 0;
    }
    return SAI_MAT_KHAU_TOI_DA - soLan;
  }

  async xoaDemSaiMatKhau(email: string) {
    await this.redis.del(this.loginFailKey(email), this.loginLockKey(email));
  }

  private resetTokenKey(token: string) {
    return `reset_token:${token}`;
  }

  async createResetToken(email: string): Promise<string> {
    const token = randomBytes(32).toString('hex');
    await this.redis.set(
      this.resetTokenKey(token),
      email,
      'EX',
      RESET_TOKEN_TTL_SECONDS,
    );
    return token;
  }

  async consumeResetToken(token: string): Promise<string> {
    const key = this.resetTokenKey(token);
    const email = await this.redis.get(key);
    if (!email) {
      throw new BadRequestException({
        code: 'RESET_TOKEN_INVALID',
        message:
          'Phiên đặt lại mật khẩu không hợp lệ hoặc đã hết hạn, vui lòng thử lại',
      });
    }
    await this.redis.del(key);
    return email;
  }
}
