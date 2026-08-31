import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, LAT, LNG, dangNhap, authHeader } from './_chung.js';

// Bước 2 theo kế hoạch báo cáo mục 5.4: tăng dần tới 50 người dùng ảo, giữ vài phút,
// mô phỏng chuỗi hành vi chủ nuôi: đăng nhập, tìm kiếm theo toạ độ (nặng nhất vì qua
// PostGIS), xem chi tiết một người chăm. Tiêu chí đạt: p95 < 500ms, tỷ lệ lỗi < 1%.
export const options = {
  stages: [
    { duration: '1m', target: 50 },
    { duration: '5m', target: 50 },
    { duration: '1m', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

// Bước tạo đơn ghi dữ liệu thật (booking + giữ tiền), mặc định TẮT để không bơm rác
// vào Supabase thật mỗi lần chạy. Chỉ bật khi đã có tài khoản/thú cưng/địa chỉ test riêng.
const CHAY_BUOC_TAO_DON = __ENV.LOAD_TAO_DON === 'true';
const PET_ID = __ENV.LOAD_PET_ID;
const ADDRESS_ID = __ENV.LOAD_ADDRESS_ID;

// Đăng nhập một lần duy nhất khi khởi động — lý do xem 01-chay-khoi.js
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
  const ncc = Array.isArray(ds) && ds.length > 0 ? ds[0] : null;
  if (ncc) {
    const hoSo = http.get(`${BASE_URL}/sitters/${ncc.id}`, auth);
    check(hoSo, { 'xem hồ sơ 200': (r) => r.status === 200 });
  }

  if (CHAY_BUOC_TAO_DON && ncc && PET_ID && ADDRESS_ID) {
    const don = http.post(
      `${BASE_URL}/bookings`,
      JSON.stringify({
        sitterId: ncc.id,
        serviceType: 'walking',
        petIds: [PET_ID],
        addressId: ADDRESS_ID,
        startDate: __ENV.LOAD_NGAY || '2026-12-01',
        startTime: '09:00',
        gearCommitted: true,
      }),
      { headers: { 'Content-Type': 'application/json', ...auth.headers } },
    );
    check(don, { 'tạo đơn 201': (r) => r.status === 201 });
  }

  sleep(1);
}
