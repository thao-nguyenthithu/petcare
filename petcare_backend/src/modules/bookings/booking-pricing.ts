import { BadRequestException } from '@nestjs/common';
import { MOT_NGAY_MS } from '../../common/thoi-gian-vn';
import { chiaDem, dong, phiHuy } from '../../common/tien';
import { BacGiuThem, bacGiuThem, phiGiuThem } from './booking-time';

export const TRAN_BE_WALKING = 5;
export const TRAN_PHUT_GROOMING = 8 * 60;
export const NGAY_CHIU_PHI_HUY = 7;

export type GoiGrooming = 'bath' | 'bathAndTrim';
export type MucCan = 'duoi5' | 'tu5den10' | 'tu10den20' | 'tren20';

export type DongGia = {
  key: string;
  amount: number;
  petId?: string;
  meta?: Record<string, number | string>;
};

export type GiaCuaBe = {
  petId: string;
  packageCode: GoiGrooming;
  durationMinutes: number;
  price: number;
};

export type KetQuaGia = {
  total: number;
  lines: DongGia[];
  perPet: GiaCuaBe[];
  durationMinutes: number | null;
};

type Pricing = Record<string, unknown>;

export type BeTinhGia = {
  id: string;
  weightKg: number;
  packageCode?: GoiGrooming;
};

function loi(code: string, message: string): never {
  throw new BadRequestException({ code, message });
}

function soNguyenDuong(v: unknown): number | null {
  return typeof v === 'number' && Number.isFinite(v) && v > 0
    ? Math.floor(v)
    : null;
}

function bang(pricing: Pricing, khoa: string): Record<string, unknown> {
  const o = pricing[khoa];
  return o && typeof o === 'object' ? (o as Record<string, unknown>) : {};
}

export function mucCanCua(kg: number): MucCan {
  if (kg < 5) return 'duoi5';
  if (kg <= 10) return 'tu5den10';
  if (kg <= 20) return 'tu10den20';
  return 'tren20';
}

export function soBeToiDa(pricing: Pricing): number {
  return soNguyenDuong(pricing.maxPets) ?? 1;
}

export function sucChuaTrongGiu(pricing: Pricing): number {
  return soNguyenDuong(pricing.capacity) ?? 0;
}

function phuPhiBeThem(pricing: Pricing): number {
  return soNguyenDuong(pricing.additionalPetFee) ?? 0;
}

export function tinhGiaWalking(
  pricing: Pricing,
  soBe: number,
  durationMinutes: number,
): KetQuaGia {
  const giaGoi = soNguyenDuong(
    bang(pricing, 'priceByDuration')[durationMinutes],
  );
  if (giaGoi === null) {
    loi(
      'THIEU_GIA_DICH_VU',
      `Người chăm chưa báo giá cho lượt ${durationMinutes} phút`,
    );
  }
  const phuPhi = phuPhiBeThem(pricing) * (soBe - 1);
  const lines: DongGia[] = [
    {
      key: 'goiDat',
      amount: giaGoi,
      meta: { durationMinutes },
    },
  ];
  if (soBe > 1) {
    lines.push({
      key: 'phuPhiBeThem',
      amount: phuPhi,
      meta: { soBeThem: soBe - 1, moiBe: phuPhiBeThem(pricing) },
    });
  }
  return {
    total: giaGoi + phuPhi,
    lines,
    perPet: [],
    durationMinutes,
  };
}

export function tinhGiaBoarding(
  pricing: Pricing,
  soBe: number,
  soDem: number,
  phutGiuThemDon: number,
): KetQuaGia & { bacGiuThem: BacGiuThem } {
  const giaDem = soNguyenDuong(pricing.pricePerDay);
  if (giaDem === null) {
    loi('THIEU_GIA_DICH_VU', 'Người chăm chưa báo giá trông giữ theo đêm');
  }
  const moiBeThem = phuPhiBeThem(pricing);
  const phuPhiMoiDem = moiBeThem * (soBe - 1);
  const giaMotDemCaDon = giaDem + phuPhiMoiDem;
  const bac = bacGiuThem(phutGiuThemDon);
  const phiThem = phiGiuThem(phutGiuThemDon, giaMotDemCaDon);
  const lines: DongGia[] = [
    { key: 'giaDemBeDau', amount: giaDem * soDem, meta: { soDem, giaDem } },
  ];
  if (soBe > 1) {
    lines.push({
      key: 'phuPhiBeThemMoiDem',
      amount: phuPhiMoiDem * soDem,
      meta: { soBeThem: soBe - 1, moiBe: moiBeThem, soDem },
    });
  }
  if (phiThem > 0) {
    lines.push({
      key: 'phiGiuThem',
      amount: phiThem,
      meta: { phutGiuThem: phutGiuThemDon, bac },
    });
  }
  return {
    total: giaMotDemCaDon * soDem + phiThem,
    lines,
    perPet: [],
    durationMinutes: null,
    bacGiuThem: bac,
  };
}

export function tinhGiaGrooming(
  pricing: Pricing,
  pets: BeTinhGia[],
): KetQuaGia {
  const bangGia = bang(pricing, 'priceByPackage');
  const bangPhut = bang(pricing, 'durationByPackage');
  const lines: DongGia[] = [];
  const perPet: GiaCuaBe[] = [];
  let tong = 0;
  let tongPhut = 0;
  for (const be of pets) {
    const goi = be.packageCode;
    if (!goi) {
      loi('THIEU_GOI_GROOMING', 'Chưa chọn gói cho một trong các bé');
    }
    const muc = mucCanCua(be.weightKg);
    const gia = soNguyenDuong(
      (bangGia[goi] as Record<string, unknown> | undefined)?.[muc],
    );
    const phut = soNguyenDuong(
      (bangPhut[goi] as Record<string, unknown> | undefined)?.[muc],
    );
    if (gia === null || phut === null) {
      loi(
        'THIEU_GIA_DICH_VU',
        'Người chăm chưa báo giá cho gói hoặc mức cân của bé này',
      );
    }
    tong += gia;
    tongPhut += phut;
    perPet.push({
      petId: be.id,
      packageCode: goi,
      durationMinutes: phut,
      price: gia,
    });
    lines.push({
      key: 'goiCuaBe',
      amount: gia,
      petId: be.id,
      meta: { packageCode: goi, weightTier: muc, durationMinutes: phut },
    });
  }
  if (tongPhut > TRAN_PHUT_GROOMING) {
    loi(
      'VUOT_THOI_LUONG_BUOI',
      `Tổng thời lượng của đơn là ${Math.round(tongPhut / 60)} giờ, vượt mức ${TRAN_PHUT_GROOMING / 60} giờ một buổi. Bớt bé hoặc đổi gói rồi thử lại`,
    );
  }
  return { total: tong, lines, perPet, durationMinutes: tongPhut };
}

export function tinhKetThucSom(
  tongTien: number,
  soDem: number,
  phanTramPhiHuy: number,
  batDau: Date,
  soDemDaO: number,
  bamLuc: number = Date.now(),
): { chuNuoiTra: number; duocHoan: number; O: number; C: number; K: number } {
  const tong = dong(tongTien);
  const giaTungDem = chiaDem(tong, soDem);
  const O = Math.max(0, Math.min(soDemDaO, soDem));
  const C = soDem - O;
  const hanChiuPhi = bamLuc + NGAY_CHIU_PHI_HUY * MOT_NGAY_MS;
  let tienDaO = 0;
  let tienChiuPhi = 0;
  let K = 0;
  for (let i = 0; i < soDem; i++) {
    if (i < O) {
      tienDaO += giaTungDem[i];
      continue;
    }
    if (batDau.getTime() + i * MOT_NGAY_MS < hanChiuPhi) {
      tienChiuPhi += giaTungDem[i];
      K++;
    }
  }
  const chuNuoiTra = tienDaO + phiHuy(tienChiuPhi, phanTramPhiHuy);
  return { chuNuoiTra, duocHoan: tong - chuNuoiTra, O, C, K };
}
