import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import {
  PaymentStatus,
  PenaltyKind,
  ReportStatus,
} from '../../../../generated/prisma/enums';
import { tienVn as tien } from '../../../common/dinh-dang-tien';
import { PrismaService } from '../../../prisma/prisma.service';
import {
  phanChiaPhiHuy,
  phanTramNenTangCuaDon,
} from '../../bookings/booking-cancel';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';
import { NotificationsService } from '../../notifications/notifications.service';
import { WalletLedgerService } from '../../wallet/wallet-ledger.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { KetLuanKhieuNaiDto } from './dto/loc-khieu-nai.dto';

type DonKetLuan = {
  id: string;
  sitterId: string;
  totalPrice: number | null;
  platformFeePercent: number | null;
};

type PhanChia = { nccNhan: number; nenTang: number };

@Injectable()
export class AdminDisputeResolveService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
    private readonly phat: SitterPenaltyService,
    private readonly thongBao: NotificationsService,
    private readonly soVi: WalletLedgerService,
  ) {}

  async ketLuan(code: string, dto: KetLuanKhieuNaiDto, adminId: string) {
    const [hs, khoanGiu] = await Promise.all([
      this.prisma.violationReport.findUnique({
        where: { code },
        select: {
          id: true,
          code: true,
          status: true,
          booking: {
            select: {
              id: true,
              code: true,
              ownerId: true,
              totalPrice: true,
              platformFeePercent: true,
              sitterId: true,
              sitter: { select: { userId: true } },
            },
          },
        },
      }),
      // Lọc thẳng qua quan hệ để nhánh bác khiếu nại không tốn thêm lượt đi về nào
      dto.refundAmount > 0
        ? this.prisma.payment.findFirst({
            where: {
              status: PaymentStatus.HELD,
              booking: { reports: { some: { code } } },
            },
            orderBy: { createdAt: 'desc' },
            select: { id: true },
          })
        : null,
    ]);
    if (!hs) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_KHIEU_NAI',
        message: 'Không tìm thấy hồ sơ khiếu nại',
      });
    }
    if (hs.status === ReportStatus.RESOLVED) throw this.loiDaKetLuan();
    // Đơn chưa chốt giá thì trần là 0, hoàn tiền cho nó là hoàn từ hư không
    if (dto.refundAmount > (hs.booking.totalPrice ?? 0)) {
      throw new BadRequestException({
        code: 'VUOT_GIA_TRI_DON',
        message: 'Khoản hoàn không được vượt giá trị đơn',
      });
    }

    const chia = this.chiaTien(hs.booking, dto.refundAmount);
    if (chia && !khoanGiu) throw this.loiHetKhoanGiu();

    const bayGio = Date.now();
    const chotLuc = new Date(bayGio);
    await this.prisma.$transaction(async (db) => {
      // Kẹp trạng thái cũ vào where, không thì hai lượt cùng lúc phạt người chăm hai lần
      const doi = await db.violationReport.updateMany({
        where: { id: hs.id, status: { not: ReportStatus.RESOLVED } },
        data: {
          status: ReportStatus.RESOLVED,
          resolution: dto.resolution,
          resolutionReason: dto.resolutionReason,
          refundAmount: dto.refundAmount,
          resolvedAt: chotLuc,
        },
      });
      if (doi.count === 0) throw this.loiDaKetLuan();
      if (chia && khoanGiu) {
        await this.chotTien(db, hs.booking, khoanGiu.id, chia, hs.code);
      }
      const hienTuong = await this.ghiPhat(db, hs.booking, dto, bayGio);
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: 'KET_LUAN_KHIEU_NAI',
          targetType: 'DISPUTE',
          targetId: hs.id,
          targetCode: hs.code,
          reason: dto.resolutionReason,
          oldValue: hs.status,
          newValue: `hoan=${dto.refundAmount}|nccNhan=${chia?.nccNhan ?? 'GIU'}|phat=${dto.penalty ?? 'NONE'}${hienTuong}`,
        },
        db,
      );
    });

    if (dto.notifyBoth) await this.bao(hs.booking, dto);
    return {
      code: hs.code,
      status: ReportStatus.RESOLVED,
      refundAmount: dto.refundAmount,
      resolvedAt: chotLuc,
    };
  }

  private loiDaKetLuan() {
    return new ConflictException({
      code: 'HO_SO_DA_KET_LUAN',
      message: 'Hồ sơ này đã có kết luận, kết luận không lùi được',
    });
  }

  private loiHetKhoanGiu() {
    return new ConflictException({
      code: 'KHONG_CON_KHOAN_GIU',
      message:
        'Đơn không còn khoản tiền nào đang giữ, không hoàn cho chủ nuôi được',
    });
  }

  // Phần chủ nuôi còn phải chịu đi qua phễu phí nền tảng như mọi nhánh khép đơn (bộ luật mục 2)
  private chiaTien(don: DonKetLuan, hoan: number): PhanChia | null {
    if (hoan <= 0) return null;
    return phanChiaPhiHuy(
      (don.totalPrice ?? 0) - hoan,
      phanTramNenTangCuaDon(don.platformFeePercent),
    );
  }

  // Tiền chỉ rời chỗ giữ khi có kết luận, và rời cùng transaction với kết luận (bộ luật mục 7)
  private async chotTien(
    db: Prisma.TransactionClient,
    don: DonKetLuan,
    khoanGiuId: string,
    chia: PhanChia,
    maHoSo: string,
  ) {
    // Kẹp HELD vào where để hai lượt kết luận cùng lúc không ghi ví hai lần
    const doi = await db.payment.updateMany({
      where: { id: khoanGiuId, status: PaymentStatus.HELD },
      data: { status: PaymentStatus.REFUNDING },
    });
    if (doi.count === 0) throw this.loiHetKhoanGiu();
    // Đóng băng phần chia mới, không thì mọi màn tiền vẫn kể theo số trước khiếu nại
    await db.booking.update({
      where: { id: don.id },
      data: { sitterPayout: chia.nccNhan, platformFee: chia.nenTang },
    });
    if (chia.nccNhan <= 0) return;
    await this.soVi.ghi(
      don.sitterId,
      {
        loai: 'TIEN_VAO',
        tieuDe: `Kết luận khiếu nại ${maHoSo}`,
        soTien: chia.nccNhan,
        bookingId: don.id,
        disputeCode: maHoSo,
      },
      db,
    );
  }

  // Số ngày tạm ẩn đi theo bậc tái phạm, không ép số (bộ luật mục 6)
  private async ghiPhat(
    db: Prisma.TransactionClient,
    don: { id: string; sitterId: string },
    dto: KetLuanKhieuNaiDto,
    bayGio: number,
  ): Promise<string> {
    if (!dto.penalty) return '';
    if (dto.penalty === PenaltyKind.HIDE) {
      const ket = await this.phat.tamAn(
        don.sitterId,
        bayGio,
        dto.resolutionReason,
        db,
      );
      return `|anNgay=${ket.soNgay}|khoaHan=${ket.khoa}`;
    }
    const ket = await this.phat.ghiPhat(
      don.sitterId,
      don.id,
      {
        tinhTyLeHuy: dto.penalty === PenaltyKind.CANCEL_RATE,
        canhCao: dto.penalty === PenaltyKind.WARNING,
        treoChoSoat: false,
      },
      dto.resolutionReason,
      bayGio,
      db,
    );
    // Cảnh cáo thứ tư tự kéo theo tạm ẩn, nhật ký phải ghi lại hệ quả đó
    if (!ket.tamAn) return '';
    return `|tuDongAn=${'soNgayAn' in ket ? ket.soNgayAn : 0}|khoaHan=${ket.khoa}`;
  }

  // Người chăm cũng đọc kết luận nên câu chữ phải nói được cả khi hoàn 0 đồng
  private async bao(
    don: {
      id: string;
      code: string;
      ownerId: string;
      sitter: { userId: string };
    },
    dto: KetLuanKhieuNaiDto,
  ) {
    const coHoan = dto.refundAmount > 0;
    const tin = {
      type: 'KHIEU_NAI' as const,
      titleKey: 'tbKhieuNaiKetLuanTieuDe' as const,
      bodyKey: coHoan
        ? ('tbKhieuNaiCoHoanNoiDung' as const)
        : ('tbKhieuNaiKhongHoanNoiDung' as const),
      params: {
        code: don.code,
        ketLuan: dto.resolution,
        lyDo: dto.resolutionReason,
        soTien: tien(dto.refundAmount),
      },
      targetId: don.id,
      urgent: true,
    };
    await Promise.all([
      this.thongBao.tao({ ...tin, userId: don.ownerId, role: 'CHU_NUOI' }),
      this.thongBao.tao({
        ...tin,
        userId: don.sitter.userId,
        role: 'NGUOI_CHAM',
      }),
    ]);
  }
}
