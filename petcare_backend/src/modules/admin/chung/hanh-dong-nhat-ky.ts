// Thiếu mã ở đây là bảng nhật ký hiện mã thô vì màn không có nhãn tương ứng
export const HANH_DONG_NHAT_KY = [
  'KHOA_TAI_KHOAN',
  'MO_KHOA_TAI_KHOAN',
  'AN_HO_SO_THU_CUNG',
  'HIEN_HO_SO_THU_CUNG',
  'DUYET_HO_SO_NCC',
  'TU_CHOI_HO_SO_NCC',
  'YEU_CAU_BO_SUNG_HO_SO_NCC',
  'TAM_AN_HO_SO_NCC',
  'KHOA_HO_SO_NCC',
  'GO_KHOA_HO_SO_NCC',
  'MIEN_PHAT_NCC',
  'GIU_PHAT_NCC',
  'CAN_THIEP_HUY_DON',
  'GO_CO_GPS',
  'GIU_CO_GPS',
  'KET_LUAN_KHIEU_NAI',
  'DANH_DAU_HOAN_TIEN',
  'CHUYEN_TIEN_RUT',
  'HOAN_TAT_LENH_RUT',
  'TU_CHOI_LENH_RUT',
  'CAP_NHAT_THAM_SO',
  'GUI_THONG_BAO_HE_THONG',
  'HUY_LICH_THONG_BAO',
  'CAP_NHAT_DANH_MUC_DICH_VU',
  'KHOA_CAU_HINH_DICH_VU',
  'MO_CAU_HINH_DICH_VU',
] as const;

export type HanhDongNhatKy = (typeof HANH_DONG_NHAT_KY)[number];

// Loại đối tượng bị tác động, đúng danh sách ghi ở model AdminAuditLog
export const LOAI_DOI_TUONG_NHAT_KY = [
  'USER',
  'PET',
  'SITTER',
  'BOOKING',
  'DISPUTE',
  'WITHDRAWAL',
  'PAYMENT',
  'PENALTY',
  'SETTING',
  'NOTIFICATION',
] as const;

export type LoaiDoiTuong = (typeof LOAI_DOI_TUONG_NHAT_KY)[number];
