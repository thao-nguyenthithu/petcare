import type { SitterRow, SitterState, SitterTabKey } from '@/features/sitters/types';

export const BAC_NGAY_TAM_AN = [3, 7, 14];
export const NGAY_TAM_AN_MAC_DINH = 7;
export const SO_LAN_TAM_AN_KHOA = 4;
export const THANG_DEM_LAN_TAM_AN = 6;

export const GOI_GROOMING = ['bath', 'bathAndTrim'] as const;
export const BAC_CAN = ['duoi5', 'tu5den10', 'tu10den20', 'tren20'] as const;

export function trangThaiCuaNcc(
  row: Pick<SitterRow, 'status' | 'hiddenUntil' | 'bannedAt'>,
  bayGio: number = Date.now(),
): SitterState {
  if (row.bannedAt) return 'banned';
  if (row.hiddenUntil && new Date(row.hiddenUntil).getTime() > bayGio) return 'hidden';
  if (row.status === 'PENDING') return 'pending';
  if (row.status === 'REJECTED') return 'rejected';
  return 'active';
}

export const THU_TU_TAB: SitterTabKey[] = ['pending', 'active', 'rejected', 'hidden'];
