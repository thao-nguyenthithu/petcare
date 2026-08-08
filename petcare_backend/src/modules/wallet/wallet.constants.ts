
export const PHI_CHUYEN = 0;

export const TIEN_TO_MA = {
  TIEN_VAO: 'GD',
  RUT_RA: 'RT',
  DIEU_CHINH: 'DC',
} as const;

export function maGiaoDichVi(
  loai: keyof typeof TIEN_TO_MA,
  luc = new Date(),
): string {
  const so = luc.getTime().toString().slice(-7);
  return `${TIEN_TO_MA[loai]}-${so}`;
}
