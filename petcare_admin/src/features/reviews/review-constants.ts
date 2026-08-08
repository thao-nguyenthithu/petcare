import type { AdminReviewRow, ReviewTabKey } from '@/features/reviews/types';

export const NGAY_DUOC_PHAN_HOI = 7;

export const THU_TU_TAB: ReviewTabKey[] = ['all', 'lowRating', 'hasPhotos', 'noReply'];

export const SAO_THAP_TOI_DA = 2;

export type TinhTrangPhanHoi =
  { kieu: 'daDap'; luc: string } | { kieu: 'conHan'; soNgay: number } | { kieu: 'hetHan' };

export function tinhTrangPhanHoi(
  row: Pick<AdminReviewRow, 'reply' | 'replyAt' | 'replyDeadline'>,
  now: Date = new Date(),
): TinhTrangPhanHoi {
  if (row.reply && row.replyAt) return { kieu: 'daDap', luc: row.replyAt };
  const conLaiMs = new Date(row.replyDeadline).getTime() - now.getTime();
  if (conLaiMs <= 0) return { kieu: 'hetHan' };
  return { kieu: 'conHan', soNgay: Math.max(1, Math.floor(conLaiMs / (24 * 3600_000))) };
}
