import type { OperatingSetting } from '@/features/settings/types';
import { formatDateTime } from '@/lib/format';

export type DichChuoi = (key: string, options?: Record<string, unknown>) => string;

export function khoaChuoi(key: string): string {
  return key.replace(/\./g, '_');
}

export function nhanNguoiDoi(t: DichChuoi, item: OperatingSetting): string {
  if (!item.nguoiDoi || !item.capNhatLuc) return t('caiDat.vanHanh.chuaAiDoi');
  return t('caiDat.vanHanh.doiBoi', {
    ten: item.nguoiDoi.hoTen ?? t('chung.quanTriVien'),
    time: formatDateTime(item.capNhatLuc),
  });
}

export function nhanGiaTriChon(t: DichChuoi, giaTri: string): string {
  return t(`caiDat.luaChon.giaTri.${giaTri}`, { defaultValue: giaTri });
}
