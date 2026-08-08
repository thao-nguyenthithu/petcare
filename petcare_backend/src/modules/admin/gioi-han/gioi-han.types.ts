// Bản kê chỉ đọc màn 15b: con số phải NHẬP từ module thi hành, khai lại là bản sao thứ hai

// Nhãn và mô tả nằm ở vi.json của web quản trị, đây chỉ giữ mã
export type MucGioiHan = {
  ma: string;
  value: string;
  unit: string;
};

export type CotGioiHan = 'trai' | 'phai';

export type NhomGioiHan = {
  key: string;
  cot: CotGioiHan;
  items: MucGioiHan[];
  // Nhóm chỉ giữ chỗ, chưa có hằng số hay bảng dữ liệu tương ứng
  chuaCoTrongCode?: boolean;
  // Nhóm từng có dòng nay đã chuyển sang màn Cấu hình vận hành
  coDongDaChuyen?: boolean;
};

const DINH_DANG_SO = new Intl.NumberFormat('vi-VN');

export function so(giaTri: number): string {
  return DINH_DANG_SO.format(giaTri);
}

export function day(giaTri: readonly number[]): string {
  return giaTri.map(so).join(' · ');
}

const BYTE_MOI_MB = 1024 * 1024;

export function mb(byte: number): string {
  return so(byte / BYTE_MOI_MB);
}

export function phutRaGio(phut: number): string {
  return so(phut / 60);
}

export function giayRaPhut(giay: number): string {
  return so(giay / 60);
}

export function msRaGiay(ms: number): string {
  return so(ms / 1000);
}

// Làm tròn hai chữ số vì 0.05 nhân 100 trong dấu phẩy động ra 5,000000000000001
export function phanTram(tiLe: number): string {
  return so(Math.round(tiLe * 100 * 100) / 100);
}
