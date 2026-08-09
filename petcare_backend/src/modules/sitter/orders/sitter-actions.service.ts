import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { gioVn, MOT_PHUT_MS, ngayThangVn } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import {
  DEPART_WINDOW_MINUTES,
  ARRIVE_GEOFENCE_METERS,
} from '../../bookings/booking-compensation';
import { kiemTraChuyen } from '../../bookings/booking-state';
import { BookingChatService } from '../../messaging/booking-chat.service';
import { BookingNotifyService } from '../../notifications/booking-notify.service';
import {
  ArriveDto,
  AcceptBookingDto,
  LateReportDto,
  RejectBookingDto,
} from './dto/sitter-order.dto';
import {
  batBuocMoTa,
  chuaCoMoc,
  hanNhanDon,
  loaiDichVu,
  metToiDiemHen,
  phaiDangO,
  SitterOrderStore,
} from './sitter-order-store.service';
import { KHONG_TINH_LOI } from '../../bookings/sitter-penalty-rules';
import { dangBiTamAn } from '../public/sitter-public';
import { SitterLichService } from './sitter-lich.service';

@Injectable()
export class SitterActionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly store: SitterOrderStore,
    private readonly notify: BookingNotifyService,
    private readonly chat: BookingChatService,
    private readonly lich: SitterLichService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  async nhanDon(userId: string, id: string, dto: AcceptBookingDto) {
    const { ncc, don } = await this.store.timDon(userId, id);
    kiemTraChuyen(don.status, 'CONFIRMED');
    const bayGio = Date.now();
    if (dangBiTamAn(ncc.hiddenUntil, new Date(bayGio))) {
      const den = ncc.hiddenUntil!;
      throw new ForbiddenException({
        code: 'HO_SO_DANG_BI_TAM_AN',
        message: `Hồ sơ của bạn đang tạm ẩn tới ${gioVn(den)} ngày ${ngayThangVn(den)}, chưa nhận được đơn mới`,
      });
    }
    if (bayGio > hanNhanDon(don).getTime()) {
      throw new ConflictException({
        code: 'QUA_HAN_NHAN_DON',
        message: 'Đơn đã quá hạn nhận, chủ nuôi được hoàn tiền',
      });
    }
    if (loaiDichVu(don) === 'walking' && dto.safetyCommitted !== true) {
      throw new BadRequestException({
        code: 'THIEU_CAM_KET_DUNG_CU',
        message: 'Cần cam kết giữ rọ mõm và dây xích cho các bé',
      });
    }
    const cungLich = await this.lich.donCungLich(don);
    await this.lich.chanTrungLich(don, cungLich.daNhan);
    const luc = new Date(bayGio);
    await this.prisma.booking.update({
      where: { id: don.id },
      data: { status: 'CONFIRMED', acceptedAt: luc },
    });
    await this.notify.daNhanDon(don.id);
    await this.chat.daNhanDon(don.id, luc);
    await this.lich.donDepDonChoChet(don, cungLich.dangCho);
    return { id: don.id, status: 'confirmed' };
  }

  async tuChoi(userId: string, id: string, dto: RejectBookingDto) {
    const { don } = await this.store.timDon(userId, id);
    kiemTraChuyen(don.status, 'CANCELLED_BY_SITTER');
    if (don.status !== 'PENDING') {
      throw new ConflictException({
        code: 'DON_DA_NHAN_KHONG_TU_CHOI_DUOC',
        message: 'Đơn đã nhận rồi, dùng Huỷ đơn thay vì từ chối',
      });
    }
    batBuocMoTa(dto.reason === 'khac', dto.note);
    await this.store.khepDon(don.id, {
      trangThai: 'CANCELLED_BY_SITTER',
      lyDo: dto.reason,
      moTa: dto.note,
      chuNuoiChiu: 0,
      nccNhan: 0,
      tienDi: 'hoanNgay',
    });
    await this.notify.tuChoiDon(don.id);
    return { id: don.id, status: 'cancelledBySitter' };
  }

  async xuatPhat(userId: string, id: string) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    chuaCoMoc(don.departedAt, 'DA_XUAT_PHAT', 'Bạn đã bấm xuất phát rồi');
    const moLuc =
      don.scheduledAt.getTime() - DEPART_WINDOW_MINUTES * MOT_PHUT_MS;
    if (Date.now() < moLuc) {
      throw new ConflictException({
        code: 'CHUA_TOI_GIO_XUAT_PHAT',
        message: `Nút xuất phát mở trước giờ hẹn ${DEPART_WINDOW_MINUTES} phút`,
      });
    }
    const luc = new Date();
    await this.prisma.booking.update({
      where: { id: don.id },
      data: { departedAt: luc },
    });
    await this.notify.daXuatPhat(don.id);
    await this.chat.daXuatPhat(don.id, luc);
    return { id: don.id, departedAt: luc };
  }

  async daToi(userId: string, id: string, dto: ArriveDto) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    if (!don.departedAt) {
      throw new ConflictException({
        code: 'CHUA_XUAT_PHAT',
        message: 'Cần bấm xuất phát trước khi báo đã tới',
      });
    }
    chuaCoMoc(don.arrivedAt, 'DA_TOI_ROI', 'Bạn đã báo tới nơi rồi');
    const met = metToiDiemHen(don, dto.lat, dto.lng);
    // Công tắc màn 15, tắt thì vẫn ghi khoảng cách để về sau soát lại (bộ luật mục 15)
    if (
      this.thamSo.batGeofence() &&
      (met === null || met > ARRIVE_GEOFENCE_METERS)
    ) {
      throw new ConflictException({
        code: 'NGOAI_VUNG_DIEM_DON',
        message: `Bạn cần vào trong ${ARRIVE_GEOFENCE_METERS} m quanh điểm hẹn`,
      });
    }
    const luc = new Date();
    const saiLech = met === null ? null : Math.round(met);
    await this.prisma.booking.update({
      where: { id: don.id },
      data: { arrivedAt: luc, arriveDistanceM: saiLech },
    });
    await this.notify.daToiNoi(don.id);
    await this.chat.daToiNoi(don.id, saiLech, luc);
    return { id: don.id, arrivedAt: luc, distanceMeters: saiLech };
  }

  async baoMuon(userId: string, id: string, dto: LateReportDto) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    chuaCoMoc(don.lateReportedAt, 'DA_BAO_MUON', 'Đơn này đã báo muộn rồi');
    const luc = new Date();
    const eta = new Date(don.scheduledAt.getTime() + dto.minutes * MOT_PHUT_MS);
    await this.prisma.booking.update({
      where: { id: don.id },
      data: { lateMinutes: dto.minutes, etaAt: eta, lateReportedAt: luc },
    });
    await this.chat.baoMuon(don.id, dto.minutes, eta);
    return { id: don.id, minutes: dto.minutes, etaAt: eta, reportedAt: luc };
  }

  static readonly khongTinhLoi = KHONG_TINH_LOI;
}
