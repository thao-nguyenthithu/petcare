export type TrangThaiBang = 'loading' | 'error' | 'success';

export function trangThaiBang(truyVan: { isPending: boolean; isError: boolean }): TrangThaiBang {
  if (truyVan.isPending) return 'loading';
  return truyVan.isError ? 'error' : 'success';
}
