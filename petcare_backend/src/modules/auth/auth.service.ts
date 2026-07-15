import {
  BadRequestException,
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
import { OtpService } from './otp.service';
import { RegisterDto } from './dto/register.dto';
import { VerifyEmailDto } from './dto/verify-email.dto';
import { LoginDto } from './dto/login.dto';

const BCRYPT_ROUNDS = 10;

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly otpService: OtpService,
    private readonly jwt: JwtService,
    private readonly firebase: FirebaseService,
  ) {}

  async register(dto: RegisterDto) {
    const email = dto.email.toLowerCase().trim();

    const daTonTai = await this.prisma.user.findUnique({ where: { email } });
    if (daTonTai?.isVerified) {
      throw new ConflictException({
        code: 'EMAIL_ALREADY_USED',
        message: 'Email đã được sử dụng',
      });
    }

    const trungPhone = await this.prisma.user.findUnique({
      where: { phone: dto.phone },
    });
    if (trungPhone && trungPhone.email !== email) {
      if (trungPhone.isVerified) {
        throw new ConflictException({
          code: 'PHONE_ALREADY_USED',
          message: 'Số điện thoại đã được sử dụng',
        });
      }
      await this.prisma.user.update({
        where: { id: trungPhone.id },
        data: { phone: null },
      });
    }

    const passwordHash = await bcrypt.hash(dto.password, BCRYPT_ROUNDS);
    const data = {
      fullName: dto.fullName.trim(),
      email,
      phone: dto.phone,
      passwordHash,
    };

    try {
      if (daTonTai) {
        await this.prisma.user.update({ where: { email }, data });
      } else {
        await this.prisma.user.create({ data });
      }
    } catch (e) {
      if (
        e instanceof Prisma.PrismaClientKnownRequestError &&
        e.code === 'P2002'
      ) {
        const trungEmail = await this.prisma.user.findUnique({
          where: { email },
        });
        if (trungEmail) {
          throw new ConflictException({
            code: 'EMAIL_ALREADY_USED',
            message: 'Email đã được sử dụng',
          });
        }
        throw new ConflictException({
          code: 'PHONE_ALREADY_USED',
          message: 'Số điện thoại đã được sử dụng',
        });
      }
      throw e;
    }

    await this.otpService.generateAndSend(email, 'verify');
    return {
      message: 'Đăng ký thành công, mã xác minh đã được gửi tới email của bạn',
    };
  }

  async verifyEmail(dto: VerifyEmailDto) {
    const email = dto.email.toLowerCase().trim();

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'Tài khoản không tồn tại',
      });
    }
    if (user.isVerified) return { message: 'Email đã được xác minh trước đó' };

    await this.otpService.verify(email, 'verify', dto.otp);
    await this.prisma.user.update({
      where: { email },
      data: { isVerified: true },
    });
    return { message: 'Xác minh email thành công' };
  }

  async resendVerifyOtp(email: string) {
    email = email.toLowerCase().trim();

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'Tài khoản không tồn tại',
      });
    }
    if (user.isVerified) {
      throw new BadRequestException({
        code: 'EMAIL_ALREADY_VERIFIED',
        message: 'Email đã được xác minh, vui lòng đăng nhập',
      });
    }

    await this.otpService.generateAndSend(email, 'verify');
    return { message: 'Đã gửi lại mã xác minh tới email của bạn' };
  }

  async login(dto: LoginDto) {
    const email = dto.email.toLowerCase().trim();

    const user = await this.prisma.user.findUnique({ where: { email } });
    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    const dungMatKhau = await bcrypt.compare(dto.password, user.passwordHash);
    if (!dungMatKhau) {
      throw new UnauthorizedException('Email hoặc mật khẩu không đúng');
    }

    if (!user.isVerified) {
      throw new ForbiddenException('Email chưa được xác minh');
    }

    return this.signToken(user.id, user.email, user.role);
  }

  async loginWithFirebase(idToken: string) {
    const thongTin = await this.firebase.verifyIdToken(idToken);
    if (!thongTin.email) {
      throw new UnauthorizedException(
        'Tài khoản mạng xã hội không cung cấp email',
      );
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

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        role: true,
        avatarUrl: true,
        isVerified: true,
        createdAt: true,
      },
    });
    if (!user) throw new NotFoundException('Tài khoản không tồn tại');
    return user;
  }

  private signToken(userId: string, email: string, role: UserRole) {
    const payload = { sub: userId, email, role };
    return {
      accessToken: this.jwt.sign(payload),
      user: { id: userId, email, role },
    };
  }
}
