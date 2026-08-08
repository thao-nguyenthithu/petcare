import { ConflictException, Injectable } from '@nestjs/common';
import { MOT_PHUT_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import {
  phanChiaPhiHuy,
  phanTramNenTangCuaDon,
  phanTramPhiHuyCuaDon,
  phiHuyCuaDon,
} from '../../bookings/booking-cancel';
import {
  GEAR_WAIT,
  HAN_PHAN_DOI_HOURS,
} from '../../bookings/booking-compensation';
import { LY_DO_THIEU_DUNG_CU } from '../../bookings/booking-enums';
import { kiemTraChuyen } from '../../bookings/booking-state';
import { mucPhat } from '../../bookings/sitter-penalty-rules';
import { type UploadedImage } from '../../media/image-upload';
import { BookingChatService } from '../../messaging/booking-chat.service';
import { BookingNotifyService } from '../../notifications/booking-notify.service';
import { SitterCancelDto } from './dto/sitter-order.dto';
import {
  batBuocMoTa,
  chiDichVu,
  chuaCoMoc,
  loaiDichVu,
  phaiChoDu,
  phaiCoAnhBangChung,
  phaiDangO,
  soDem,
  SitterOrderStore,
} from './sitter-order-store.service';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';

@Injectable()
export class SitterCancelService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly store: SitterOrderStore,
    private readonly penalty: SitterPenaltyService,
    private readonly notify: BookingNotifyService,
    private readonly chat: BookingChatService,
  ) {}

  async baoThieuDungCu(userId: string, id: string, files: UploadedImage[]) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    chiDichVu(don, 'walking');
    if (!don.arrivedAt) {
      throw new ConflictException({
        code: 'CHUA_TOI_DIEM_DON',
        message: 'Cần báo đã tới điểm đón trước',
      });
    }
    chuaCoMoc(don.gearReportedAt, 'DA_BAO_THIEU', 'Bạn đã báo thiếu rồi');
    phaiCoAnhBangChung(files);
    const anh = await this.store.dayAnhLenStorage(don.id, files);
    const luc = new Date();
    await this.prisma.booking.update({
      where: { id: don.id },
      data: { gearReportedAt: luc, noShowProofUrls: anh },
    });
    await this.chat.baoThieuDungCu(don.id, GEAR_WAIT);
    return {
      id: don.id,
      reportedAt: luc,
      waitUntil: new Date(luc.getTime() + GEAR_WAIT * MOT_PHUT_MS),
      photos: await this.store.kyAnhMang(anh),
    };
  }

  async huyViThieuDungCu(userId: string, id: string) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    chiDichVu(don, 'walking');
    if (!don.gearReportedAt) {
      throw new ConflictException({
        code: 'CHUA_BAO_THIEU_DUNG_CU',
        message: 'Cần bấm báo thiếu dụng cụ và chờ hết ân hạn trước',
      });
    }
    const hetCho = don.gearReportedAt.getTime() + GEAR_WAIT * MOT_PHUT_MS;
    if (Date.now() < hetCho) {
      throw new ConflictException({
        code: 'CHUA_HET_AN_HAN_DUNG_CU',
        message: `Còn trong ${GEAR_WAIT} phút chờ chủ nuôi mang dụng cụ ra`,
      });
    }
    const tong = don.totalPrice ?? 0;
    const chuNuoiChiu = phiHuyCuaDon(
      'walking',
      tong,
      0,
      phanTramPhiHuyCuaDon(don.cancelFeePercent),
      don.scheduledAt,
    );
    const nccNhan = phanChiaPhiHuy(
      chuNuoiChiu,
      phanTramNenTangCuaDon(don.platformFeePercent),
    ).nccNhan;
    await this.store.khepDon(don.id, {
      trangThai: 'CANCELLED_BY_SITTER',
      lyDo: LY_DO_THIEU_DUNG_CU,
      chuNuoiChiu,
      nccNhan,
      tienDi: 'giuChoPhanDoi',
    });
    const hoanLai = tong - chuNuoiChiu;
    await this.notify.huyViThieuDungCu(don.id, chuNuoiChiu, nccNhan, hoanLai);
    await this.chat.huyViThieuDungCu(don.id, chuNuoiChiu, nccNhan, hoanLai);
    return { id: don.id, status: 'cancelledBySitter', sitterPayout: nccNhan };
  }

  async baoVangMat(userId: string, id: string, files: UploadedImage[]) {
    const { don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    kiemTraChuyen(don.status, 'CANCELLED_NO_SHOW');
    phaiCoAnhBangChung(files);
    const loai = loaiDichVu(don);
    const bayGio = Date.now();
    if (loai === 'boarding') {
      if (don.ownerArrivedAt) {
        throw new ConflictException({
          code: 'CHU_NUOI_DA_TOI',
          message: 'Chủ nuôi đã tới nơi nên không báo vắng mặt được',
        });
      }
    } else if (!don.arrivedAt) {
      throw new ConflictException({
        code: 'CHUA_TOI_DIEM_DON',
        message: 'Cần báo đã tới điểm đón trước khi báo chủ nuôi vắng mặt',
      });
    }
    phaiChoDu(don.scheduledAt.getTime(), bayGio);

    const tong = don.totalPrice ?? 0;
    const chuNuoiChiu = phiHuyCuaDon(
      loai,
      tong,
      soDem(don),
      phanTramPhiHuyCuaDon(don.cancelFeePercent),
      don.scheduledAt,
      bayGio,
    );
    const nccNhan = phanChiaPhiHuy(
      chuNuoiChiu,
      phanTramNenTangCuaDon(don.platformFeePercent),
    ).nccNhan;
    const anh = await this.store.dayAnhLenStorage(don.id, files);
    await this.prisma.booking.update({
      where: { id: don.id },
      data: { noShowProofUrls: anh },
    });
    await this.store.khepDon(don.id, {
      trangThai: 'CANCELLED_NO_SHOW',
      lyDo: 'chuNuoiVangMat',
      chuNuoiChiu,
      nccNhan,
      tienDi: 'giuChoPhanDoi',
    });
    await this.chat.baoVangMat(don.id, nccNhan, HAN_PHAN_DOI_HOURS);
    await this.notify.chuNuoiVangMat(
      don.id,
      chuNuoiChiu,
      nccNhan,
      HAN_PHAN_DOI_HOURS,
    );
    return {
      id: don.id,
      status: 'cancelledNoShow',
      ownerFee: chuNuoiChiu,
      sitterPayout: nccNhan,
      noShowProofUrls: await this.store.kyAnhMang(anh),
    };
  }

  async huyDon(userId: string, id: string, dto: SitterCancelDto) {
    const { ncc, don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    if (don.departedAt) {
      throw new ConflictException({
        code: 'DA_XUAT_PHAT_KHONG_HUY_DUOC',
        message:
          'Bạn đã lên đường nên không huỷ thường được, dùng Không thể tiếp nhận',
      });
    }
    batBuocMoTa(dto.reason === 'khac', dto.note);
    const bayGio = Date.now();
    const muc = mucPhat('huyChuaXuatPhat');
    const ket = await this.prisma.$transaction(async (tx) => {
      await this.store.khepDon(
        don.id,
        {
          trangThai: 'CANCELLED_BY_SITTER',
          lyDo: dto.reason,
          moTa: dto.note,
          chuNuoiChiu: 0,
          nccNhan: 0,
          tienDi: 'hoanNgay',
        },
        tx,
      );
      return this.penalty.ghiPhat(ncc.id, don.id, muc, dto.reason, bayGio, tx);
    });
    await this.notify.nccHuyDon(don.id);
    await this.chat.nccHuyDon(don.id);
    return { id: don.id, status: 'cancelledBySitter', ...muc, ...ket };
  }

  async khongTheTiepNhan(
    userId: string,
    id: string,
    dto: SitterCancelDto,
    files: UploadedImage[],
  ) {
    const { ncc, don } = await this.store.timDon(userId, id);
    phaiDangO(don, ['CONFIRMED']);
    if (!don.departedAt) {
      throw new ConflictException({
        code: 'CHUA_XUAT_PHAT',
        message: 'Chưa lên đường thì dùng Huỷ đơn',
      });
    }
    batBuocMoTa(true, dto.note);
    phaiCoAnhBangChung(files);
    const bayGio = Date.now();
    const muc = mucPhat('daXuatPhat');
    const anh = await this.store.dayAnhLenStorage(don.id, files);
    const ket = await this.prisma.$transaction(async (tx) => {
      await tx.booking.update({
        where: { id: don.id },
        data: { noShowProofUrls: anh },
      });
      await this.store.khepDon(
        don.id,
        {
          trangThai: 'CANCELLED_BY_SITTER',
          lyDo: dto.reason,
          moTa: dto.note,
          chuNuoiChiu: 0,
          nccNhan: 0,
          tienDi: 'hoanNgay',
        },
        tx,
      );
      return this.penalty.ghiPhat(ncc.id, don.id, muc, dto.reason, bayGio, tx);
    });
    await this.notify.nccKhongTheTiepNhan(don.id);
    await this.chat.nccKhongTheTiepNhan(don.id, muc.treoChoSoat);
    return {
      id: don.id,
      status: 'cancelledBySitter',
      choSoat: muc.treoChoSoat,
      ...ket,
    };
  }
}
