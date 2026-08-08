import type { NotificationTypeRow, PreventionNote } from '@/features/notifications/types';

// Chữ sự kiện và màn mở nằm ở vi.json theo thongBao.loai.mo.<type>
export const LOAI_THONG_BAO: NotificationTypeRow[] = [
  { type: 'DON_HANG', audience: 'BOTH', inApp: true, push: true, hasTrigger: true },
  { type: 'DON_HUY', audience: 'BOTH', inApp: true, push: true, hasTrigger: true },
  { type: 'DON_MOI', audience: 'SITTER', inApp: true, push: true, hasTrigger: true },
  { type: 'BANG_CHUNG', audience: 'OWNER', inApp: true, push: true, hasTrigger: true },
  { type: 'DANH_GIA', audience: 'BOTH', inApp: true, push: true, hasTrigger: true },
  { type: 'NHAC_LICH', audience: 'BOTH', inApp: true, push: true, hasTrigger: false },
  { type: 'HO_SO', audience: 'SITTER', inApp: true, push: true, hasTrigger: true },
  { type: 'TIN_NHAN', audience: 'BOTH', inApp: true, push: true, hasTrigger: false },
  { type: 'NOI_DUNG', audience: 'BOTH', inApp: true, push: true, hasTrigger: true },
  { type: 'TIEN_VI', audience: 'SITTER', inApp: true, push: true, hasTrigger: false },
  { type: 'PHONG_BENH', audience: 'OWNER', inApp: true, push: true, hasTrigger: true },
  { type: 'KHIEU_NAI', audience: 'BOTH', inApp: true, push: true, hasTrigger: true },
];

export const GHI_CHU_PHONG_BENH: PreventionNote[] = [
  { ma: 'chuKy' },
  { ma: 'ngayToiHan' },
  { ma: 'nguongSapToiHan' },
  { ma: 'lucNaoTinh' },
  { ma: 'dayThongBao' },
];
