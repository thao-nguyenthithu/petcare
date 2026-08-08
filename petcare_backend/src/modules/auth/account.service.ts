import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { UserRole } from '../../../generated/prisma/enums';
import { randomUUID } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { kiemTraAnh, type UploadedImage } from '../media/image-upload';
import { SupabaseService } from '../media/supabase.service';
import { UpdateMeDto } from './dto/update-me.dto';
import { OtpService } from './otp.service';
import {
  AuthScope,
  BCRYPT_ROUNDS,
  BUCKET_AVATAR,
  PHAN_HOI_QUEN_MAT_KHAU_ADMIN,
} from './auth.constants';

// Quên mật khẩu và hồ sơ cá nhân
@Injectable()
export class AccountService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly otpService: OtpService,
    private readonly supabase: SupabaseService,
  ) {}

  async forgotPassword(email: string, scope: AuthScope = 'app') {
    email = email.toLowerCase().trim();

    const user = await this.prisma.user.findUnique({ where: { email } });

    if (scope === 'admin') {
      if (user?.role === UserRole.ADMIN) {
        await this.otpService.generateAndSend(email, 'reset');
      }
      return { message: PHAN_HOI_QUEN_MAT_KHAU_ADMIN };
    }

    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'Email chưa được đăng ký',
      });
    }

    await this.otpService.generateAndSend(email, 'reset');
    return { message: 'Mã xác minh đã được gửi tới email của bạn' };
  }

  async verifyResetOtp(email: string, otp: string, scope: AuthScope = 'app') {
    email = email.toLowerCase().trim();

    const user = await this.prisma.user.findUnique({ where: { email } });

    if (scope === 'admin' && user?.role !== UserRole.ADMIN) {
      throw new BadRequestException({
        code: 'OTP_INVALID',
        message: 'Mã xác minh không đúng',
      });
    }

    if (!user) {
      throw new NotFoundException({
        code: 'USER_NOT_FOUND',
        message: 'Tài khoản không tồn tại',
      });
    }

    await this.otpService.verify(email, 'reset', otp);
    const resetToken = await this.otpService.createResetToken(email);
    return { resetToken };
  }

  async resetPassword(resetToken: string, newPassword: string) {
    const email = await this.otpService.consumeResetToken(resetToken);
    const passwordHash = await bcrypt.hash(newPassword, BCRYPT_ROUNDS);
    await this.prisma.user.update({
      where: { email },
      data: { passwordHash, passwordChangedAt: new Date() },
    });
    await this.otpService.xoaDemSaiMatKhau(email);
    return { message: 'Đặt lại mật khẩu thành công' };
  }

  async capNhatHoSo(userId: string, dto: UpdateMeDto) {
    const ngaySinh = docNgaySinh(dto.dateOfBirth);

    if (dto.phone) {
      const trung = await this.prisma.user.findUnique({
        where: { phone: dto.phone },
        select: { id: true },
      });
      if (trung && trung.id !== userId) {
        throw new ConflictException({
          code: 'PHONE_ALREADY_USED',
          message: 'Số điện thoại đã được sử dụng',
        });
      }
    }

    await this.prisma.user.update({
      where: { id: userId },
      data: {
        ...(dto.fullName !== undefined
          ? { fullName: dto.fullName.trim() }
          : {}),
        ...(dto.phone !== undefined ? { phone: dto.phone } : {}),
        ...(dto.dateOfBirth !== undefined ? { dateOfBirth: ngaySinh } : {}),
      },
    });
    return this.getMe(userId);
  }

  async getMe(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        fullName: true,
        email: true,
        phone: true,
        dateOfBirth: true,
        role: true,
        avatarUrl: true,
        isVerified: true,
        createdAt: true,
        sitter: { select: { status: true, bannedAt: true } },
      },
    });
    if (!user) throw new NotFoundException('Tài khoản không tồn tại');

    const { sitter, ...hoSo } = user;
    const laNguoiCham = sitter?.status === 'APPROVED' && !sitter.bannedAt;
    return {
      ...hoSo,
      roles: laNguoiCham ? ['OWNER', 'SITTER'] : ['OWNER'],
      sitterStatus: sitter?.status ?? null,
    };
  }

  async uploadAvatar(userId: string, file: UploadedImage) {
    if (!file?.buffer) {
      throw new BadRequestException({
        code: 'THIEU_ANH',
        message: 'Thiếu ảnh tải lên',
      });
    }
    await this.supabase.ensurePublicBucket(BUCKET_AVATAR);
    const kieu = kiemTraAnh(file);
    const path = `avatars/${randomUUID()}.${kieu.duoi}`;
    await this.supabase.uploadFile(
      BUCKET_AVATAR,
      path,
      file.buffer,
      kieu.contentType,
    );
    const url = this.supabase.getPublicUrl(BUCKET_AVATAR, path);
    await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: url },
    });
    return { avatarUrl: url };
  }
}

const TUOI_TOI_THIEU = 16;

function docNgaySinh(chuoi?: string): Date | null {
  if (!chuoi) return null;
  const [nam, thang, ngay] = chuoi.split('-').map(Number);
  const moc = new Date(Date.UTC(nam, thang - 1, ngay));
  if (
    moc.getUTCFullYear() !== nam ||
    moc.getUTCMonth() !== thang - 1 ||
    moc.getUTCDate() !== ngay
  ) {
    throw new BadRequestException({
      code: 'NGAY_SINH_KHONG_HOP_LE',
      message: 'Ngày sinh không hợp lệ',
    });
  }
  const bayGio = new Date();
  const dayNhat = new Date(
    Date.UTC(
      bayGio.getUTCFullYear() - TUOI_TOI_THIEU,
      bayGio.getUTCMonth(),
      bayGio.getUTCDate(),
    ),
  );
  if (moc > dayNhat) {
    throw new BadRequestException({
      code: 'CHUA_DU_TUOI',
      message: `Bạn phải từ ${TUOI_TOI_THIEU} tuổi trở lên`,
    });
  }
  return moc;
}
