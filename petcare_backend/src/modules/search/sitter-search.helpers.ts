import { ServiceType } from '../../../generated/prisma/client';

function boDau(chuoi: string): string {
  return chuoi
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .trim();
}

const TU_KHOA_DICH_VU: Record<ServiceType, string[]> = {
  WALKING: ['dat di dao', 'dat cho', 'di dao', 'dan cho', 'walking'],
  BOARDING: ['trong giu', 'giu cho', 'giu meo', 'qua dem', 'boarding'],
  GROOMING: ['tam', 'cat tia', 'tia long', 'lam dep', 'grooming'],
};

export function loaiBeEpTheoDichVu(
  loaiDv?: ServiceType,
): 'dog' | 'cat' | undefined {
  return loaiDv === 'WALKING' ? 'dog' : undefined;
}

export function dichVuTuTuKhoa(tuKhoa: string): ServiceType | null {
  const khoa = boDau(tuKhoa);
  for (const [loai, tuDong] of Object.entries(TU_KHOA_DICH_VU)) {
    if (tuDong.some((t) => khoa.includes(t) || t.includes(khoa))) {
      return loai as ServiceType;
    }
  }
  return null;
}

export const LUOT_TOI_THIEU = 5;
const DIEM_TRUNG_BINH_HE_THONG = 4.5;
const DON_TOI_DA_TINH = 50;
const NGAY_NANG_NGUOI_MOI = 30;
const DON_TOI_THIEU_XET_HUY = 5;

// Cửa vào khối Được đánh giá cao ở trang chủ (bộ luật mục 9)
export const DIEM_TOI_THIEU_KHOI_NOI_BAT = 4.5;

// 5 sao của một lượt không đáng tin bằng 4,8 sao của trăm lượt (bộ luật mục 9)
export function diemDanhGiaCoTrongSo(
  ratingAvg: number,
  totalReviews: number,
): number {
  const v = totalReviews;
  return (
    (v / (v + LUOT_TOI_THIEU)) * ratingAvg +
    (LUOT_TOI_THIEU / (v + LUOT_TOI_THIEU)) * DIEM_TRUNG_BINH_HE_THONG
  );
}

export function diemTinh(e: {
  ratingAvg: number;
  totalReviews: number;
  completedOrders: number;
  trusted: boolean;
  cancelRate: number;
  duMauXetHuy: boolean;
}): number {
  const chatLuong = diemDanhGiaCoTrongSo(e.ratingAvg, e.totalReviews) / 5;

  const kinhNghiem =
    Math.log10(1 + Math.min(e.completedOrders, DON_TOI_DA_TINH)) /
    Math.log10(1 + DON_TOI_DA_TINH);

  const giuLoi = e.duMauXetHuy ? 1 - Math.min(e.cancelRate, 1) : 0.5;

  return (
    chatLuong * 0.35 + giuLoi * 0.2 + kinhNghiem * 0.1 + (e.trusted ? 0.05 : 0)
  );
}

export function duMauXetHuy(soDonDaNganNgu: number): boolean {
  return soDonDaNganNgu >= DON_TOI_THIEU_XET_HUY;
}

export function diemDong(
  e: {
    distanceKm: number | null;
    availableDays: number;
    selectedDays: number;
    totalReviews: number;
    createdAt: Date;
  },
  banKinhToiDaKm: number,
): number {
  const gan =
    e.distanceKm === null
      ? 0.5
      : Math.max(0, 1 - e.distanceKm / banKinhToiDaKm);

  const conTrong = e.selectedDays > 0 ? e.availableDays / e.selectedDays : 0.5;

  const soNgayHoatDong =
    (Date.now() - e.createdAt.getTime()) / (24 * 60 * 60 * 1000);
  const nangNguoiMoi =
    e.totalReviews < LUOT_TOI_THIEU || soNgayHoatDong <= NGAY_NANG_NGUOI_MOI
      ? 0.05
      : 0;

  return gan * 0.2 + conTrong * 0.1 + nangNguoiMoi;
}

const BAN_KINH_TRAI_DAT_KM = 6371;

export function giaThapNhat(
  type: ServiceType,
  pricing: unknown,
  goi?: string,
): number | null {
  if (pricing === null || typeof pricing !== 'object') return null;
  const p = pricing as Record<string, unknown>;
  const soDuong = (v: unknown) =>
    typeof v === 'number' && Number.isFinite(v) && v > 0 ? v : null;
  const nhoNhat = (ds: (number | null)[]) => {
    const hopLe = ds.filter((e): e is number => e !== null);
    return hopLe.length ? Math.min(...hopLe) : null;
  };
  switch (type) {
    case 'WALKING':
      return nhoNhat(Object.values(p.priceByDuration ?? {}).map(soDuong));
    case 'BOARDING':
      return soDuong(p.pricePerDay);
    case 'GROOMING': {
      const theoGoi = p.priceByPackage;
      if (theoGoi === null || typeof theoGoi !== 'object') return null;
      const bang = theoGoi as Record<string, unknown>;
      // Lọc theo gói nào thì chỉ nhìn giá của gói đó
      const canXet = goi === undefined ? Object.values(bang) : [bang[goi]];
      const tatCa: (number | null)[] = [];
      for (const mucCan of canXet) {
        if (mucCan === null || typeof mucCan !== 'object') continue;
        tatCa.push(
          ...Object.values(mucCan as Record<string, unknown>).map(soDuong),
        );
      }
      return nhoNhat(tatCa);
    }
    default:
      return null;
  }
}

export function coGoiGrooming(pricing: unknown, goi: string): boolean {
  return giaThapNhat('GROOMING', pricing, goi) !== null;
}

export function soBeToiDa(pricing: unknown): number | null {
  if (pricing === null || typeof pricing !== 'object') return null;
  const p = pricing as Record<string, unknown>;
  const so = (v: unknown) =>
    typeof v === 'number' && Number.isInteger(v) && v > 0 ? v : null;
  const mucs = [so(p.maxPets), so(p.capacity)].filter(
    (e): e is number => e !== null,
  );
  return mucs.length ? Math.min(...mucs) : null;
}

export function sucChua(pricing: unknown): number | null {
  if (pricing === null || typeof pricing !== 'object') return null;
  const v = (pricing as Record<string, unknown>).capacity;
  return typeof v === 'number' && Number.isInteger(v) && v > 0 ? v : null;
}

export const TRANG_THAI_GIU_CHO = [
  'PENDING',
  'AWAITING_OWNER_CONFIRM',
  'CONFIRMED',
  'IN_PROGRESS',
] as const;

export function khoangCachKm(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const rad = (do_: number) => (do_ * Math.PI) / 180;
  const dLat = rad(lat2 - lat1);
  const dLng = rad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin(dLng / 2) ** 2;
  return BAN_KINH_TRAI_DAT_KM * 2 * Math.asin(Math.sqrt(a));
}
