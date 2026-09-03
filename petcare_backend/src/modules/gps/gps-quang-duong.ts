import { khoangCachKm } from '../../common/khoang-cach';

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

export function kmHienThi(soDiem: number, tongMet: number): number | null {
  if (soDiem < 2) return null;
  return Math.round(tongMet / 100) / 10;
}
