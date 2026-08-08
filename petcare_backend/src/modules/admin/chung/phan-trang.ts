// Trần cứng phía máy chủ, số lớn hơn bị KẸP về đây chứ không báo lỗi
export const TRAN_MOI_TRANG = 50;
export const MOI_TRANG_MAC_DINH = 20;

export type KetQuaTrang<T> = {
  total: number;
  page: number;
  limit: number;
  items: T[];
};

export type KhoangTrang = { trang: number; moiTrang: number; boQua: number };

export function kepTrang(page?: number, limit?: number): KhoangTrang {
  const trang = Math.max(1, Math.trunc(page ?? 1));
  const moiTrang = Math.min(
    TRAN_MOI_TRANG,
    Math.max(1, Math.trunc(limit ?? MOI_TRANG_MAC_DINH)),
  );
  return { trang, moiTrang, boQua: (trang - 1) * moiTrang };
}

export function dungTrang<T>(
  items: T[],
  total: number,
  khoang: KhoangTrang,
): KetQuaTrang<T> {
  return { total, page: khoang.trang, limit: khoang.moiTrang, items };
}
