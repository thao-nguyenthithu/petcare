import { ConflictException } from '@nestjs/common';
import { BookingStatus } from 'generated/prisma/enums';

const CHUYEN_DUOC: Record<BookingStatus, BookingStatus[]> = {
  AWAITING_PAYMENT: ['PENDING', 'CANCELLED_UNPAID', 'CANCELLED_BY_ADMIN'],
  CANCELLED_UNPAID: [],
  PENDING: [
    'CONFIRMED',
    'CANCELLED_BY_OWNER',
    'CANCELLED_BY_SITTER',
    'CANCELLED_EXPIRED',
    'CANCELLED_BY_ADMIN',
  ],
  CONFIRMED: [
    'IN_PROGRESS',
    'CANCELLED_BY_OWNER',
    'CANCELLED_BY_SITTER',
    'CANCELLED_NO_SHOW',
    'CANCELLED_BY_ADMIN',
  ],
  IN_PROGRESS: ['AWAITING_OWNER_CONFIRM', 'COMPLETED', 'DISPUTED'],
  AWAITING_OWNER_CONFIRM: ['COMPLETED', 'DISPUTED'],
  COMPLETED: ['DISPUTED'],
  CANCELLED_BY_OWNER: [],
  CANCELLED_BY_SITTER: [],
  CANCELLED_EXPIRED: [],
  CANCELLED_NO_SHOW: [],
  CANCELLED_BY_ADMIN: [],
  DISPUTED: ['RESOLVED'],
  RESOLVED: [],
};

export function chuyenDuoc(tu: BookingStatus, den: BookingStatus): boolean {
  return CHUYEN_DUOC[tu].includes(den);
}

export function kiemTraChuyen(tu: BookingStatus, den: BookingStatus) {
  if (!chuyenDuoc(tu, den)) {
    throw new ConflictException({
      code: 'TRANG_THAI_KHONG_HOP_LE',
      message: 'Đơn không còn ở bước làm được việc này',
    });
  }
}

export function daKhepLai(tt: BookingStatus): boolean {
  return CHUYEN_DUOC[tt].length === 0;
}
