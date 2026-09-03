import http from 'k6/http';
import { check } from 'k6';

// Tham số dùng chung cho mọi kịch bản k6, đọc từ biến môi trường thay vì hardcode
// Chạy: k6 run -e BASE_URL=... -e LOAD_EMAIL=... -e LOAD_PASSWORD=... load-test/<file>.js
export const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000/api/v1';
export const LOAD_EMAIL = __ENV.LOAD_EMAIL;
export const LOAD_PASSWORD = __ENV.LOAD_PASSWORD;
// Toạ độ mẫu Hà Nội, đổi qua -e nếu muốn test vùng khác
export const LAT = Number(__ENV.LOAD_LAT || 21.0278);
export const LNG = Number(__ENV.LOAD_LNG || 105.8342);

export function dangNhap() {
  if (!LOAD_EMAIL || !LOAD_PASSWORD) {
    throw new Error(
      'Thiếu LOAD_EMAIL/LOAD_PASSWORD, truyền qua -e khi chạy k6 (dùng tài khoản test riêng, không dùng tài khoản thật)',
    );
  }
  const res = http.post(
    `${BASE_URL}/auth/login`,
    JSON.stringify({ email: LOAD_EMAIL, password: LOAD_PASSWORD }),
    { headers: { 'Content-Type': 'application/json' } },
  );
  // POST không @HttpCode(200) nên Nest trả 201 mặc định, không phải lỗi
  check(res, { 'đăng nhập thành công (201)': (r) => r.status === 201 });
  const token = res.json('accessToken');
  if (!token) {
    throw new Error(`Đăng nhập thất bại, status=${res.status} body=${res.body}`);
  }
  return token;
}

export function authHeader(token) {
  return { headers: { Authorization: `Bearer ${token}` } };
}
