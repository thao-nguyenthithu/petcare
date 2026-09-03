// Công tắc diễn thử: đặt DEMO_MO_CUA_THOI_GIAN=true mở sẵn mọi cửa giờ, vận hành thật để trống
export function moMoiCuaThoiGian(): boolean {
  return process.env.DEMO_MO_CUA_THOI_GIAN === 'true';
}
