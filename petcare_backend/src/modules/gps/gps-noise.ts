import { khoangCachKm } from '../../common/khoang-cach';
import { NGUONG_NOISE_KMH } from './gps.constants';

export interface DiemGps {
  lat: number;
  lng: number;
  tsMs: number;
}

export function tocDoKmh(a: DiemGps, b: DiemGps): number {
  const km = khoangCachKm(a.lat, a.lng, b.lat, b.lng);
  const gio = (b.tsMs - a.tsMs) / 3_600_000;
  if (gio <= 0) return km > 0 ? Infinity : 0;
  return km / gio;
}

export function danhDauNoise(
  diemTruoc: DiemGps | null,
  batch: DiemGps[],
): boolean[] {
  const day = diemTruoc ? [diemTruoc, ...batch] : [...batch];
  const batDau = diemTruoc ? 1 : 0;
  const ketQua: boolean[] = [];
  for (let i = batDau; i < day.length; i++) {
    const vao = i > 0 ? tocDoKmh(day[i - 1], day[i]) : null;
    const ra = i < day.length - 1 ? tocDoKmh(day[i], day[i + 1]) : null;
    ketQua.push(
      vao !== null &&
        ra !== null &&
        vao > NGUONG_NOISE_KMH &&
        ra > NGUONG_NOISE_KMH,
    );
  }
  return ketQua;
}
