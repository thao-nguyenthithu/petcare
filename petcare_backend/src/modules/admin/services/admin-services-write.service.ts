import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ServiceType } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { SuaDichVuDto } from './dto/loc-dich-vu.dto';
import { doiBangGia, thieuDeBat } from './rang-buoc-dich-vu';

@Injectable()
export class AdminServicesWriteService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
  ) {}

  // Chỉ tên và mô tả: giá lẫn thời lượng của một đơn đã chốt theo đơn (bộ luật mục 2)
  async suaDanhMuc(type: ServiceType, dto: SuaDichVuDto, adminId: string) {
    const cu = await this.prisma.service.findUnique({
      where: { type },
      select: { name: true },
    });
    const moTa = dto.description ?? null;

    return this.prisma.$transaction(async (db) => {
      const dong = await db.service.upsert({
        where: { type },
        // basePricePerHour là cột bắt buộc nhưng không lối nào đọc, để 0 như lúc sinh đơn
        create: {
          type,
          name: dto.name,
          description: moTa,
          basePricePerHour: 0,
        },
        update: { name: dto.name, description: moTa },
        select: { id: true, type: true, name: true, description: true },
      });
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: 'CAP_NHAT_DANH_MUC_DICH_VU',
          targetType: 'SETTING',
          targetId: dong.id,
          targetCode: type,
          oldValue: cu?.name ?? null,
          newValue: dong.name,
        },
        db,
      );
      return dong;
    });
  }

  async datBat(id: string, enabled: boolean, reason: string, adminId: string) {
    const cauHinh = await this.prisma.sitterService.findUnique({
      where: { id },
      select: {
        id: true,
        sitterId: true,
        type: true,
        enabled: true,
        pricing: true,
        sitter: { select: { user: { select: { fullName: true } } } },
      },
    });
    if (!cauHinh) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_CAU_HINH',
        message: 'Không tìm thấy cấu hình dịch vụ này',
      });
    }
    if (cauHinh.enabled === enabled) {
      throw new ConflictException({
        code: 'TRANG_THAI_KHONG_HOP_LE',
        message: enabled
          ? 'Cấu hình này đang bật rồi'
          : 'Cấu hình này đang tắt rồi',
      });
    }
    if (enabled) {
      const thieu = thieuDeBat(doiBangGia(cauHinh.type, cauHinh.pricing));
      if (thieu) throw new BadRequestException(thieu);
    }

    await this.prisma.$transaction(async (db) => {
      // Kẹp trạng thái cũ vào where để hai quản trị viên bấm cùng lúc không ghi đè nhau
      const doi = await db.sitterService.updateMany({
        where: { id, enabled: !enabled },
        data: { enabled },
      });
      if (doi.count === 0) {
        throw new ConflictException({
          code: 'TRANG_THAI_KHONG_HOP_LE',
          message: 'Cấu hình vừa được đổi ở nơi khác, tải lại rồi thử tiếp',
        });
      }
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: enabled ? 'MO_CAU_HINH_DICH_VU' : 'KHOA_CAU_HINH_DICH_VU',
          targetType: 'SITTER',
          targetId: cauHinh.sitterId,
          targetCode: cauHinh.sitter.user.fullName,
          reason,
          oldValue: `${cauHinh.type}=${!enabled}`,
          newValue: `${cauHinh.type}=${enabled}`,
        },
        db,
      );
    });

    return { id, enabled };
  }
}
