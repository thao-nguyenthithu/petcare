import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, LAT, LNG, dangNhap, authHeader } from './_chung.js';

// Bước 1 theo kế hoạch báo cáo mục 5.4: 5 người dùng ảo trong vài phút,
// chỉ xác nhận API trả đúng kết quả dưới tải nhẹ, chưa xét ngưỡng thời gian
export const options = {
  vus: 5,
  duration: '3m',
  thresholds: {
    http_req_failed: ['rate<0.01'],
  },
};

// Đăng nhập một lần duy nhất khi khởi động, chia sẻ token cho mọi VU/iteration —
// gọi lại /auth/login mỗi iteration sẽ tự chạm trần 20 req/phút của nhóm xác thực
// (bộ luật mục 12), không phản ánh cách người dùng thật giữ phiên JWT 30 ngày.
export function setup() {
  return { token: dangNhap() };
}

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

  sleep(1);
}
