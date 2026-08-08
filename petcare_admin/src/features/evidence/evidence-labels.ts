import type { TFunction } from 'i18next';
import type { EvidenceGroup, EvidencePhoto, ReportKind } from '@/features/evidence/types';
import { formatTime } from '@/lib/format';

export function nhanNguon(photo: EvidencePhoto, t: TFunction): string {
  const gio = formatTime(photo.takenAt);
  if (photo.source === 'noShow') {
    const kieu = photo.reportKind
      ? t(`anh.suCo.${photo.reportKind}`)
      : t('anh.suCo.khac');
    return `${kieu} · ${gio}`;
  }
  if (photo.source === 'boarding') return `${t('anh.tab.boarding')} · ${gio}`;
  if (photo.anhDoDung) return `${t('anh.nhom.doDung')} · ${gio}`;
  if (!photo.phase) return gio;
  return `${t(`anh.pha.${photo.phase}`)} · ${gio}`;
}

export function nhanNhom(
  group: EvidenceGroup,
  t: TFunction,
  reportKind?: ReportKind | null,
): string {
  if (group.dayIndex !== null) return t('anh.nhom.ngay', { n: group.dayIndex });
  const nhan = t(`anh.nhom.${group.key}`, { defaultValue: t('anh.nhom.khac') });
  if (group.key !== 'suCo') return nhan;
  return `${nhan} · ${reportKind ? t(`anh.suCo.${reportKind}`) : t('anh.suCo.khac')}`;
}

export function nhanTinhTrang(ma: string, t: TFunction): string {
  return t(`anh.tinhTrang.${ma}`, { defaultValue: t('anh.tinhTrang.khac') });
}
