
export const DON_HOAN_THANH_TOI_THIEU = 20;
export const DIEM_DANH_GIA_TOI_THIEU = 4.5;
export const TY_LE_HUY_TOI_DA = 0.05;

export function laNguoiChamTinCay(e: {
  soDonHoanThanh: number;
  ratingAvg: number;
  tyLeHuy: number;
  biAnGanDay: boolean;
}): boolean {
  return (
    e.soDonHoanThanh >= DON_HOAN_THANH_TOI_THIEU &&
    e.ratingAvg >= DIEM_DANH_GIA_TOI_THIEU &&
    e.tyLeHuy <= TY_LE_HUY_TOI_DA &&
    !e.biAnGanDay
  );
}
