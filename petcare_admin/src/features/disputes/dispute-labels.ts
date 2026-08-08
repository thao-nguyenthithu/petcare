import { tinhTrangHanDap } from '@/features/disputes/dispute-constants';
import { formatDate } from '@/lib/format';

export function moTaHanDap(
  t: (key: string, options?: Record<string, unknown>) => string,
  replyDeadline: string | null,
  sitterReplyAt: string | null,
): string {
  const tinhTrang = tinhTrangHanDap({ replyDeadline, sitterReplyAt });
  if (tinhTrang.kieu === 'khongCoHan') {
    return t('khieuNai.hoSo.khongCoLuotDap');
  }
  if (tinhTrang.kieu === 'daDap') {
    return t('khieuNai.hoSo.daDapLuc', { luc: formatDate(tinhTrang.luc) });
  }
  if (tinhTrang.kieu === 'hetHan') {
    return t('khieuNai.hoSo.hetHanDap');
  }
  return t('khieuNai.hoSo.conHanDap', { soGio: tinhTrang.soGio });
}
