// Khoảng cách đường chim bay giữa hai toạ độ
const BAN_KINH_TRAI_DAT_KM = 6371;

function radian(do_: number): number {
  return (do_ * Math.PI) / 180;
}

export function khoangCachKm(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const dLat = radian(lat2 - lat1);
  const dLng = radian(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(radian(lat1)) * Math.cos(radian(lat2)) * Math.sin(dLng / 2) ** 2;
  return BAN_KINH_TRAI_DAT_KM * 2 * Math.asin(Math.sqrt(a));
}
