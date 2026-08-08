import { khoangCachKm } from '../../../common/khoang-cach';
import { MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { ServiceType } from '../../../../generated/prisma/enums';

// Ba nhánh cùng ghi đè lên Booking.noShowProofUrls nên ảnh phải nói rõ nó thuộc nhánh nào
export type KieuBaoSuCo = 'GEAR' | 'NO_SHOW' | 'SITTER_ABANDON';

// Khép đơn ghi đè mảng ảnh của lượt báo thiếu dụng cụ, nên hai kết cục kia xét trước
export function kieuBaoSuCo(
  status: string,
  gearReportedAt: Date | null,
): KieuBaoSuCo | null {
  if (status === 'CANCELLED_NO_SHOW') return 'NO_SHOW';
  if (status === 'CANCELLED_BY_SITTER') return 'SITTER_ABANDON';
  return gearReportedAt ? 'GEAR' : null;
}

export type ToaDo = { lat: number | null; lng: number | null };

// Trông giữ thì chủ nuôi mang bé tới nhà người chăm, hai dịch vụ kia người chăm tới nhà chủ nuôi
export function diemHen(
  serviceType: ServiceType,
  diaChiDon: ToaDo,
  nhaNguoiCham: ToaDo,
): ToaDo {
  return serviceType === ServiceType.BOARDING ? nhaNguoiCham : diaChiDon;
}

export function lechMet(diem: ToaDo, anh: ToaDo): number | null {
  if (diem.lat === null || diem.lng === null) return null;
  if (anh.lat === null || anh.lng === null) return null;
  return Math.round(khoangCachKm(diem.lat, diem.lng, anh.lat, anh.lng) * 1000);
}

// Bỏ trống khi chưa chốt ngày trả bé, suy đại một đêm là bịa ra ngày thiếu ảnh
export function soDem(tu: Date, den: Date | null): number | null {
  if (!den) return null;
  return Math.max(1, Math.round((den.getTime() - tu.getTime()) / MOT_NGAY_MS));
}
