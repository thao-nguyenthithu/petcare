import {
  MOT_PHUT_MS,
  gioTuPhut,
  gioVn,
  khoaNgayVn,
  phutTrongNgay,
  soNgayLech,
  themNgay,
} from '../../common/thoi-gian-vn';
import { LOAI_RA_APP } from './booking-enums';
import { demGiuaHaiDon, TRAN_DEM_MOT_DON } from './booking-time';
import { DonChiemCho } from './sitter-slots.service';

export function khoangBanCuaDon(don: DonChiemCho) {
  const phut = don.durationMinutes ?? don.service.durationMinutes ?? 60;
  const ketThuc =
    don.scheduledEndAt ??
    new Date(don.scheduledAt.getTime() + phut * MOT_PHUT_MS);
  const ngay = khoaNgayVn(don.scheduledAt);
  const dem = demGiuaHaiDon(
    LOAI_RA_APP[don.service.type as keyof typeof LOAI_RA_APP],
  );
  const dau = phutTrongNgay(gioVn(don.scheduledAt)) - dem;
  const cuoiThuc =
    khoaNgayVn(ketThuc) === ngay ? phutTrongNgay(gioVn(ketThuc)) : 24 * 60;
  const cuoi = Math.min(cuoiThuc + dem, 24 * 60);
  return {
    ngay,
    start: gioTuPhut(Math.max(dau, 0)),
    end: cuoi >= 24 * 60 ? '23:59' : gioTuPhut(cuoi),
  };
}

export function demTrongGiu(don: {
  scheduledAt: Date;
  scheduledEndAt: Date | null;
}): string[] {
  const ngayDau = khoaNgayVn(don.scheduledAt);
  const ketThuc = don.scheduledEndAt ?? don.scheduledAt;
  const soDem = Math.min(
    Math.max(soNgayLech(ngayDau, khoaNgayVn(ketThuc)), 1),
    TRAN_DEM_MOT_DON,
  );
  return Array.from({ length: soDem }, (_, i) => themNgay(ngayDau, i));
}
