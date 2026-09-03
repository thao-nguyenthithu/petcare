# Kết quả kiểm thử tải — đo thật trên Railway

Ngày đo: 11/08/2026. Đích: `https://petcare-backend.up.railway.app/api/v1` (hệ thống thật,
DB Supabase Singapore). Máy đo: một máy dev, một địa chỉ IP. Tài khoản test do Kendra cấp.

Tiêu chí đạt đã chốt ở báo cáo mục 5.4: **p95 < 500ms** và **tỷ lệ lỗi < 1%**.

## Bảng kết quả

| Kịch bản | Tải | Số request | p95 | 2xx | 429 | 5xx |
|---|---|---|---|---|---|---|
| 01 Smoke | 5 VU, 3 phút | 621 | 465ms | 100% | 0 | 0 |
| 02 Load | 50 VU, 7 phút | 12.497 | 456ms | 75,9% | 3.006 | 0 |
| 03 Stress | 20→200 VU, 13 phút | 45.413 | 451ms | 16.675 | 28.737 | 0 |
| 04 Spike | 10→150 VU đột biến, 3 phút | 5.178 | 450ms | 44,3% | 2.882 | 0 |
| 05 Soak | 5 VU, 20 phút | 2.473 | 477ms | 100% | 0 | 0 |

## Đọc kết quả

**p95 đạt tiêu chí ở CẢ NĂM kịch bản** (450-477ms, đều dưới ngưỡng 500ms), kể cả lúc dội
200 VU. Latency gần như không đổi giữa tải nhẹ và tải nặng, cho thấy backend không phải là
nút thắt — phần lớn thời gian là độ trễ mạng tới Supabase Singapore.

**Không có một lỗi 5xx nào trong tổng 66.182 request** của cả năm lượt đo. Đây là tiêu chí
sống còn của Stress/Spike: hệ thống từ chối có kiểm soát (429) chứ không sập.

**Tỷ lệ lỗi < 1% đạt ở Smoke và Soak (0%)** — hai kịch bản có tải nằm dưới trần IP. Ở Load,
Stress và Spike, con số `http_req_failed` cao (24%, 63%, 56%) **toàn bộ là mã 429 do trần
300 yêu cầu/phút/IP** (bộ luật mục 12) chặn lại, không phải backend quá tải. Nguyên nhân:
k6 chạy từ một máy nên mọi VU dùng chung một IP, riêng Load đã bắn ~30 req/s ≈ 1.800
req/phút, gấp 6 lần trần. Đây là hành vi ĐÚNG THIẾT KẾ, đồng thời là bằng chứng cơ chế
chống lạm dụng hoạt động thật dưới tải cao.

**Soak không phát hiện suy giảm**: nửa đầu 1.225 vòng, nửa sau 1.247 vòng — thông lượng
ổn định, không có dấu hiệu rò rỉ bộ nhớ hay cạn kết nối DB trong 20 phút.

## Giới hạn của phép đo này

Sức chịu tải THẬT của backend/DB chưa đo được, vì trần IP chặn trước khi hệ thống chạm
giới hạn thật. Muốn biết đỉnh thật phải bắn từ nhiều IP — xem mục "Bắn từ nhiều IP" ở
`README.md` (cần 2-3 máy có IP khác nhau, hoặc tài khoản k6 Cloud).

Soak chạy 20 phút thay vì 2-24 giờ như thông lệ, đủ để loại trừ rò rỉ nhanh nhưng chưa
loại trừ được rò rỉ chậm. Lệnh chạy bản đầy đủ có trong `README.md`.

Bước tạo đơn (ghi booking thật vào DB) không bật trong các lượt đo này, nên số liệu phản
ánh đường đọc (đăng nhập, tìm kiếm, xem hồ sơ) chứ chưa phải đường ghi.

## File thô

Log đầy đủ của từng lượt nằm ở `ket-qua-0*.txt` (không commit vào Git vì phần lớn là dòng
tiến trình). Chạy lại theo lệnh ở `README.md` để tái tạo.
