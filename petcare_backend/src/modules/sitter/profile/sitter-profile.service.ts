import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { randomUUID } from 'crypto';
import { soTuoi } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { kiemTraAnh } from '../../media/image-upload';
import { SupabaseService } from '../../media/supabase.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import { CreateSitterProfileDto } from './dto/create-sitter-profile.dto';

// Ảnh upload
export interface UploadedImage {
  buffer?: Buffer;
}

export const TUOI_TOI_THIEU_NCC = 18;

@Injectable()
export class SitterProfileService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly supabase: SupabaseService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  // Tải ảnh CCCD lên bucket cccd-imgs
  async uploadCccd(file: UploadedImage, mat: string) {
    if (!file?.buffer) {
      throw new BadRequestException({
        code: 'THIEU_ANH_CCCD',
        message: 'Thiếu ảnh CCCD',
      });
    }
    // Ảnh giấy tờ vào bucket riêng nhưng quản trị viên vẫn mở ra xem, phải soi kiểu thật
    const kieu = kiemTraAnh(file);
    // Ép bucket riêng tư ngay trong code, không phó mặc cho cấu hình tay trên Supabase
    await this.supabase.ensurePrivateBucket('cccd-imgs');
    const loai = mat === 'back' ? 'back' : 'front';
    const path = `${randomUUID()}_${loai}.${kieu.duoi}`;
    await this.supabase.uploadFile(
      'cccd-imgs',
      path,
      file.buffer,
      kieu.contentType,
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
    if (daCo?.status === 'PENDING') {
      const yeuCau = await this.yeuCauSua(
        daCo.id,
        daCo.status,
        daCo.submittedAt,
      );
      if (!yeuCau) {
        throw new ConflictException({
          code: 'HO_SO_DANG_CHO_DUYET',
          message:
            'Hồ sơ đang chờ duyệt, chỉ sửa được khi quản trị viên yêu cầu',
        });
      }
    }
    // Ngày sinh ở đây khớp CCCD nên là số thật, khác lời khai (bộ luật mục 12)
    if (soTuoi(new Date(dto.dateOfBirth)) < TUOI_TOI_THIEU_NCC) {
      throw new BadRequestException({
        code: 'CHUA_DU_TUOI',
        message: `Bạn phải từ ${TUOI_TOI_THIEU_NCC} tuổi mới đăng ký làm người chăm`,
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
      // Công tắc tự duyệt, quản trị viên gạt ở màn 15b (bộ luật mục 15)
      status: this.thamSo.bat('sitter.auto_approve')
        ? ('APPROVED' as const)
        : ('PENDING' as const),
      submittedAt: new Date(),
    };

    const hoSo = await this.prisma.sitter.upsert({
      where: { userId },
      create: { userId, ...duLieu },
      update: duLieu,
    });
    return { status: hoSo.status, submittedAt: hoSo.submittedAt };
  }

  async review(userId: string, status: 'APPROVED' | 'REJECTED') {
    const hoSo = await this.prisma.sitter.findUnique({
      where: { userId },
      select: { status: true },
    });
    if (!hoSo) {
      throw new NotFoundException({
        code: 'CHUA_CO_HO_SO',
        message: 'Chưa có hồ sơ nhà cung cấp',
      });
    }
    const capNhat = await this.prisma.sitter.update({
      where: { userId },
      data: { status },
      select: { status: true, submittedAt: true },
    });
    return capNhat;
  }

  // Kiểm tra CCCD đã có ở hồ sơ người khác chưa
  async checkCccd(userId: string, nationalId: string) {
    const daCo = await this.prisma.sitter.findUnique({
      where: { nationalId },
    });
    return { available: !daCo || daCo.userId === userId };
  }

  // Yêu cầu sửa còn hiệu lực: bị từ chối, hoặc bị nhắn bổ sung mà chưa nộp lại
  private async yeuCauSua(
    sitterId: string,
    status: string,
    submittedAt: Date | null,
  ) {
    if (status !== 'PENDING' && status !== 'REJECTED') return null;
    const ban = await this.prisma.adminAuditLog.findFirst({
      where: {
        targetType: 'SITTER',
        targetId: sitterId,
        action: {
          in: ['YEU_CAU_BO_SUNG_HO_SO_NCC', 'TU_CHOI_HO_SO_NCC'],
        },
      },
      orderBy: { createdAt: 'desc' },
      select: { action: true, reason: true, createdAt: true },
    });
    if (!ban) return null;
    const boSung = ban.action === 'YEU_CAU_BO_SUNG_HO_SO_NCC';
    if (status === 'REJECTED') {
      return boSung
        ? null
        : { kind: 'REJECTED', reason: ban.reason, at: ban.createdAt };
    }
    if (!boSung) return null;
    if (submittedAt && submittedAt > ban.createdAt) return null;
    return { kind: 'SUPPLEMENT', reason: ban.reason, at: ban.createdAt };
  }

  // Xem trạng thái hồ sơ của người dùng hiện tại, đủ trường để nạp lại form sửa
  async getMine(userId: string) {
    const hoSo = await this.prisma.sitter.findUnique({
      where: { userId },
      select: {
        id: true,
        status: true,
        legalName: true,
        gender: true,
        dateOfBirth: true,
        nationalId: true,
        idIssuedPlace: true,
        idIssuedDate: true,
        province: true,
        addressDetail: true,
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

    const { id, ...traVe } = hoSo;
    const yeuCau = await this.yeuCauSua(id, hoSo.status, hoSo.submittedAt);
    // Chờ duyệt yên lành thì khoá đường sửa, không thì hồ sơ đổi ngay dưới tay người duyệt
    return { ...traVe, canEdit: yeuCau !== null, editRequest: yeuCau };
  }
}
