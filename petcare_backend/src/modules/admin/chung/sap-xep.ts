// Cột lạ rơi về mặc định, không ai dò được sơ đồ bảng bằng cách thử tên cột
export function chonCot<T extends string>(
  choPhep: readonly T[],
  cot: string | undefined,
  macDinh: T,
): T {
  return cot !== undefined && (choPhep as readonly string[]).includes(cot)
    ? (cot as T)
    : macDinh;
}

export type Chieu = 'asc' | 'desc';

export function chonChieu(chieu: string | undefined, macDinh: Chieu): Chieu {
  if (chieu === 'asc' || chieu === 'desc') return chieu;
  return macDinh;
}
