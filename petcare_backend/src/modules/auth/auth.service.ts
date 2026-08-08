import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { UserRole } from '../../../generated/prisma/enums';
import { Prisma } from '../../../generated/prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { FirebaseService } from '../firebase/firebase.service';
import { SupabaseService } from '../media/supabase.service';
import { OtpService } from './otp.service';
import { RegisterDto } from './dto/register.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { LoginDto } from './dto/login.dto';
import {
  BCRYPT_ROUNDS,
  KHOA_DANG_NHAP_PHUT,
  SAI_MAT_KHAU_TOI_DA,
} from './auth.constants';

export type { AuthScope } from './auth.constants';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly otpService: OtpService,
    private readonly jwt: JwtService,
    private readonly firebase: FirebaseService,
    private readonly supabase: SupabaseService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.toLowerCase().trim();
    await this.kiemTrung(email, dto.phone);
    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    await this.otpService.luuDangKyCho(email, {
      fullName: dto.fullName.trim(),
      email,
      phone: dto.phone,
      passwordHash,
    });
    await this.otpService.generateAndSend(email, 'verify');
    return {
      message: 'Đăng ký thành công, mã xác minh đã được gửi tới email của bạn',
    };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const email = dto.email.toLowerCase().trim();
    const goi = await this.otpService.docDangKyCho(email);
    if (!goi) {
      const daCo = await this.prisma.user.findUnique({ where: { email } });
      if (daCo) return { message: 'Email đã được xác minh trước đó' };
      throw new NotFoundException({
        code: 'DANG_KY_HET_HAN',
        message: 'Thông tin đăng ký đã hết hạn, vui lòng đăng ký lại',
      });
    }

    await this.otpService.verify(email, 'verify', dto.otp);
    await this.kiemTrung(email, goi.phone);
    try {
      await this.prisma.user.create({
        data: {
          fullName: goi.fullName,
          email: goi.email,
          phone: goi.phone,
          passwordHash: goi.passwordHash,
          isVerified: true,
        },
      });
    } catch (e) {
      if (
        e instanceof Prisma.PrismaClientKnownRequestError &&
        e.code === 'P2002'
      ) {
        throw new ConflictException({
          code: 'EMAIL_ALREADY_USED',
          message: 'Email hoặc số điện thoại vừa được người khác đăng ký',
        });
      }
      throw e;
    }
    await this.otpService.xoaDangKyCho(email);
    return { message: 'Xác minh email thành công' };
  }

  async resendVerifyOtp(email: string) {
    email = email.toLowerCase().trim();
    const goi = await this.otpService.docDangKyCho(email);
    if (!goi) {
      throw new NotFoundException({
        code: 'DANG_KY_HET_HAN',
        message: 'Thông tin đăng ký đã hết hạn, vui lòng đăng ký lại',
      });
    }
    await this.otpService.generateAndSend(email, 'verify');
    return { message: 'Đã gửi lại mã xác minh tới email của bạn' };
  }

  // Email và số điện thoại phải chưa thuộc về tài khoản nào
  private async kiemTrung(email: string, phone: string) {
    const [trungEmail, trungPhone] = await Promise.all([
      this.prisma.user.findUnique({ where: { email }, select: { id: true } }),
      this.prisma.user.findUnique({ where: { phone }, select: { id: true } }),
    ]);
    if (trungEmail) {
      throw new ConflictException({
        code: 'EMAIL_ALREADY_USED',
        message: 'Email đã được sử dụng',
      });
    }
    if (trungPhone) {
      throw new ConflictException({
        code: 'PHONE_ALREADY_USED',
        message: 'Số điện thoại đã được sử dụng',
      });
    }
  }

  async login(dto: LoginDto) {
    const email = dto.email.toLowerCase().trim();
    await this.otpService.chanNeuDangBiKhoa(email);

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message: 'Email hoặc mật khẩu không đúng',
      });
    }

    const dungMatKhau = await bcrypt.compare(dto.password, user.passwordHash);
    if (!dungMatKhau) {
      const conLai = await this.otpService.ghiNhanSaiMatKhau(email);
      throw new UnauthorizedException({
        code: 'INVALID_CREDENTIALS',
        message:
          conLai > 0
            ? `Email hoặc mật khẩu không đúng, còn ${conLai} lần thử`
            : `Bạn đã nhập sai quá ${SAI_MAT_KHAU_TOI_DA} lần, tài khoản tạm khoá ${KHOA_DANG_NHAP_PHUT} phút`,
      });
    }

    if (!user.isVerified) {
      throw new ForbiddenException({
        code: 'EMAIL_NOT_VERIFIED',
        message: 'Email chưa được xác minh',
      });
    }

    await this.otpService.xoaDemSaiMatKhau(email);
    return this.signToken(user.id, user.email, user.role);
  }

  async loginWithFirebase(idToken: string) {
    const thongTin = await this.firebase.verifyIdToken(idToken);
    if (!thongTin.email) {
      throw new UnauthorizedException({
        code: 'SOCIAL_NO_EMAIL',
        message: 'Tài khoản mạng xã hội không cung cấp email',
      });
    }
    const email = thongTin.email.toLowerCase();

    let user = await this.prisma.user.findUnique({
      where: { firebaseUid: thongTin.firebaseUid },
    });

    if (!user) {
      const trungEmail = await this.prisma.user.findUnique({
        where: { email },
      });
      if (trungEmail) {
        user = await this.prisma.user.update({
          where: { email },
          data: { firebaseUid: thongTin.firebaseUid, isVerified: true },
        });
      } else {
        user = await this.prisma.user.create({
          data: {
            fullName: thongTin.fullName ?? email.split('@')[0],
            email,
            firebaseUid: thongTin.firebaseUid,
            avatarUrl: thongTin.avatarUrl,
            role: UserRole.OWNER,
            isVerified: true,
          },
        });
      }
    }

    return this.signToken(user.id, user.email, user.role);
  }

  private signToken(userId: string, email: string, role: UserRole) {
    const payload = { sub: userId, email, role };
    return {
      accessToken: this.jwt.sign(payload),
      user: { id: userId, email, role },
    };
  }
}
