import { xuLySlot, type XuLySlot } from '../../ai/ai-ket-luan';
import { SO_LUOT_CHUP_MOI_BE } from '../../ai/ai.constants';

export type DongQuet = {
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

export function luotDaTru(ds: DongQuet[], slot: number): number {
  return cuaSlot(ds, slot).filter((d) => d.tinhLuot).length;
}

export function conLai(ds: DongQuet[], slot: number): number {
  return Math.max(0, SO_LUOT_CHUP_MOI_BE - luotDaTru(ds, slot));
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
  return conLai(ds, slot) === 0 || !conQuotaDon;
}

export function tranAnhMoiLuot(soBe: number): number {
  return (soBe + 1) * 2;
}
