import type {
  AdminDisputeRow,
  DisputePenalty,
  DisputeTabKey,
  DisputeViewStatus,
} from '@/features/disputes/types';

export const HAN_PHAN_DOI_HOURS = 24;

export const NGUONG_SAP_HET_HAN_GIO = 3;

export const KHOA_HAN_KET_LUAN = 'dispute.support_days';

export const NGAY_CANH_BAO_TRUOC_HAN = 2;

export const THU_TU_TAB: DisputeTabKey[] = ['waitingSitter', 'waitingSupport', 'resolved'];

export const CAC_MUC_PHAT: DisputePenalty[] = ['WARNING', 'CANCEL_RATE', 'HIDE'];

export const CAC_KET_LUAN = [
  'khongToi',
  'treGio',
  'anhKhongHopLe',
  'thuThemTien',
  'khongDuCanCu',
] as const;

export type KetLuanKey = (typeof CAC_KET_LUAN)[number];

export function tinhTrangHienThi(
  row: Pick<AdminDisputeRow, 'status' | 'replyDeadline' | 'refundAmount'>,
  now: Date = new Date(),
): DisputeViewStatus {
  if (row.status === 'RESOLVED') {
    return (row.refundAmount ?? 0) > 0 ? 'refunded' : 'rejected';
  }
  if (row.status === 'REVIEWING') return 'waitingSupport';
  if (!row.replyDeadline) return 'waitingSupport';
  return new Date(row.replyDeadline).getTime() > now.getTime()
    ? 'waitingSitter'
    : 'waitingSupport';
}

export type TinhTrangHanDap =
  | { kieu: 'khongCoHan' }
  | { kieu: 'daDap'; luc: string }
  | { kieu: 'conHan'; soGio: number }
  | { kieu: 'hetHan' };

export function tinhTrangHanDap(
  row: { replyDeadline: string | null; sitterReplyAt: string | null },
  now: Date = new Date(),
): TinhTrangHanDap {
  if (row.sitterReplyAt) return { kieu: 'daDap', luc: row.sitterReplyAt };
  if (!row.replyDeadline) return { kieu: 'khongCoHan' };
  const conLaiMs = new Date(row.replyDeadline).getTime() - now.getTime();
  if (conLaiMs <= 0) return { kieu: 'hetHan' };
  return { kieu: 'conHan', soGio: Math.max(1, Math.floor(conLaiMs / 3600_000)) };
}

export type TinhTrangHanKetLuan =
  | { kieu: 'daKetLuan' }
  | { kieu: 'quaHan'; soNgay: number }
  | { kieu: 'canhBao'; soNgayConLai: number }
  | { kieu: 'conHan'; soNgayConLai: number };

const MOT_NGAY_MS = 24 * 3600_000;

export function tinhTrangHanKetLuan(
  row: Pick<AdminDisputeRow, 'status' | 'createdAt'>,
  hanNgay: number,
  now: Date = new Date(),
): TinhTrangHanKetLuan {
  if (row.status === 'RESOLVED') return { kieu: 'daKetLuan' };
  const conLai = new Date(row.createdAt).getTime() + hanNgay * MOT_NGAY_MS - now.getTime();
  if (conLai <= 0) {
    return { kieu: 'quaHan', soNgay: Math.max(1, Math.ceil(-conLai / MOT_NGAY_MS)) };
  }
  const soNgayConLai = Math.max(1, Math.ceil(conLai / MOT_NGAY_MS));
  const daTroi = hanNgay - soNgayConLai;
  if (daTroi >= hanNgay - NGAY_CANH_BAO_TRUOC_HAN) return { kieu: 'canhBao', soNgayConLai };
  return { kieu: 'conHan', soNgayConLai };
}
