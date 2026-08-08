import type { TFunction } from 'i18next';
import type { ServicePricing } from '@/features/services/types';
import { formatMoney } from '@/lib/format';

function nhanKhoa(t: TFunction, key: string): string {
  return t(`dichVu.nhanKhoa.${key}`, { defaultValue: key });
}

export function tomTatBangGia(t: TFunction, pricing: ServicePricing): string {
  if (pricing.type === 'WALKING') return tomTatDat(t, pricing);
  if (pricing.type === 'BOARDING') return tomTatTrongGiu(t, pricing);
  return tomTatGrooming(t, pricing);
}

function tomTatDat(
  t: TFunction,
  pricing: Extract<ServicePricing, { type: 'WALKING' }>,
): string {
  const phan = Object.entries(pricing.priceByDuration).map(([phut, gia]) =>
    t('dichVu.bangGia.luotDat', { phut, gia: formatMoney(gia) }),
  );
  if (pricing.additionalPetFee !== null) {
    phan.push(t('dichVu.bangGia.beThem', { gia: formatMoney(pricing.additionalPetFee) }));
  }
  return phan.join(' · ');
}

function tomTatTrongGiu(
  t: TFunction,
  pricing: Extract<ServicePricing, { type: 'BOARDING' }>,
): string {
  const phan: string[] = [];
  if (pricing.pricePerDay !== null) {
    phan.push(t('dichVu.bangGia.moiDem', { gia: formatMoney(pricing.pricePerDay) }));
  }
  if (pricing.capacity !== null) {
    phan.push(t('dichVu.bangGia.sucChua', { count: pricing.capacity }));
  }
  if (pricing.additionalPetFee !== null) {
    phan.push(t('dichVu.bangGia.beThem', { gia: formatMoney(pricing.additionalPetFee) }));
  }
  return phan.join(' · ');
}

function tomTatGrooming(
  t: TFunction,
  pricing: Extract<ServicePricing, { type: 'GROOMING' }>,
): string {
  return Object.entries(pricing.priceByPackage)
    .map(([goi, theoBac]) => {
      const bac = Object.entries(theoBac)
        .map(([khoa, gia]) =>
          t('dichVu.bangGia.bacVaGia', { bac: nhanKhoa(t, khoa), gia: formatMoney(gia) }),
        )
        .join(', ');
      return t('dichVu.bangGia.goiVaBac', { goi: nhanKhoa(t, goi), bac });
    })
    .join(' · ');
}

export function danhSachRangBuoc(t: TFunction, numbers: number[], keys: string[]): string {
  return keys.length ? keys.map((key) => nhanKhoa(t, key)).join(' · ') : numbers.join(' · ');
}
