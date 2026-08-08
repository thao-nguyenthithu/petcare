import { khoangCachKm } from '../../common/khoang-cach';
import { NGUONG_LECH_KM, NGUONG_LECH_TY_LE } from './gps.constants';


export interface ToaDo {
  lat: number;
  lng: number;
}

export function tongQuangDuongKm(diem: ToaDo[]): number {
  let km = 0;
  for (let i = 1; i < diem.length; i++) {
    km += khoangCachKm(
      diem[i - 1].lat,
      diem[i - 1].lng,
      diem[i].lat,
      diem[i].lng,
    );
  }
  return km;
}

export function tiLeLech(
  kmServer: number,
  kmApp: number | null,
): number | null {
  if (kmApp === null) return null;
  const lech = Math.abs(kmApp - kmServer);
  const mocChia = Math.max(kmServer, kmApp, 0.1);
  return Math.min(1, Math.round((lech / mocChia) * 100) / 100);
}

export function kmHienThi(soDiem: number, tongMet: number): number | null {
  if (soDiem < 2) return null;
  return Math.round(tongMet / 100) / 10;
}

export function lechDangKe(kmServer: number, kmApp: number | null): boolean {
  if (kmApp === null) return false;
  const lech = Math.abs(kmApp - kmServer);
  return lech > NGUONG_LECH_KM && lech > kmServer * NGUONG_LECH_TY_LE;
}
