export function maGiaoDichGia(txnRef: string): string {
  let tong = 0;
  for (const ky of txnRef) tong = (tong * 31 + ky.charCodeAt(0)) % 100000000;
  return String(10000000 + tong).slice(0, 8);
}
