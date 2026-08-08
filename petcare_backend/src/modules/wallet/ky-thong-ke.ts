import {
  LECH_VN_MS,
  MOT_NGAY_MS,
  ngayThangVn,
} from '../../common/thoi-gian-vn';
import { dauNamVn, dauThangVn, dauTuanVn } from './wallet.service';


export type Ky = 'week' | 'month' | 'year';

const MOC_KHOI_TUAN = [1, 8, 15, 22];

export function dauKy(ky: Ky, bayGio: Date): Date {
  if (ky === 'week') return dauTuanVn(bayGio);
  if (ky === 'month') return dauThangVn(bayGio);
  return dauNamVn(bayGio);
}

export function luiMotKy(ky: Ky, tu: Date): Date {
  if (ky === 'week') return new Date(tu.getTime() - 7 * MOT_NGAY_MS);
  const t = new Date(tu.getTime() + LECH_VN_MS);
  if (ky === 'month') {
    return new Date(
      Date.UTC(t.getUTCFullYear(), t.getUTCMonth() - 1, 1) - LECH_VN_MS,
    );
  }
  return new Date(Date.UTC(t.getUTCFullYear() - 1, 0, 1) - LECH_VN_MS);
}

export function chiSoCot(ky: Ky, tu: Date, moc: Date): number {
  if (ky === 'week') {
    return Math.floor((moc.getTime() - tu.getTime()) / MOT_NGAY_MS);
  }
  const t = new Date(moc.getTime() + LECH_VN_MS);
  if (ky === 'month') {
    const ngay = t.getUTCDate();
    for (let i = MOC_KHOI_TUAN.length - 1; i >= 0; i--) {
      if (ngay >= MOC_KHOI_TUAN[i]) return i;
    }
    return 0;
  }
  return t.getUTCMonth();
}

export function nhanCot(ky: Ky): string[] {
  if (ky === 'week') return ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  if (ky === 'month') return ['T1', 'T2', 'T3', 'T4'];
  return Array.from({ length: 12 }, (_, i) => `T${i + 1}`);
}

export function tieuDeBieuDo(ky: Ky): string {
  return { week: 'Theo ngày', month: 'Theo tuần', year: 'Theo tháng' }[ky];
}

export function dungCot(
  ky: Ky,
  tu: Date,
  bayGio: Date,
  soLieu: { amount: number; moc: Date }[],
) {
  const nhan = nhanCot(ky);
  const tien = nhan.map(() => 0);
  for (const s of soLieu) {
    const i = chiSoCot(ky, tu, s.moc);
    if (i >= 0 && i < tien.length) tien[i] += s.amount;
  }
  const hienTai = chiSoCot(ky, tu, bayGio);
  return {
    bars: nhan.map((label, i) => ({
      label,
      amount: tien[i],
      upcoming: i > hienTai,
    })),
    highlightBar: Math.max(0, Math.min(hienTai, nhan.length - 1)),
  };
}

export function nhanKy(ky: Ky, tu: Date, bayGio: Date): string {
  const t = new Date(bayGio.getTime() + LECH_VN_MS);
  if (ky === 'week') {
    const den = new Date(tu.getTime() + 6 * MOT_NGAY_MS);
    return `Tuần này · ${ngayThangVn(tu)} – ${ngayThangVn(den)}`;
  }
  if (ky === 'month') {
    return `Tháng này · ${t.getUTCMonth() + 1}/${t.getUTCFullYear()}`;
  }
  return `Năm nay · ${t.getUTCFullYear()}`;
}

export function phanTramDoi(tong: number, tongTruoc: number): number | null {
  return tongTruoc > 0
    ? Math.round(((tong - tongTruoc) / tongTruoc) * 100)
    : null;
}
