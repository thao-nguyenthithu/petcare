import { MOT_NGAY_MS } from '../../../common/thoi-gian-vn';

const NGAY_MOI_NAM = 365.25;
const THANG_MOI_NAM = 12;

// Nhãn tuổi bé cho card thú cưng: dưới một năm thì đếm theo tháng cho có nghĩa
export function nhanTuoi(birthDate: Date | null): string {
  if (!birthDate) return 'Chưa rõ tuổi';
  const soNgay = (Date.now() - birthDate.getTime()) / MOT_NGAY_MS;
  if (soNgay < 0) return 'Chưa rõ tuổi';
  const soNam = Math.floor(soNgay / NGAY_MOI_NAM);
  if (soNam >= 1) return `${soNam} tuổi`;
  const soThang = Math.floor((soNgay / NGAY_MOI_NAM) * THANG_MOI_NAM);
  return `${Math.max(soThang, 0)} tháng`;
}

// Địa chỉ một dòng cho sổ địa chỉ và dòng "Địa chỉ mặc định" ở card hồ sơ
export function gopDiaChi(dc: {
  street: string;
  ward: string;
  province: string;
}): string {
  return [dc.street, dc.ward, dc.province].filter(Boolean).join(', ');
}
