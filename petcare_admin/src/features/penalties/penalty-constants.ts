import type { PenaltyTabKey } from '@/features/penalties/types';

export const NGUONG_SAP_HET_HAN_GIO = 3;

export const THU_TU_TAB: PenaltyTabKey[] = ['pendingReview', 'active', 'waived', 'hidden'];

export type TinhTrangHanSoat =
  { kieu: 'khongCo' } | { kieu: 'quaHan' } | { kieu: 'conHan'; soGio: number; sapHet: boolean };

export function tinhTrangHanSoat(
  reviewDeadline: string | null,
  now: Date = new Date(),
): TinhTrangHanSoat {
  if (!reviewDeadline) return { kieu: 'khongCo' };
  const conLaiMs = new Date(reviewDeadline).getTime() - now.getTime();
  if (conLaiMs <= 0) return { kieu: 'quaHan' };
  const soGio = Math.max(1, Math.ceil(conLaiMs / 3600_000));
  return { kieu: 'conHan', soGio, sapHet: soGio <= NGUONG_SAP_HET_HAN_GIO };
}
