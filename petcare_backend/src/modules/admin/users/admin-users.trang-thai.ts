import {
  BookingStatus,
  PaymentStatus,
} from '../../../../generated/prisma/enums';

// Đơn còn đang chạy, chưa ngã ngũ về tiền lẫn kết quả
export const TRANG_THAI_DANG_MO = [
  BookingStatus.PENDING,
  BookingStatus.CONFIRMED,
  BookingStatus.IN_PROGRESS,
  BookingStatus.AWAITING_OWNER_CONFIRM,
  BookingStatus.DISPUTED,
];

// Đơn khoá tài khoản là làm treo: hai bên còn phải bấm nút mới đi tiếp được
export const TRANG_THAI_DANG_CHAY = [
  BookingStatus.CONFIRMED,
  BookingStatus.IN_PROGRESS,
  BookingStatus.AWAITING_OWNER_CONFIRM,
];

// Đơn chưa trả tiền không tính là đã chi tiêu, kể cả khi còn đang chờ trả
export const TRANG_THAI_DA_TRA_TIEN = [
  PaymentStatus.HELD,
  PaymentStatus.RELEASED,
  PaymentStatus.REFUNDING,
  PaymentStatus.REFUNDED,
];
