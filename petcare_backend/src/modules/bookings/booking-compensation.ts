import { MOT_GIO_MS } from '../../common/thoi-gian-vn';
import { THAM_SO } from '../admin/tham-so.dinh-nghia';

export const NO_SHOW_WAIT = 15;
export const PHUT_TU_HUY_KHONG_AI_BAT_DAU = 30;
export const GEAR_WAIT = 10;
export const DEPART_WINDOW_MINUTES = 120;
export const START_WINDOW_MINUTES = 15;
export const ARRIVE_GEOFENCE_METERS = 200;
export const HAN_PHAN_DOI_HOURS = 24;
export function mocNhaTien(ketThucLuc: Date, gioGiuTien: number): Date {
  return new Date(ketThucLuc.getTime() + gioGiuTien * MOT_GIO_MS);
}

export function gioGiuTienCuaDon(d: {
  endedAt: Date | null;
  escrowReleaseAt: Date | null;
}): number {
  if (!d.endedAt || !d.escrowReleaseAt) {
    return THAM_SO['escrow.hours'].macDinh;
  }
  return Math.round(
    (d.escrowReleaseAt.getTime() - d.endedAt.getTime()) / MOT_GIO_MS,
  );
}
