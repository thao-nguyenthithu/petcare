import http from 'k6/http';
import { check, sleep } from 'k6';
import { BASE_URL, LAT, LNG, dangNhap, authHeader } from './_chung.js';

// Tăng tải ĐỘT BIẾN trong thời gian cực ngắn (giả lập một chương trình khuyến mãi
// hay một link được chia sẻ rộng) rồi rút ngay, xem hệ thống có hồi phục về bình
// thường sau đỉnh hay không. Cùng giới hạn với 03-stress-test.js: trần 300
// request/phút/IP sẽ chặn phần lớn đỉnh tải khi bắn từ một máy, nên phần đọc kết quả
// nên nhìn ĐƯỜNG BIỂU DIỄN theo thời gian (http_req_failed, http_req_duration theo
// từng giai đoạn) hơn là một con số tổng — xem có tụt về bình thường sau khi rút tải.
// Muốn vượt trần 300/phút để đo đúng đỉnh: xem mục "Bắn từ nhiều IP" ở README.
export function setup() {
  return { token: dangNhap() };
}

export const options = {
  stages: [
    { duration: '10s', target: 10 }, // mức nền
    { duration: '10s', target: 150 }, // đột biến
    { duration: '30s', target: 150 }, // giữ đỉnh ngắn
    { duration: '10s', target: 10 }, // rút tải ngay
    { duration: '2m', target: 10 }, // theo dõi hồi phục
  ],
};

export default function (data) {
  const auth = authHeader(data.token);
  const res = http.get(
    `${BASE_URL}/search/sitters?lat=${LAT}&lng=${LNG}&radiusKm=10&page=1&limit=20`,
    auth,
  );
  check(res, { 'không sập 5xx': (r) => r.status < 500 });
  sleep(1);
}
