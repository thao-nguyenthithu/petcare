import { BookingStatus, ServiceType } from 'generated/prisma/enums';
import { LoaiDichVuDto } from './dto/create-booking.dto';
import { LY_DO_NCC_CHUA_TOI } from './dto/cancel-booking.dto';

export const MA_TRANG_THAI: Record<BookingStatus, string> = {
  AWAITING_PAYMENT: 'awaitingPayment',
  CANCELLED_UNPAID: 'cancelledUnpaid',
  PENDING: 'pending',
  CONFIRMED: 'confirmed',
  IN_PROGRESS: 'inProgress',
  AWAITING_OWNER_CONFIRM: 'awaitingOwnerConfirm',
  COMPLETED: 'completed',
  CANCELLED_BY_OWNER: 'cancelledByOwner',
  CANCELLED_BY_SITTER: 'cancelledBySitter',
  CANCELLED_EXPIRED: 'cancelledExpired',
  CANCELLED_NO_SHOW: 'cancelledNoShow',
  CANCELLED_BY_ADMIN: 'cancelledByAdmin',
  DISPUTED: 'disputed',
  RESOLVED: 'resolved',
};

export const TRANG_THAI_HUY: BookingStatus[] = [
  'CANCELLED_BY_OWNER',
  'CANCELLED_BY_SITTER',
  'CANCELLED_EXPIRED',
  'CANCELLED_NO_SHOW',
  'CANCELLED_BY_ADMIN',
];

export const TRANG_THAI_AN: BookingStatus[] = [
  'AWAITING_PAYMENT',
  'CANCELLED_UNPAID',
];

export const BEN_HUY_RA_APP: Partial<Record<BookingStatus, string>> = {
  CANCELLED_BY_OWNER: 'owner',
  CANCELLED_BY_SITTER: 'sitter',
  CANCELLED_EXPIRED: 'systemExpired',
  CANCELLED_NO_SHOW: 'noShow',
  CANCELLED_BY_ADMIN: 'admin',
};

export const LY_DO_QUAN_TRI_CAN_THIEP = 'quanTriCanThiep';
export const LY_DO_HUY_NCC_BAN = 'nccBanKhungKhac';
export const LY_DO_HE_THONG_NCC_CHUA_TOI = 'heThongNccChuaToi';
export const LY_DO_KHONG_AI_BAT_DAU = 'heThongKhongAiBatDau';
export const LY_DO_THIEU_DUNG_CU = 'thieuDungCu';

export function benHuyRaApp(d: {
  status: BookingStatus;
  cancellationReason: string | null;
}): string {
  if (
    d.status === 'CANCELLED_EXPIRED' &&
    d.cancellationReason === LY_DO_HUY_NCC_BAN
  ) {
    return 'systemSitterBusy';
  }
  if (
    d.status === 'CANCELLED_BY_SITTER' &&
    d.cancellationReason === LY_DO_NCC_CHUA_TOI
  ) {
    return 'sitterNoShow';
  }
  if (
    d.status === 'CANCELLED_BY_SITTER' &&
    d.cancellationReason === LY_DO_HE_THONG_NCC_CHUA_TOI
  ) {
    return 'systemSitterNoShow';
  }
  if (
    d.status === 'CANCELLED_NO_SHOW' &&
    d.cancellationReason === LY_DO_KHONG_AI_BAT_DAU
  ) {
    return 'systemNoStart';
  }
  return BEN_HUY_RA_APP[d.status] ?? 'systemExpired';
}

export const LOAI_RA_APP: Record<ServiceType, LoaiDichVuDto> = {
  WALKING: 'walking',
  BOARDING: 'boarding',
  GROOMING: 'grooming',
};

export const LOAI_RA_DB: Record<LoaiDichVuDto, ServiceType> = {
  walking: 'WALKING',
  boarding: 'BOARDING',
  grooming: 'GROOMING',
};
