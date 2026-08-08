import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { BookingStatus, SitterDayMode } from 'generated/prisma/enums';
import { soNgayLech } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { CheDoNgay } from './dto/update-day-availability.dto';

export const TRAN_NGAY_XEM = 62;
export const TRAN_NGAY_NGHI = 90;
export const TRAN_DON_XEM = 500;
export const TRAN_NGAY_DA_CHINH = 400;
export const TRAN_NGAY_MOT_DON = 31;

export const TRANG_THAI_TREN_LICH: BookingStatus[] = [
  'CONFIRMED',
  'IN_PROGRESS',
  'AWAITING_OWNER_CONFIRM',
  'COMPLETED',
];

export const TRANG_THAI_CON_HIEU_LUC: BookingStatus[] = [
  'CONFIRMED',
  'IN_PROGRESS',
];

export function soTuJson(v: unknown): number | null {
  return typeof v === 'number' && Number.isFinite(v) ? v : null;
}

export const CHE_DO_RA_DB: Record<CheDoNgay, SitterDayMode> = {
  default: 'DEFAULT',
  customHours: 'CUSTOM_HOURS',
  off: 'OFF',
};

export const CHE_DO_RA_APP: Record<SitterDayMode, CheDoNgay> = {
  DEFAULT: 'default',
  CUSTOM_HOURS: 'customHours',
  OFF: 'off',
};

export const TRANG_THAI_RA_APP: Partial<Record<BookingStatus, string>> = {
  CONFIRMED: 'sapToi',
  IN_PROGRESS: 'dangDienRa',
  AWAITING_OWNER_CONFIRM: 'choXacNhan',
  COMPLETED: 'hoanThanh',
};

export type DonCuaLich = {
  id: string;
  code: string;
  status: BookingStatus;
  scheduledAt: Date;
  scheduledEndAt: Date | null;
  service: { name: string; type: string; durationMinutes: number | null };
  owner: { fullName: string };
  pets: { pet: { name: string; species: string; avatarUrl: string | null } }[];
};

export type PhanNgayTrongGiu = 'nhan' | 'troc' | 'tra';

export type DongLich = {
  id: string;
  code: string;
  startTime: string;
  endTime: string;
  dayPart: PhanNgayTrongGiu | null;
  serviceName: string;
  serviceType: string;
  status: string;
  ownerName: string;
  district: string | null;
  pets: { name: string; species: string; avatarUrl: string | null }[];
  ngayThu: number;
  tongNgay: number;
};

export async function layNccCuaToi(prisma: PrismaService, userId: string) {
  const ncc = await prisma.sitter.findUnique({ where: { userId } });
  if (!ncc) {
    throw new ForbiddenException({
      code: 'CHUA_LA_NCC',
      message: 'Tài khoản chưa phải nhà cung cấp',
    });
  }
  return ncc;
}

export function kiemTraKhoang(tu: string, den: string, tran: number) {
  const soNgay = soNgayLech(tu, den) + 1;
  if (soNgay < 1) {
    throw new BadRequestException({
      code: 'KHOANG_KHONG_HOP_LE',
      message: 'Ngày kết thúc phải từ ngày bắt đầu trở đi',
    });
  }
  if (soNgay > tran) {
    throw new BadRequestException({
      code: 'KHOANG_QUA_DAI',
      message: `Chỉ xem được tối đa ${tran} ngày mỗi lần`,
    });
  }
  return soNgay;
}

// Không bật trông giữ thì không có chỗ nào để nhận
export async function sucChuaTrongGiu(
  prisma: PrismaService,
  userId: string,
): Promise<number> {
  const dv = await prisma.sitterService.findFirst({
    where: { sitter: { userId }, type: 'BOARDING' },
    select: { enabled: true, pricing: true },
  });
  if (!dv?.enabled) return 0;
  const pricing = dv.pricing as Record<string, unknown> | null;
  return soTuJson(pricing?.capacity) ?? 0;
}
