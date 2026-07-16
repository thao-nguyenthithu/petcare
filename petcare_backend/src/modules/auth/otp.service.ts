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

// Cấu hình OTP
const OTP_TTL_SECONDS = 5 * 60;
const MAX_ATTEMPTS = 5;
const RESEND_COOLDOWN_SECONDS = 30;
const LOCK_SECONDS = 5 * 60;
const RESET_TOKEN_TTL_SECONDS = 10 * 60;

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

    const otp = randomInt(0, 1000000).toString().padStart(6, '0');
    await this.redis.set(
      this.otpKey(purpose, email),
      this.hash(otp),
      'EX',
      OTP_TTL_SECONDS,
    );
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

  //sai quá số lần hoặc hết hạn đều phải gửi lại mã mới
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
