// Định dạng tiền cho backend sinh ra
export function tienVn(so: number): string {
  return `${so.toLocaleString('vi-VN')}đ`;
}
