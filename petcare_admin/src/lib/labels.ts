import type { TFunction } from 'i18next';

export function nhanThoiLuong(t: TFunction, phut: number | null): string | null {
  if (phut === null) return null;
  if (phut % 60 === 0) return t('don.thoiLuongGio', { count: phut / 60 });
  return t('don.thoiLuongPhut', { count: phut });
}

export function nhanTuoi(t: TFunction, birthDate: string | null): string | null {
  if (!birthDate) return null;
  const thang = Math.max(
    0,
    Math.floor((Date.now() - new Date(birthDate).getTime()) / (30.44 * 24 * 3600_000)),
  );
  if (thang < 12) return t('don.tuoiThang', { count: thang });
  return t('don.tuoiNam', { count: Math.floor(thang / 12) });
}
