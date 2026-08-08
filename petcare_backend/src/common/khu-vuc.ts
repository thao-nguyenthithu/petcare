// Rút địa chỉ đầy đủ về 2 cấp Phường, Tỉnh/Thành phố
const BO_QUA = /^(việt nam|vietnam|vn)$/i;

const CAP_PHUONG = /^(phường|phuong|xã|xa|thị trấn|thi tran|p\.|tt\.|x\.)\s/i;

export function khuVucHaiCap(diaChiDayDu: string | null): string | null {
  const phan = (diaChiDayDu ?? '')
    .split(',')
    .map((e) => e.trim())
    .filter((e) => e.length > 0)
    .filter((e) => !/^\d+$/.test(e) && !BO_QUA.test(e));

  if (phan.length === 0) return null;
  const tinh = phan[phan.length - 1];
  const phuong = phan.slice(0, -1).find((e) => CAP_PHUONG.test(e));
  return phuong ? `${phuong}, ${tinh}` : tinh;
}
