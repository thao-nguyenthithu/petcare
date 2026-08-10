import { xuLySlot, type XuLySlot } from '../../ai/ai-ket-luan';
import {
  LUOT_HONG_MO_VAN_XA,
  SO_LUOT_GUI_MOI_DON,
} from '../../ai/ai.constants';

export type DongQuet = {
  batchId: string;
  slotIndex: number;
  trangThai: string | null;
  code: string | null;
  confidence: number | null;
  canhDaiPx: number | null;
  tinhLuot: boolean;
  photoUrl: string;
  lat: number | null;
  lng: number | null;
};

export function cuaSlot(ds: DongQuet[], slot: number): DongQuet[] {
  return ds.filter((d) => d.slotIndex === slot);
}

// Một lô gửi là một lượt dù trong đó có mấy tấm (bộ luật mục 8)
export function luotDaTru(ds: DongQuet[]): number {
  return new Set(ds.filter((d) => d.tinhLuot).map((d) => d.batchId)).size;
}

export function conLai(ds: DongQuet[]): number {
  return Math.max(0, SO_LUOT_GUI_MOI_DON - luotDaTru(ds));
}

// Lô mà mọi dòng đều là lỗi nền tảng thì không trừ lượt nhưng vẫn phải đếm để mở van xả
export function loHongHaTang(ds: DongQuet[]): number {
  const theoLo = new Map<string, boolean>();
  for (const d of ds) {
    theoLo.set(d.batchId, (theoLo.get(d.batchId) ?? true) && !d.tinhLuot);
  }
  return [...theoLo.values()].filter(Boolean).length;
}

export function chotCuaSlot(ds: DongQuet[], slot: number): DongQuet | null {
  const daChot = cuaSlot(ds, slot).filter((d) => d.trangThai);
  return daChot.length ? daChot[daChot.length - 1] : null;
}

export function xuLyCuaSlot(ds: DongQuet[], slot: number): XuLySlot | null {
  const chot = chotCuaSlot(ds, slot);
  return chot ? xuLySlot(chot) : null;
}

export function slotXong(
  ds: DongQuet[],
  daXacNhan: ReadonlySet<number>,
  slot: number,
): boolean {
  return xuLyCuaSlot(ds, slot) === 'DI_TIEP' || daXacNhan.has(slot);
}

export function slotConThieu(
  ds: DongQuet[],
  daXacNhan: ReadonlySet<number>,
  soBe: number,
): number[] {
  const thieu: number[] = [];
  for (let slot = 1; slot <= soBe; slot++) {
    if (!slotXong(ds, daXacNhan, slot)) thieu.push(slot);
  }
  return thieu;
}

export function slotDaDat(ds: DongQuet[], slot: number): boolean {
  return xuLyCuaSlot(ds, slot) === 'DI_TIEP';
}

export function duocTuXacNhan(
  ds: DongQuet[],
  slot: number,
  conQuotaDon: boolean,
): boolean {
  const xuLy = xuLyCuaSlot(ds, slot);
  if (xuLy === 'DI_TIEP') return false;
  if (xuLy === 'TU_XAC_NHAN') return true;
  if (!conQuotaDon || conLai(ds) === 0) return true;
  return (
    luotDaTru(ds) >= LUOT_HONG_MO_VAN_XA ||
    loHongHaTang(ds) >= LUOT_HONG_MO_VAN_XA
  );
}

export function tranAnhMoiLuot(soBe: number): number {
  return (soBe + 1) * 2;
}
