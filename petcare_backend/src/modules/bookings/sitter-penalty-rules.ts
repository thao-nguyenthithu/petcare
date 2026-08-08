import { MOT_NGAY_MS } from '../../common/thoi-gian-vn';

export const CANH_CAO_BAT_DAU_NHAC = 2;
export const BAC_NGAY_TAM_AN = [3, 7, 14];
export const SO_LAN_TAM_AN_KHOA = 4;
export const THANG_DEM_LAN_TAM_AN = 6;
export const GIO_SUPPORT_SOAT = 24;

export function mocDemPhat(
  bayGio: number,
  ngayCuaSo: number,
  mocAnGanNhat: Date | null,
): Date {
  const dauCuaSo = bayGio - ngayCuaSo * MOT_NGAY_MS;
  if (mocAnGanNhat === null) return new Date(dauCuaSo);
  return new Date(Math.max(dauCuaSo, mocAnGanNhat.getTime()));
}

export type MucPhat = {
  tinhTyLeHuy: boolean;
  canhCao: boolean;
  treoChoSoat: boolean;
};

export type NgaCanhBoDon = 'huyChuaXuatPhat' | 'daXuatPhat' | 'imLang';

export function mucPhat(nga: NgaCanhBoDon): MucPhat {
  switch (nga) {
    case 'huyChuaXuatPhat':
      return { tinhTyLeHuy: true, canhCao: false, treoChoSoat: false };
    case 'daXuatPhat':
      return { tinhTyLeHuy: true, canhCao: true, treoChoSoat: true };
    case 'imLang':
      return { tinhTyLeHuy: true, canhCao: true, treoChoSoat: false };
  }
}

export function ngayTamAn(lanThu: number): number {
  const i = Math.min(Math.max(lanThu, 1), BAC_NGAY_TAM_AN.length);
  return BAC_NGAY_TAM_AN[i - 1];
}

export const KHONG_TINH_LOI: MucPhat = {
  tinhTyLeHuy: false,
  canhCao: false,
  treoChoSoat: false,
};

export const PHAT_NCC_CHUA_TOI: MucPhat = mucPhat('imLang');
