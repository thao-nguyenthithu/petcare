import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  MOT_PHUT_MS,
  khoaNgayVn,
  mocVn,
  soNgayLech,
} from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { BookingChatService } from '../messaging/booking-chat.service';
import { BookingNotifyService } from '../notifications/booking-notify.service';
import {
  phanChiaPhiHuy,
  phanTramNenTangCuaDon,
  phanTramPhiHuyCuaDon,
  phiHuyCuaDon,
  xetMienPhi,
} from './booking-cancel';
import { DEPART_WINDOW_MINUTES } from './booking-compensation';
import { LOAI_RA_APP, TRANG_THAI_AN, TRANG_THAI_HUY } from './booking-enums';
import { tinhKetThucSom } from './booking-pricing';
import { SitterScoreService } from '../search/sitter-score.service';
import { CancelBookingDto, LY_DO_CAN_MO_TA } from './dto/cancel-booking.dto';
import { EndEarlyDto } from './dto/end-early.dto';
import { donXetHuy, raChiTiet, soDem } from './owner-booking-detail.mapper';
import { AnhKyService } from '../media/anh-ky.service';
import { CHON, DonChiTiet, TRANG_THAI_HUY_DUOC } from './owner-booking-select';
import { PHAT_NCC_CHUA_TOI } from './sitter-penalty-rules';
import { SitterPenaltyService } from './sitter-penalty.service';

const GIO_BAO_TRUOC_KET_THUC_SOM = 1;

// Chi tiết một đơn phía chủ nuôi
@Injectable()
export class OwnerBookingDetailService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notify: BookingNotifyService,
    private readonly chat: BookingChatService,
    private readonly penalty: SitterPenaltyService,
    private readonly diem: SitterScoreService,
    private readonly kyAnh: AnhKyService,
  ) {}

  private async raChiTietDaKy(d: DonChiTiet) {
    return raChiTiet(d, await this.kyAnh.kyLo(d.noShowProofUrls));
  }

  async chiTiet(userId: string, id: string) {
    return this.raChiTietDaKy(await this.timCuaToi(userId, id));
  }

  async huy(userId: string, id: string, dto: CancelBookingDto) {
    if (dto.reason === LY_DO_CAN_MO_TA && !dto.note) {
      throw new BadRequestException({
        code: 'THIEU_MO_TA_LY_DO',
        message: 'Chọn lý do khác thì cần mô tả thêm',
      });
    }
    const don = await this.timCuaToi(userId, id);
    if (!TRANG_THAI_HUY_DUOC.includes(don.status)) {
      throw new ConflictException({
        code: 'DON_KHONG_HUY_DUOC',
        message: TRANG_THAI_HUY.includes(don.status)
          ? 'Đơn này đã huỷ rồi'
          : 'Đơn đã bắt đầu nên không huỷ được nữa, dùng Báo sự cố',
      });
    }
    if (don.departedAt) {
      throw new ConflictException({
        code: 'DA_XUAT_PHAT_KHONG_HUY_DUOC',
        message: 'Người chăm đã lên đường nên đơn không huỷ được nữa',
      });
    }

    const bayGio = Date.now();
    const xet = xetMienPhi(donXetHuy(don), bayGio);
    const phiHuy = xet.mienPhi
      ? 0
      : phiHuyCuaDon(
          LOAI_RA_APP[don.service.type],
          don.totalPrice ?? 0,
          soDem(don),
          phanTramPhiHuyCuaDon(don.cancelFeePercent),
          don.scheduledAt,
          bayGio,
        );
    const nccNhanPhiHuy = phanChiaPhiHuy(
      phiHuy,
      phanTramNenTangCuaDon(don.platformFeePercent),
    );
    const daHuy = await this.prisma.$transaction(async (tx) => {
      const kq = await tx.booking.update({
        where: { id: don.id },
        data: {
          status: xet.doNguoiCham
            ? 'CANCELLED_BY_SITTER'
            : 'CANCELLED_BY_OWNER',
          cancelledAt: new Date(bayGio),
          cancellationReason: dto.reason,
          cancellationNote: dto.note ?? null,
          cancellationFee: phiHuy,
          platformFee: nccNhanPhiHuy.nenTang,
        },
        select: CHON,
      });
      await tx.payment.updateMany({
        where: { bookingId: don.id, status: 'HELD' },
        data: { status: 'REFUNDING' },
      });
      if (xet.doNguoiCham && don.sitter?.id) {
        await this.penalty.ghiPhat(
          don.sitter.id,
          don.id,
          PHAT_NCC_CHUA_TOI,
          dto.reason,
          bayGio,
          tx,
        );
      }
      return kq;
    });
    await this.notify.chuNuoiHuyDon(don.id);
    await this.chat.chuNuoiHuyDon(
      don.id,
      phiHuy || null,
      nccNhanPhiHuy.nccNhan,
    );
    return this.raChiTietDaKy(daHuy);
  }

  async xacNhanHoanThanh(userId: string, id: string) {
    const don = await this.timCuaToi(userId, id);
    if (don.status !== 'AWAITING_OWNER_CONFIRM') {
      throw new ConflictException({
        code: 'TRANG_THAI_KHONG_HOP_LE',
        message: 'Đơn không ở bước chờ bạn xác nhận',
      });
    }
    const luc = new Date();
    const ketQua = await this.prisma.booking.updateMany({
      where: { id: don.id, status: 'AWAITING_OWNER_CONFIRM' },
      data: { status: 'COMPLETED', completedAt: luc },
    });
    if (ketQua.count > 0 && don.sitter?.id) {
      await this.diem.tinhLai(don.sitter.id);
    }
    return this.raChiTietDaKy(await this.timCuaToi(userId, id));
  }

  async xuatPhat(userId: string, id: string) {
    const don = await this.timCuaToi(userId, id);
    if (LOAI_RA_APP[don.service.type] !== 'boarding') {
      throw new ConflictException({
        code: 'SAI_LOAI_DICH_VU',
        message: 'Chỉ đơn trông giữ mới có nút xuất phát của chủ nuôi',
      });
    }
    const donVe = don.status === 'IN_PROGRESS';
    if (!donVe && don.status !== 'CONFIRMED') {
      throw new ConflictException({
        code: 'TRANG_THAI_KHONG_HOP_LE',
        message: 'Đơn không còn ở bước làm được việc này',
      });
    }
    const moc = donVe ? don.scheduledEndAt : don.scheduledAt;
    if (!moc) {
      throw new ConflictException({
        code: 'THIEU_MOC_GIO',
        message: 'Đơn chưa có mốc giờ để mở nút xuất phát',
      });
    }
    if (donVe ? don.ownerReturnDepartedAt : don.ownerDepartedAt) {
      throw new ConflictException({
        code: 'DA_XUAT_PHAT',
        message: 'Bạn đã bấm xuất phát rồi',
      });
    }
    const moLuc = moc.getTime() - DEPART_WINDOW_MINUTES * MOT_PHUT_MS;
    if (Date.now() < moLuc) {
      throw new ConflictException({
        code: 'CHUA_TOI_GIO_XUAT_PHAT',
        message: `Nút xuất phát mở trước giờ hẹn ${DEPART_WINDOW_MINUTES / 60} giờ`,
      });
    }
    const luc = new Date();
    await this.prisma.booking.update({
      where: { id: don.id },
      data: donVe
        ? { ownerReturnDepartedAt: luc }
        : { ownerDepartedAt: luc, departedAt: luc },
    });
    await this.chat.chuNuoiDaXuatPhat(don.id, donVe);
    return { id: don.id, departedAt: luc, chieuDonVe: donVe };
  }

  async ketThucSom(userId: string, id: string, dto: EndEarlyDto) {
    const don = await this.timCuaToi(userId, id);
    if (LOAI_RA_APP[don.service.type] !== 'boarding') {
      throw new ConflictException({
        code: 'SAI_LOAI_DICH_VU',
        message: 'Chỉ kỳ trông giữ mới kết thúc sớm được',
      });
    }
    if (don.status !== 'CONFIRMED' && don.status !== 'IN_PROGRESS') {
      throw new ConflictException({
        code: 'TRANG_THAI_KHONG_HOP_LE',
        message: 'Đơn không còn ở bước kết thúc sớm được',
      });
    }
    const bayGio = Date.now();
    const traMoi = mocVn(dto.endDate, dto.endTime);
    if (traMoi.getTime() < bayGio + GIO_BAO_TRUOC_KET_THUC_SOM * 3_600_000) {
      throw new BadRequestException({
        code: 'BAO_QUA_GAP',
        message: `Giờ trả mới phải cách bây giờ ít nhất ${GIO_BAO_TRUOC_KET_THUC_SOM} giờ`,
      });
    }
    const tongDem = soDem(don);
    const demDaO = soNgayLech(khoaNgayVn(don.scheduledAt), khoaNgayVn(traMoi));
    if (demDaO < 1 || demDaO >= tongDem) {
      throw new BadRequestException({
        code: 'NGAY_TRA_KHONG_HOP_LE',
        message: 'Ngày trả mới phải nằm giữa ngày nhận và ngày trả đã chốt',
      });
    }
    const tien = tinhKetThucSom(
      don.totalPrice ?? 0,
      tongDem,
      phanTramPhiHuyCuaDon(don.cancelFeePercent),
      don.scheduledAt,
      demDaO,
      bayGio,
    );
    const daSua = await this.prisma.booking.update({
      where: { id: don.id },
      data: {
        scheduledEndAt: traMoi,
        cancellationFee: tien.chuNuoiTra,
        platformFee: phanChiaPhiHuy(
          tien.chuNuoiTra,
          phanTramNenTangCuaDon(don.platformFeePercent),
        ).nenTang,
        priceBreakdown: {
          ...(don.priceBreakdown as object),
          nights: demDaO,
          endedEarly: { demBiCat: tien.C, demChiuPhi: tien.K },
        },
      },
      select: CHON,
    });
    await this.notify.chuNuoiKetThucSom(don.id, tien.duocHoan);
    await this.chat.chuNuoiKetThucSom(don.id, demDaO, tien.duocHoan);
    return {
      ...(await this.raChiTietDaKy(daSua)),
      ketThucSom: {
        demDaO: tien.O,
        demBiCat: tien.C,
        demChiuPhi: tien.K,
        chuNuoiTra: tien.chuNuoiTra,
        duocHoan: tien.duocHoan,
      },
    };
  }

  private async timCuaToi(userId: string, id: string) {
    const don = await this.prisma.booking.findFirst({
      where: { id, ownerId: userId, status: { notIn: TRANG_THAI_AN } },
      select: CHON,
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }
    return don;
  }
}
