import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { SupabaseService } from '../media/supabase.service';
import { CreateSitterProfileDto } from './dto/create-sitter-profile.dto';

// Ảnh upload 
export interface UploadedImage {
  buffer?: Buffer;
}

@Injectable()
export class SitterProfileService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly supabase: SupabaseService,
  ) {}

  // Tải ảnh CCCD lên bucket cccd-imgs
  async uploadCccd(file: UploadedImage, mat: string) {
    if (!file?.buffer) {
      throw new BadRequestException({
        code: 'THIEU_ANH_CCCD',
        message: 'Thiếu ảnh CCCD',
      });
    }
    const loai = mat === 'back' ? 'back' : 'front';
    const path = `${randomUUID()}_${loai}.jpg`;
    await this.supabase.uploadFile(
      'cccd-imgs',
      path,
      file.buffer,
      'image/jpeg',
    );
    return { path };
  }

  // Gửi hồ sơ đăng ký NCC
  async submit(userId: string, dto: CreateSitterProfileDto) {
    const daCo = await this.prisma.sitter.findUnique({
      where: { userId },
    });
    // Đã được duyệt rồi thì không cho gửi lại
    if (daCo?.status === 'APPROVED') {
      throw new ConflictException({
        code: 'HO_SO_DA_DUYET',
        message: 'Hồ sơ đã được duyệt, không thể gửi lại',
      });
    }
    // CCCD đã có ở hồ sơ của người khác
    const trungCccd = await this.prisma.sitter.findUnique({
      where: { nationalId: dto.nationalId },
    });
    if (trungCccd && trungCccd.userId !== userId) {
      throw new ConflictException({
        code: 'CCCD_DA_DANG_KY',
        message: 'Số CCCD đã được đăng ký',
      });
    }

    const duLieu = {
      legalName: dto.legalName,
      gender: dto.gender,
      dateOfBirth: new Date(dto.dateOfBirth),
      nationalId: dto.nationalId,
      idIssuedPlace: dto.idIssuedPlace,
      idIssuedDate: new Date(dto.idIssuedDate),
      province: dto.province,
      addressDetail: dto.addressDetail,
      cccdFrontPath: dto.cccdFrontPath,
      cccdBackPath: dto.cccdBackPath,
      status: 'PENDING' as const,
      submittedAt: new Date(),
    };

    const hoSo = await this.prisma.sitter.upsert({
      where: { userId },
      create: { userId, ...duLieu },
      update: duLieu,
    });
    return { status: hoSo.status, submittedAt: hoSo.submittedAt };
  }

  // Kiểm tra CCCD đã có ở hồ sơ người khác chưa
  async checkCccd(userId: string, nationalId: string) {
    const daCo = await this.prisma.sitter.findUnique({
      where: { nationalId },
    });
    return { available: !daCo || daCo.userId === userId };
  }

  // Xem trạng thái hồ sơ của người dùng hiện tại
  async getMine(userId: string) {
    const hoSo = await this.prisma.sitter.findUnique({
      where: { userId },
      select: {
        status: true,
        legalName: true,
        submittedAt: true,
        cccdFrontPath: true,
        cccdBackPath: true,
      },
    });
    if (!hoSo) {
      throw new NotFoundException({
        code: 'CHUA_CO_HO_SO',
        message: 'Chưa có hồ sơ nhà cung cấp',
      });
    }
    return hoSo;
  }
}
