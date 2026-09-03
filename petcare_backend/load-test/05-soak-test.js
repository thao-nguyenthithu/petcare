import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, LAT, LNG, dangNhap, authHeader } from './_chung.js';

// Giữ tải TRUNG BÌNH liên tục trong thời gian dài để bắt rò rỉ bộ nhớ, cạn kết nối
// DB (Prisma pool qua pgbouncer), hay chỉ số suy giảm dần theo thời gian mà lượt tải
// ngắn không thấy được. Mặc định 2 giờ cho phù hợp lịch đồ án; soak test "chuẩn" hay
// chạy 4-24 giờ, tăng bằng -e LOAD_SOAK_DURATION=8h khi cần đo dài hơn. VU giữ THẤP
// (mặc định 15) để tổng tải nằm dưới trần 300 request/phút/IP xuyên suốt.
export function setup() {
  return { token: dangNhap() };
}

export const options = {
  vus: Number(__ENV.LOAD_SOAK_VUS || 15),
  duration: __ENV.LOAD_SOAK_DURATION || '2h',
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function (data) {
  const auth = authHeader(data.token);
  const timKiem = http.get(
    `${BASE_URL}/search/sitters?lat=${LAT}&lng=${LNG}&radiusKm=10&page=1&limit=20`,
    auth,
  );
  check(timKiem, { 'tìm kiếm 200': (r) => r.status === 200 });

  const ds = timKiem.json('items');
  if (Array.isArray(ds) && ds.length > 0) {
    const hoSo = http.get(`${BASE_URL}/sitters/${ds[0].id}`, auth);
    check(hoSo, { 'xem hồ sơ 200': (r) => r.status === 200 });
  }

  sleep(2);
}
