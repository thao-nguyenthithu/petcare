import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter } from 'k6/metrics';
import { BASE_URL, LAT, LNG, dangNhap, authHeader } from './_chung.js';

// Tăng tải LIÊN TỤC vượt mức bình thường để tìm điểm hệ thống "sập" (trả lỗi 5xx
// hoặc treo) thay vì chỉ từ chối có kiểm soát. GIỚI HẠN QUAN TRỌNG: trần 300
// request/phút/IP (bộ luật mục 12) áp cho MỌI IP kể cả máy chạy k6, nên chạy từ một
// máy sẽ chạm trần rate-limit rất sớm (chỉ khoảng 20-30 VU ở luồng 2 request/vòng)
// trước khi chạm sức chịu thật của backend/DB. Kết quả vì vậy trả lời được câu hỏi
// "hệ thống có sập (5xx) khi bị dội tải không" chứ CHƯA đo được sức chịu tải thật —
// muốn vượt trần để đo đúng đỉnh: xem mục "Bắn từ nhiều IP" ở README.
export function setup() {
  return { token: dangNhap() };
}

export const options = {
  stages: [
    { duration: '2m', target: 20 },
    { duration: '3m', target: 60 },
    { duration: '3m', target: 120 },
    { duration: '3m', target: 200 },
    { duration: '2m', target: 0 },
  ],
};

const so2xx = new Counter('so_luong_2xx');
const so429 = new Counter('so_luong_429');
const so5xx = new Counter('so_luong_5xx');

export default function (data) {
  const auth = authHeader(data.token);
  const res = http.get(
    `${BASE_URL}/search/sitters?lat=${LAT}&lng=${LNG}&radiusKm=10&page=1&limit=20`,
    auth,
  );
  if (res.status >= 200 && res.status < 300) so2xx.add(1);
  else if (res.status === 429) so429.add(1);
  else if (res.status >= 500) so5xx.add(1);

  // Tiêu chí sống còn của stress test: từ chối có kiểm soát (429) chấp nhận được,
  // SẬP (5xx) thì không — đây là điều duy nhất bắt buộc phải đúng dù tải cao tới đâu
  check(res, { 'không sập 5xx dù tải cao': (r) => r.status < 500 });
  sleep(1);
}

export function handleSummary(data) {
  const tong5xx = data.metrics.so_luong_5xx?.values?.count ?? 0;
  console.log(
    tong5xx > 0
      ? `PHÁT HIỆN ${tong5xx} lỗi 5xx dưới tải cao — có điểm sập thật, cần soát lại`
      : 'Không có lỗi 5xx nào dù tải tăng dần tới 200 VU — hệ thống chỉ từ chối có kiểm soát (429), chưa sập',
  );
  return { stdout: JSON.stringify(data, null, 2) };
}
