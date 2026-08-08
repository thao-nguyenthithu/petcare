export function phiNenTang(doanhThu: number, phanTram: number): number {
  return Math.floor((dong(doanhThu) * phanTram) / 100);
}

// Phí huỷ muộn chủ nuôi chịu
export function phiHuy(giaDon: number, phanTram: number): number {
  return Math.floor((dong(giaDon) * phanTram) / 100);
}

// Toàn bộ phần dư dồn vào đêm cuối
export function chiaDem(tongTien: number, soDem: number): number[] {
  const tong = dong(tongTien);
  if (soDem < 1) return [];
  const moiDem = Math.floor(tong / soDem);
  const ds = Array<number>(soDem).fill(moiDem);
  ds[soDem - 1] = tong - moiDem * (soDem - 1);
  return ds;
}

export function dong(so: number | null | undefined): number {
  return Number.isFinite(so) ? Math.floor(so as number) : 0;
}

export function soDong(
  so: bigint | number | string | null | undefined,
): number {
  return so == null ? 0 : Number(so);
}
