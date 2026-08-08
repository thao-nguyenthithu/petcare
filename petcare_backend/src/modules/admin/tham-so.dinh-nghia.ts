// Chỗ khai DUY NHẤT của tham số vận hành, không được giữ bản sao nào khác

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

// Kiểu thứ ba: chọn một giá trị trong tập cho trước (bộ luật mục 15)
export type DinhNghiaChon = {
  kieu: 'chon';
  macDinh: string;
  giaTriChoPhep: readonly string[];
  nhan: string;
  congKhai: boolean;
};

export type DinhNghiaThamSo = DinhNghiaSo | DinhNghiaBatTat | DinhNghiaChon;

// Con số áp cho một đơn là con số lúc chốt đơn, bảng này chỉ chi phối đơn mới
export const THAM_SO = {
  // Bộ luật mục 2
  'platform.fee.percent': {
    kieu: 'so',
    macDinh: 15,
    min: 5,
    max: 30,
    donVi: 'phanTram',
    nhan: 'Phí nền tảng',
    congKhai: true,
  },
  // Bộ luật mục 4
  'cancel.fee.percent': {
    kieu: 'so',
    macDinh: 50,
    min: 20,
    max: 70,
    donVi: 'phanTram',
    nhan: 'Phí huỷ muộn',
    congKhai: true,
  },
  // Bộ luật mục 7
  'escrow.hours': {
    kieu: 'so',
    macDinh: 48,
    min: 24,
    max: 168,
    donVi: 'gio',
    nhan: 'Thời gian giữ tiền sau khi xong việc',
    congKhai: true,
  },
  // Bộ luật mục 2
  'withdraw.min': {
    kieu: 'so',
    macDinh: 50_000,
    min: 20_000,
    max: 500_000,
    donVi: 'dong',
    nhan: 'Số tiền rút tối thiểu',
    congKhai: true,
  },
  // Bộ luật mục 2
  'withdraw.per_day': {
    kieu: 'so',
    macDinh: 2,
    min: 1,
    max: 10,
    donVi: 'lan',
    nhan: 'Số lần rút mỗi ngày',
    congKhai: true,
  },
  // Bộ luật mục 6
  'penalty.warnings_to_hide': {
    kieu: 'so',
    macDinh: 4,
    min: 2,
    max: 10,
    donVi: 'lan',
    nhan: 'Số cảnh cáo đủ để ẩn hồ sơ',
    congKhai: true,
  },
  // Bộ luật mục 6
  'penalty.window_days': {
    kieu: 'so',
    macDinh: 90,
    min: 30,
    max: 180,
    donVi: 'ngay',
    nhan: 'Cửa sổ đếm vi phạm',
    congKhai: true,
  },
  // Bộ luật mục 6
  'penalty.cancel_rate_max': {
    kieu: 'so',
    macDinh: 20,
    min: 10,
    max: 50,
    donVi: 'phanTram',
    nhan: 'Ngưỡng tỷ lệ huỷ bị ẩn hồ sơ',
    congKhai: true,
  },
  // Bộ luật mục 6
  'penalty.min_orders': {
    kieu: 'so',
    macDinh: 5,
    min: 1,
    max: 20,
    donVi: 'don',
    nhan: 'Số đơn tối thiểu để xét tỷ lệ huỷ',
    congKhai: true,
  },
  // Bộ luật mục 7
  'dispute.support_days': {
    kieu: 'so',
    macDinh: 7,
    min: 1,
    max: 30,
    donVi: 'ngay',
    nhan: 'Chỉ tiêu kết luận một khiếu nại',
    congKhai: true,
  },
  // Bộ luật mục 9
  'search.radius_max_km': {
    kieu: 'so',
    macDinh: 15,
    min: 5,
    max: 50,
    donVi: 'km',
    nhan: 'Bán kính tìm kiếm tối đa',
    congKhai: true,
  },
  // Bộ luật mục 15
  'sitter.auto_approve': {
    kieu: 'batTat',
    macDinh: false,
    nhan: 'Tự duyệt hồ sơ người chăm',
    // Không cho ứng dụng đọc: đây là chuyện vận hành nội bộ
    congKhai: false,
  },
  // Bộ luật mục 15
  'payment.vnpay.enabled': {
    kieu: 'batTat',
    macDinh: false,
    nhan: 'Bật thanh toán qua VNPay',
    congKhai: true,
  },
  // Bộ luật mục 15
  'ai.vision.provider': {
    kieu: 'chon',
    macDinh: 'anthropic',
    giaTriChoPhep: ['anthropic', 'gemini'] as const,
    nhan: 'Nhà cung cấp nhận diện ảnh',
    // Không cho ứng dụng đọc: người chăm không cần biết ảnh gửi cho nhà nào
    congKhai: false,
  },
} satisfies Record<string, DinhNghiaThamSo>;

export type KhoaThamSo = keyof typeof THAM_SO;

// Tách hai nhóm khoá để gọi nhầm so() vào một công tắc là lỗi biên dịch
export type KhoaSo = {
  [K in KhoaThamSo]: (typeof THAM_SO)[K]['kieu'] extends 'so' ? K : never;
}[KhoaThamSo];

export type KhoaBatTat = {
  [K in KhoaThamSo]: (typeof THAM_SO)[K]['kieu'] extends 'batTat' ? K : never;
}[KhoaThamSo];

export type KhoaChon = {
  [K in KhoaThamSo]: (typeof THAM_SO)[K]['kieu'] extends 'chon' ? K : never;
}[KhoaThamSo];

// Trả về đúng tập giá trị của khoá nên nhánh switch thiếu là lỗi biên dịch
export type GiaTriChon<K extends KhoaChon> = (typeof THAM_SO)[K] extends {
  giaTriChoPhep: readonly (infer G)[];
}
  ? G
  : never;

export const KHOA_THAM_SO = Object.keys(THAM_SO) as KhoaThamSo[];

export function laKhoaThamSo(khoa: string): khoa is KhoaThamSo {
  return (KHOA_THAM_SO as string[]).includes(khoa);
}

// Trần cứng cho @Max của DTO, decorator chạy lúc nạp lớp nên không đổi được
export const TRAN_CUNG_BAN_KINH_KM = THAM_SO['search.radius_max_km'].max;
