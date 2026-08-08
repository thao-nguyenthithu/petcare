import { BookingStatus } from 'generated/prisma/enums';
import {
  gioVn,
  khoaNgayVn,
  phutTrongNgay,
  soNgayLech,
} from '../../common/thoi-gian-vn';
import { MA_TRANG_THAI } from './booking-enums';
import { LoaiDichVuDto } from './dto/create-booking.dto';

export const MAX_ADVANCE_DAYS = 60;
export const MIN_LEAD_MINUTES = 120;
export const SLOT_STEP_MINUTES = 30;
export const DEM_WALKING_MINUTES = 15;
export const DEM_TAN_NOI_MINUTES = 30;

export function demGiuaHaiDon(loai: LoaiDichVuDto): number {
  return loai === 'walking' ? DEM_WALKING_MINUTES : DEM_TAN_NOI_MINUTES;
}

export const TRAN_DEM_MOT_DON = 30;

export function hanNhanDonPhut(phutToiGioHen: number): number {
  const gio = phutToiGioHen / 60;
  if (gio <= 6) return 30;
  if (gio <= 24) return 120;
  if (gio <= 24 * 7) return 12 * 60;
  return 24 * 60;
}

export const PHUT_GIU_CHO_TRA_TIEN = 10;

export function mocGuiNguoiCham(don: {
  paidAt: Date | null;
  createdAt: Date;
}): Date {
  return don.paidAt ?? don.createdAt;
}

export function hanGiuCho(taoLuc: Date): Date {
  return new Date(taoLuc.getTime() + PHUT_GIU_CHO_TRA_TIEN * 60000);
}

export function hanNhanDonCua(don: {
  scheduledAt: Date;
  createdAt: Date;
  paidAt: Date | null;
}): Date {
  const guiLuc = mocGuiNguoiCham(don);
  const toiGioHen = (don.scheduledAt.getTime() - guiLuc.getTime()) / 60000;
  return new Date(guiLuc.getTime() + hanNhanDonPhut(toiGioHen) * 60000);
}

export function maTrangThaiHieuLuc(d: {
  status: BookingStatus;
  scheduledAt: Date;
  createdAt: Date;
  paidAt: Date | null;
}): string {
  const quaHan =
    d.status === 'PENDING' &&
    !conGiuCho(mocGuiNguoiCham(d), d.scheduledAt, Date.now());
  return MA_TRANG_THAI[quaHan ? 'CANCELLED_EXPIRED' : d.status];
}

export function conGiuCho(datLuc: Date, gioHen: Date, bayGio: number): boolean {
  const toiGioHen = (gioHen.getTime() - datLuc.getTime()) / 60000;
  const han = hanNhanDonPhut(toiGioHen);
  return bayGio < datLuc.getTime() + han * 60000;
}

export type BacGiuThem = 'khongThem' | 'nuaDem' | 'themMotDem';

export function phutGiuThem(gioNhan: Date, gioTra: Date): number {
  const soNgay = Math.max(
    0,
    soNgayLech(khoaNgayVn(gioNhan), khoaNgayVn(gioTra)),
  );
  const lech =
    phutTrongNgay(gioVn(gioTra)) -
    phutTrongNgay(gioVn(gioNhan)) +
    soNgay * 24 * 60;
  return lech < 0 ? 0 : lech;
}

export function phutTreCuaKy(
  gioNhan: Date,
  soDem: number,
  gioTraThat: Date,
): number {
  return Math.max(0, phutGiuThem(gioNhan, gioTraThat) - soDem * 24 * 60);
}

export function bacGiuThem(phutLech: number): BacGiuThem {
  if (phutLech <= 120) return 'khongThem';
  if (phutLech <= 480) return 'nuaDem';
  return 'themMotDem';
}

export function phiGiuThem(phutLech: number, giaMotDemCaDon: number): number {
  const bac = bacGiuThem(phutLech);
  if (bac === 'khongThem') return 0;
  if (bac === 'nuaDem') return Math.floor(giaMotDemCaDon / 2);
  const soNgayQua = Math.floor(phutLech / (24 * 60));
  return giaMotDemCaDon * (1 + soNgayQua);
}
