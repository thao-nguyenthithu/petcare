import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  PenaltyKind,
  PenaltyStatus,
  SitterStatus,
} from '../../../../generated/prisma/enums';
import { gioVn, MOT_NGAY_MS, ngayThangVn } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { THANG_DEM_LAN_TAM_AN } from '../../bookings/sitter-penalty-rules';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { dangBiTamAn } from '../../sitter/public/sitter-public';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { DuyetHoSoDto } from './dto/loc-nguoi-cham.dto';

// Ba trạng thái đơn làm hồ sơ bị khoá thành đơn treo, giống luật khoá tài khoản
const TRANG_THAI_DANG_CHAY = [
  'CONFIRMED',
  'IN_PROGRESS',
  'AWAITING_OWNER_CONFIRM',
] as const;

@Injectable()
export class AdminSittersWriteService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
    private readonly phat: SitterPenaltyService,
    private readonly thongBao: NotificationsService,
  ) {}

  private loiVuaDoiNoiKhac() {
    return new ConflictException({
      code: 'TRANG_THAI_KHONG_HOP_LE',
      message: 'Hồ sơ vừa được đổi ở nơi khác, tải lại rồi thử tiếp',
    });
  }

  private async layHoSo(id: string) {
    const [ncc, donDangChay] = await Promise.all([
      this.prisma.sitter.findUnique({
        where: { id },
        select: {
          id: true,
          userId: true,
          legalName: true,
          status: true,
          hiddenUntil: true,
          hiddenCount: true,
          bannedAt: true,
        },
      }),
      this.prisma.booking.count({
        where: { sitterId: id, status: { in: [...TRANG_THAI_DANG_CHAY] } },
      }),
    ]);
    if (!ncc) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NCC',
        message: 'Không tìm thấy hồ sơ người chăm này',
      });
    }
    return { ncc, donDangChay };
  }

  async tamAn(id: string, days: number, reason: string, adminId: string) {
    const { ncc, donDangChay } = await this.layHoSo(id);
    if (ncc.bannedAt) {
      throw new BadRequestException({
        code: 'HO_SO_DA_KHOA_VINH_VIEN',
        message: 'Hồ sơ đã khoá vĩnh viễn, gỡ khoá trước rồi mới tạm ẩn được',
      });
    }
    if (dangBiTamAn(ncc.hiddenUntil)) {
      const den = ncc.hiddenUntil as Date;
      // Ẩn chồng lên lần đang chạy là đốt thêm một suất trong ngưỡng khoá hẳn
      throw new BadRequestException({
        code: 'HO_SO_DANG_BI_TAM_AN',
        message: `Hồ sơ đang tạm ẩn tới ${gioVn(den)} ngày ${ngayThangVn(den)}, chờ hết hạn rồi mới ẩn tiếp được`,
      });
    }

    // Dùng chung đường của thang tự động nên lần ẩn tay cũng tính vào luật khoá hẳn
    const ket = await this.prisma.$transaction(async (db) => {
      const ket = await this.phat.tamAn(id, Date.now(), reason, db, days);
      await this.nhatKy.lenhGhi({
        adminId,
        action: 'TAM_AN_HO_SO_NCC',
        targetType: 'SITTER',
        targetId: id,
        targetCode: ncc.legalName,
        reason,
        oldValue: `hiddenCount=${ncc.hiddenCount}`,
        newValue: `days=${days}|lanThu=${ket.hiddenCount}|donDangChay=${donDangChay}|khoaHan=${ket.khoa}`,
      });
      return ket;
    });

    await this.thongBao.tao({
      userId: ncc.userId,
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      title: ket.khoa ? 'Hồ sơ đã bị khoá' : 'Hồ sơ tạm bị ẩn khỏi tìm kiếm',
      body: ket.khoa
        ? `Hồ sơ của bạn đã bị khoá. Lý do: ${reason}`
        : `Hồ sơ của bạn tạm ẩn ${days} ngày nên không nhận được đơn mới. Các đơn đã nhận vẫn phải hoàn thành. Lý do: ${reason}`,
      urgent: true,
    });
    return {
      id,
      hiddenDays: ket.soNgay,
      hiddenCount: ket.hiddenCount,
      hiddenTimesInWindow: ket.soLanAnGanDay,
      banned: ket.khoa,
      runningBookingCount: donDangChay,
    };
  }

  async datKhoaVinhVien(
    id: string,
    banned: boolean,
    reason: string,
    adminId: string,
  ) {
    const { ncc, donDangChay } = await this.layHoSo(id);
    if (Boolean(ncc.bannedAt) === banned) {
      return { id, banned, runningBookingCount: donDangChay, waivedHides: 0 };
    }

    let mocDaMien = 0;
    if (banned) {
      await this.prisma.$transaction(async (db) => {
        // Kẹp mốc khoá cũ vào where, không thì hai lượt cùng lúc bắn hai lần tin cho người chăm
        const doi = await db.sitter.updateMany({
          where: { id, bannedAt: null },
          data: { bannedAt: new Date() },
        });
        if (doi.count === 0) throw this.loiVuaDoiNoiKhac();
        await this.nhatKy.lenhGhi(
          {
            adminId,
            action: 'KHOA_HO_SO_NCC',
            targetType: 'SITTER',
            targetId: id,
            targetCode: ncc.legalName,
            reason,
            oldValue: 'false',
            newValue: `true|donDangChay=${donDangChay}`,
          },
          db,
        );
      });
    } else {
      mocDaMien = await this.goKhoa(
        id,
        ncc.legalName,
        reason,
        adminId,
        donDangChay,
      );
    }

    await this.thongBao.tao({
      userId: ncc.userId,
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      title: banned ? 'Hồ sơ đã bị khoá' : 'Hồ sơ đã được mở lại',
      body: banned
        ? `Hồ sơ người chăm của bạn đã bị khoá nên không nhận đơn được nữa. Bạn vẫn đăng nhập và đặt dịch vụ như chủ nuôi bình thường. Lý do: ${reason}`
        : `Hồ sơ người chăm của bạn đã được mở lại và nhận đơn được ngay. Lý do: ${reason}`,
      urgent: true,
    });
    return {
      id,
      banned,
      runningBookingCount: donDangChay,
      waivedHides: mocDaMien,
    };
  }

  // Để nguyên mốc ẩn cũ thì lần tạm ẩn kế tiếp khoá lại tức thì (bộ luật mục 6)
  private goKhoa(
    id: string,
    legalName: string | null,
    reason: string,
    adminId: string,
    donDangChay: number,
  ) {
    const tuCuaSo = new Date(
      Date.now() - THANG_DEM_LAN_TAM_AN * 30 * MOT_NGAY_MS,
    );
    return this.prisma.$transaction(async (db) => {
      // Kẹp mốc khoá cũ vào where, không thì hai lượt gỡ cùng lúc miễn mốc ẩn hai lần
      const goi = await db.sitter.updateMany({
        where: { id, bannedAt: { not: null } },
        // Mở lại luôn cả tạm ẩn, không để người được gỡ vẫn biến mất khỏi tìm kiếm
        data: { bannedAt: null, hiddenUntil: null },
      });
      if (goi.count === 0) throw this.loiVuaDoiNoiKhac();
      const mien = await db.sitterPenalty.updateMany({
        where: {
          sitterId: id,
          kind: PenaltyKind.HIDE,
          status: { not: PenaltyStatus.WAIVED },
          createdAt: { gte: tuCuaSo },
        },
        data: { status: PenaltyStatus.WAIVED, reviewedAt: new Date() },
      });
      // Miễn một mốc mà vẫn tính nó khi chọn bậc ngày là mâu thuẫn (bộ luật mục 6)
      if (mien.count > 0) {
        // Đọc hiddenCount trong transaction, đọc ngoài thì lần ẩn chen vào bị ghi đè
        const truoc = await db.sitter.findUnique({
          where: { id },
          select: { hiddenCount: true },
        });
        await db.sitter.update({
          where: { id },
          // Đặt thẳng thay vì decrement: hồ sơ cũ có thể đếm nhiều hơn số mốc đã ghi
          data: {
            hiddenCount: Math.max(0, (truoc?.hiddenCount ?? 0) - mien.count),
          },
          select: { id: true },
        });
      }
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: 'GO_KHOA_HO_SO_NCC',
          targetType: 'SITTER',
          targetId: id,
          targetCode: legalName,
          reason,
          oldValue: 'true',
          newValue: `false|mienMocAn=${mien.count}|donDangChay=${donDangChay}`,
        },
        db,
      );
      return mien.count;
    });
  }

  // Giữ nguyên PENDING: người chăm sửa rồi gửi lại đúng lối nộp hồ sơ ban đầu
  async yeuCauBoSung(id: string, reason: string, adminId: string) {
    const { ncc } = await this.layHoSo(id);
    if (ncc.status !== SitterStatus.PENDING) {
      throw new BadRequestException({
        code: 'HO_SO_DA_XU_LY',
        message: 'Hồ sơ này đã được xử lý rồi',
      });
    }

    // Ghi nhật ký trước, tin tới tay mà không có dòng nhật ký là mất dấu vết
    await this.nhatKy.ghi({
      adminId,
      action: 'YEU_CAU_BO_SUNG_HO_SO_NCC',
      targetType: 'SITTER',
      targetId: id,
      targetCode: ncc.legalName,
      reason,
    });

    await this.thongBao.tao({
      userId: ncc.userId,
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      title: 'Hồ sơ cần bổ sung thêm',
      body: `Hồ sơ người chăm của bạn chưa đủ để duyệt. Cần bổ sung: ${reason}. Bạn sửa lại rồi gửi hồ sơ một lần nữa.`,
      urgent: true,
    });
    return { id };
  }

  async duyetHoSo(id: string, dto: DuyetHoSoDto, adminId: string) {
    const { ncc } = await this.layHoSo(id);
    const tuChoi = dto.status === 'REJECTED';
    if (tuChoi && !dto.reason) {
      throw new BadRequestException({
        code: 'THIEU_LY_DO_TU_CHOI',
        message: 'Từ chối hồ sơ thì phải ghi lý do',
      });
    }
    if (ncc.status !== SitterStatus.PENDING) {
      throw new BadRequestException({
        code: 'HO_SO_DA_XU_LY',
        message: 'Hồ sơ này đã được xử lý rồi',
      });
    }

    await this.prisma.$transaction(async (db) => {
      // Kẹp PENDING vào where, không thì hai lượt duyệt cùng lúc bắn hai lần tin cho người chăm
      const doi = await db.sitter.updateMany({
        where: { id, status: SitterStatus.PENDING },
        // onboardedAt là mốc người chăm tự bấm nhận đơn, lệnh duyệt không được đụng vào
        data: tuChoi
          ? { status: SitterStatus.REJECTED }
          : { status: SitterStatus.APPROVED, approvedAt: new Date() },
      });
      if (doi.count === 0) throw this.loiVuaDoiNoiKhac();
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: tuChoi ? 'TU_CHOI_HO_SO_NCC' : 'DUYET_HO_SO_NCC',
          targetType: 'SITTER',
          targetId: id,
          targetCode: ncc.legalName,
          reason: dto.reason ?? null,
          oldValue: ncc.status,
          newValue: dto.status,
        },
        db,
      );
    });

    await this.thongBao.tao({
      userId: ncc.userId,
      type: 'HO_SO',
      role: 'NGUOI_CHAM',
      title: tuChoi ? 'Hồ sơ chưa được duyệt' : 'Hồ sơ đã được duyệt',
      body: tuChoi
        ? `Hồ sơ người chăm của bạn chưa được duyệt. Lý do: ${dto.reason}`
        : 'Hồ sơ người chăm của bạn đã được duyệt. Bạn cấu hình dịch vụ và giá rồi bắt đầu nhận đơn được ngay.',
      urgent: true,
    });
    return { id, status: dto.status };
  }
}
