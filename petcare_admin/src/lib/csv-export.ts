const LIMIT_MOI_LUOT = 50;
const SO_LUOT_TOI_DA = 20;

export const TRAN_DONG_XUAT = LIMIT_MOI_LUOT * SO_LUOT_TOI_DA;

type TrangDuLieu<T> = { total: number; items: T[] };

export class VuotTranXuatError extends Error {
  readonly total: number;

  constructor(total: number) {
    super('Vượt trần dòng xuất');
    this.name = 'VuotTranXuatError';
    this.total = total;
  }
}

export async function gomMoiTrang<T>(
  tai: (page: number, limit: number) => Promise<TrangDuLieu<T>>,
): Promise<T[]> {
  const dauTien = await tai(1, LIMIT_MOI_LUOT);
  if (dauTien.total > TRAN_DONG_XUAT) throw new VuotTranXuatError(dauTien.total);

  const gom = [...dauTien.items];
  for (let page = 2; page <= SO_LUOT_TOI_DA && gom.length < dauTien.total; page += 1) {
    const trang = await tai(page, LIMIT_MOI_LUOT);
    if (trang.items.length === 0) break;
    gom.push(...trang.items);
  }
  return gom;
}

function boc(value: string | number | null | undefined): string {
  if (value === null || value === undefined) return '""';
  return `"${String(value).replace(/"/g, '""')}"`;
}

export function dungCsv(tieuDe: string[], dong: Array<Array<string | number | null>>): string {
  return [tieuDe, ...dong].map((hang) => hang.map(boc).join(',')).join('\r\n');
}

export function taiVeCsv(noiDung: string, tenFile: string) {
  const blob = new Blob([`\ufeff${noiDung}`], { type: 'text/csv;charset=utf-8;' });
  const url = URL.createObjectURL(blob);
  const the = document.createElement('a');
  the.href = url;
  the.download = tenFile;
  the.click();
  URL.revokeObjectURL(url);
}
