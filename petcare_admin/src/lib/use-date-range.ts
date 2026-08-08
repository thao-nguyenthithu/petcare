import { useState } from 'react';

export type KhoangNgay = '7' | '30' | '90';

const MOT_NGAY_MS = 24 * 3600_000;

function mocIso(moc: number): string {
  return new Date(moc).toISOString();
}

export function useDateRange(dinhDangMoc: (moc: number) => string = mocIso) {
  const [khoangNgay, setKhoangNgay] = useState<KhoangNgay | null>(null);
  const [tuNgay, setTuNgay] = useState<string | undefined>(undefined);

  const chon = (value: KhoangNgay | null) => {
    setKhoangNgay(value);
    setTuNgay(value ? dinhDangMoc(Date.now() - Number(value) * MOT_NGAY_MS) : undefined);
  };

  return { khoangNgay, tuNgay, chon, xoa: () => chon(null) };
}
