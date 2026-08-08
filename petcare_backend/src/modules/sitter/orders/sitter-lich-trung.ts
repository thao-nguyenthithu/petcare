import { BookingStatus } from 'generated/prisma/enums';
import { MOT_PHUT_MS } from '../../../common/thoi-gian-vn';
import { LOAI_RA_APP } from '../../bookings/booking-enums';
import { demGiuaHaiDon } from '../../bookings/booking-time';
import { LoaiDichVuDto } from '../../bookings/dto/create-booking.dto';
import { demTrongGiu } from '../../bookings/slot-khoang-ban';

// Luật trùng lịch
export type DonTrenLich = {
  id: string;
  status: BookingStatus;
  createdAt: Date;
  paidAt: Date | null;
  scheduledAt: Date;
  scheduledEndAt: Date | null;
  durationMinutes: number | null;
  service: { type: string; durationMinutes: number | null };
  _count: { pets: number };
};

export function loaiCuaDon(don: DonTrenLich): LoaiDichVuDto {
  return LOAI_RA_APP[don.service.type as keyof typeof LOAI_RA_APP];
}

export function khoangChiem(don: DonTrenLich): { tu: number; den: number } {
  const phut = don.durationMinutes ?? don.service.durationMinutes ?? 60;
  const ketThuc =
    don.scheduledEndAt ??
    new Date(don.scheduledAt.getTime() + phut * MOT_PHUT_MS);
  const dem = demGiuaHaiDon(loaiCuaDon(don)) * MOT_PHUT_MS;
  return {
    tu: don.scheduledAt.getTime() - dem,
    den: ketThuc.getTime() + dem,
  };
}

export function chongGio(a: DonTrenLich, b: DonTrenLich): boolean {
  const x = khoangChiem(a);
  const y = khoangChiem(b);
  return x.tu < y.den && y.tu < x.den;
}

export function beDaChiemTheoDem(
  ky: DonTrenLich,
  daNhan: DonTrenLich[],
): number {
  const demCuaKy = demTrongGiu(ky);
  let caoNhat = 0;
  for (const dem of demCuaKy) {
    let so = 0;
    for (const don of daNhan) {
      if (demTrongGiu(don).includes(dem)) so += don._count.pets;
    }
    if (so > caoNhat) caoNhat = so;
  }
  return caoNhat;
}

export function vuotSucChua(
  ky: DonTrenLich,
  daNhan: DonTrenLich[],
  sucChua: number,
): boolean {
  return beDaChiemTheoDem(ky, daNhan) + ky._count.pets > sucChua;
}

export function hetCuaNhan(
  ung: DonTrenLich,
  vuaNhan: DonTrenLich,
  daNhan: DonTrenLich[],
  sucChuaTrongGiu: number,
): boolean {
  const loaiUng = loaiCuaDon(ung);
  const loaiVua = loaiCuaDon(vuaNhan);
  if (loaiUng === 'boarding') {
    return vuotSucChua(
      ung,
      daNhan.filter((d) => loaiCuaDon(d) === 'boarding'),
      sucChuaTrongGiu,
    );
  }
  if (loaiVua === 'boarding') return false;
  return daNhan.some((d) => loaiCuaDon(d) !== 'boarding' && chongGio(ung, d));
}
