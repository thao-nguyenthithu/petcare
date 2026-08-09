export type DonViThamSo =
  | 'phanTram'
  | 'gio'
  | 'ngay'
  | 'dong'
  | 'lan'
  | 'don'
  | 'km';

export type DinhNghiaSo = {
  kieu: 'so';
  macDinh: number;
  min: number;
  max: number;
  donVi: DonViThamSo;
  nhan: string;
  congKhai: boolean;
};

export type DinhNghiaBatTat = {
  kieu: 'batTat';
  macDinh: boolean;
  nhan: string;
  congKhai: boolean;
};

export type DinhNghiaChon = {
  kieu: 'chon';
  macDinh: string;
  giaTriChoPhep: readonly string[];
  nhan: string;
  congKhai: boolean;
};

export type DinhNghiaThamSo = DinhNghiaSo | DinhNghiaBatTat | DinhNghiaChon;

export const THAM_SO = {
  'platform.fee.percent': {
    kieu: 'so',
    macDinh: 15,
    min: 5,
    max: 30,
    donVi: 'phanTram',
    nhan: 'Phí nền tảng',
    congKhai: true,
  },
  'cancel.fee.percent': {
    kieu: 'so',
    macDinh: 50,
    min: 20,
    max: 70,
    donVi: 'phanTram',
    nhan: 'Phí huỷ muộn',
    congKhai: true,
  },
  'escrow.hours': {
    kieu: 'so',
    macDinh: 48,
    min: 24,
    max: 168,
    donVi: 'gio',
    nhan: 'Thời gian giữ tiền sau khi xong việc',
    congKhai: true,
  },
  'withdraw.min': {
    kieu: 'so',
    macDinh: 50_000,
    min: 20_000,
    max: 500_000,
    donVi: 'dong',
    nhan: 'Số tiền rút tối thiểu',
    congKhai: true,
  },
  'withdraw.per_day': {
    kieu: 'so',
    macDinh: 2,
    min: 1,
    max: 10,
    donVi: 'lan',
    nhan: 'Số lần rút mỗi ngày',
    congKhai: true,
  },
  'penalty.warnings_to_hide': {
    kieu: 'so',
    macDinh: 4,
    min: 2,
    max: 10,
    donVi: 'lan',
    nhan: 'Số cảnh cáo đủ để ẩn hồ sơ',
    congKhai: true,
  },
  'penalty.window_days': {
    kieu: 'so',
    macDinh: 90,
    min: 30,
    max: 180,
    donVi: 'ngay',
    nhan: 'Cửa sổ đếm vi phạm',
    congKhai: true,
  },
  'penalty.cancel_rate_max': {
    kieu: 'so',
    macDinh: 20,
    min: 10,
    max: 50,
    donVi: 'phanTram',
    nhan: 'Ngưỡng tỷ lệ huỷ bị ẩn hồ sơ',
    congKhai: true,
  },
  'penalty.min_orders': {
    kieu: 'so',
    macDinh: 5,
    min: 1,
    max: 20,
    donVi: 'don',
    nhan: 'Số đơn tối thiểu để xét tỷ lệ huỷ',
    congKhai: true,
  },
  'dispute.support_days': {
    kieu: 'so',
    macDinh: 7,
    min: 1,
    max: 30,
    donVi: 'ngay',
    nhan: 'Chỉ tiêu kết luận một khiếu nại',
    congKhai: true,
  },
  'search.radius_max_km': {
    kieu: 'so',
    macDinh: 15,
    min: 5,
    max: 50,
    donVi: 'km',
    nhan: 'Bán kính tìm kiếm tối đa',
    congKhai: true,
  },
  'sitter.auto_approve': {
    kieu: 'batTat',
    macDinh: false,
    nhan: 'Tự duyệt hồ sơ người chăm',
    congKhai: false,
  },
  'payment.vnpay.enabled': {
    kieu: 'batTat',
    macDinh: false,
    nhan: 'Bật thanh toán qua VNPay',
    congKhai: true,
  },
  'checkin.geofence.enabled': {
    kieu: 'batTat',
    macDinh: true,
    nhan: 'Kiểm vị trí quanh điểm hẹn',
    congKhai: true,
  },
  'ai.vision.provider': {
    kieu: 'chon',
    macDinh: 'anthropic',
    giaTriChoPhep: ['anthropic', 'gemini'] as const,
    nhan: 'Nhà cung cấp nhận diện ảnh',
    congKhai: false,
  },
} satisfies Record<string, DinhNghiaThamSo>;

export type KhoaThamSo = keyof typeof THAM_SO;

export type KhoaSo = {
  [K in KhoaThamSo]: (typeof THAM_SO)[K]['kieu'] extends 'so' ? K : never;
}[KhoaThamSo];

export type KhoaBatTat = {
  [K in KhoaThamSo]: (typeof THAM_SO)[K]['kieu'] extends 'batTat' ? K : never;
}[KhoaThamSo];

export type KhoaChon = {
  [K in KhoaThamSo]: (typeof THAM_SO)[K]['kieu'] extends 'chon' ? K : never;
}[KhoaThamSo];

export type GiaTriChon<K extends KhoaChon> = (typeof THAM_SO)[K] extends {
  giaTriChoPhep: readonly (infer G)[];
}
  ? G
  : never;

export const KHOA_THAM_SO = Object.keys(THAM_SO) as KhoaThamSo[];

export function laKhoaThamSo(khoa: string): khoa is KhoaThamSo {
  return (KHOA_THAM_SO as string[]).includes(khoa);
}

export const TRAN_CUNG_BAN_KINH_KM = THAM_SO['search.radius_max_km'].max;
