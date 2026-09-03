# Kiểm thử tải (k6)

Đúng 5 kịch bản cốt lõi: Smoke, Load, Stress, Spike, Soak. Hai kịch bản đầu (01, 02) đúng
theo kế hoạch đã chốt ở báo cáo mục 5.4. Dùng tài khoản TEST riêng, không dùng tài khoản
thật — mọi kịch bản gọi API thật (local hoặc Railway), riêng lượt tải tăng dần có thể ghi
dữ liệu thật nếu bật bước tạo đơn.

## Cài đặt

Đã cài k6 qua `winget install k6`. Kiểm tra: `k6 version` (nếu PowerShell không nhận lệnh,
mở lại terminal mới để nạp PATH).

## GIỚI HẠN QUAN TRỌNG — đọc trước khi chạy 02, 03, 04, 05

Backend có trần **300 request/phút/IP** (default) và **20 request/phút/IP** cho nhóm xác
thực (bộ luật mục 12, `common/gioi-han-ip`). k6 chạy từ MỘT máy nên tất cả VU dùng chung
một địa chỉ IP — trần này áp cho cả máy đo, không phân biệt được với người dùng thật. Hệ
quả:

- Đăng nhập chỉ gọi **một lần trong `setup()`**, chia sẻ token cho mọi VU/iteration —
  gọi lại mỗi iteration sẽ tự chạm trần 20/phút của nhóm xác thực trước khi đo được gì.
- Từ khoảng vài chục VU trở lên (tuỳ nhịp sleep), 02/03/04/05 sẽ chạm trần 300/phút
  chung. Từ đó, kết quả phản ánh **hành vi của rate-limiter** (429 có kiểm soát) chứ
  không còn phản ánh sức chịu tải thật của backend/DB — với Stress/Spike đây là điều
  CHỜ ĐỢI (xem có sập 5xx không), nhưng nếu muốn biết đỉnh thật thì phải vượt qua giới
  hạn 1-IP, xem mục dưới.
- KHÔNG tự nâng `TRAN_IP_MOI_PHUT` trong code để né trần — đây là con số bộ luật (mục
  12), đổi phải qua duyệt bộ luật trước theo quy tắc dự án, kể cả tạm thời.

## Bắn từ nhiều IP (đo sức chịu tải thật, vượt qua trần 1-IP)

k6 hỗ trợ chia một kịch bản thành nhiều đoạn (`--execution-segment`) để chạy song song
từ nhiều máy/nguồn khác nhau — mỗi máy tự có IP riêng nên không cộng dồn vào cùng một
trần. Ví dụ chạy `03-stress-test.js` từ 3 máy cùng lúc:

```
# Máy 1
k6 run --execution-segment "0:1/3" --execution-segment-sequence "0,1/3,2/3,1" -e BASE_URL=... -e LOAD_EMAIL=... -e LOAD_PASSWORD=... load-test/03-stress-test.js
# Máy 2
k6 run --execution-segment "1/3:2/3" --execution-segment-sequence "0,1/3,2/3,1" -e BASE_URL=... ... load-test/03-stress-test.js
# Máy 3
k6 run --execution-segment "2/3:1" --execution-segment-sequence "0,1/3,2/3,1" -e BASE_URL=... ... load-test/03-stress-test.js
```

Cả 3 lệnh cần chạy **gần như đồng thời** để tải cộng dồn đúng thời điểm; đọc kết quả
bằng cách gộp 3 bản tóm tắt lại (số VU cộng lại đúng bằng tổng, nhưng error rate/p95
phải đọc riêng từng máy vì k6 không tự gộp qua mạng ở chế độ chạy local này).

Cách này CẦN ít nhất 2-3 máy/thiết bị có IP khác nhau thật (máy khác, VM cloud khác,
điện thoại phát 4G làm nguồn thứ hai...) — tôi chỉ có một máy dev nên không tự bắn được
đa IP. Muốn có nguồn tải phân tán thật từ nhiều vùng mà không cần tự quản nhiều máy thì
dùng **k6 Cloud** (`k6 cloud login` rồi `k6 cloud run load-test/03-stress-test.js`) —
cần Kendra tự tạo tài khoản Grafana Cloud k6 (có gói miễn phí giới hạn) vì đây là dịch
vụ bên thứ ba, tôi không tự đăng ký thay.

## Chạy (một máy)

```
k6 run -e BASE_URL=http://localhost:3000/api/v1 -e LOAD_EMAIL=... -e LOAD_PASSWORD=... load-test/01-chay-khoi.js
k6 run -e BASE_URL=... -e LOAD_EMAIL=... -e LOAD_PASSWORD=... load-test/02-tai-tang-dan.js
k6 run -e BASE_URL=... -e LOAD_EMAIL=... -e LOAD_PASSWORD=... load-test/03-stress-test.js
k6 run -e BASE_URL=... -e LOAD_EMAIL=... -e LOAD_PASSWORD=... load-test/04-spike-test.js
k6 run -e BASE_URL=... -e LOAD_EMAIL=... -e LOAD_PASSWORD=... -e LOAD_SOAK_DURATION=2h load-test/05-soak-test.js
```

`BASE_URL` mặc định `http://localhost:3000/api/v1`. Nhắm vào Railway thì đổi thành
`https://petcare-backend.up.railway.app/api/v1` — cân nhắc kỹ vì đây là hệ thống thật.

## Năm kịch bản

1. **01-chay-khoi.js** (Smoke) — 5 VU, 3 phút. Chỉ xác nhận API đúng chức năng dưới tải nhẹ.
2. **02-tai-tang-dan.js** (Load) — tăng dần tới 50 VU giữ 5 phút, mô phỏng tải ngày
   thường. Tiêu chí đạt: 95% yêu cầu dưới 500ms, tỷ lệ lỗi dưới 1%. Bước tạo đơn mặc định
   TẮT (`LOAD_TAO_DON=true` để bật, kèm `LOAD_PET_ID`/`LOAD_ADDRESS_ID` của tài khoản
   test) vì ghi booking thật vào DB.
3. **03-stress-test.js** (Stress) — tăng liên tục 20→200 VU tìm điểm hệ thống thật sự
   sập (5xx). Không đặt ngưỡng pass/fail cứng vì CHỜ ĐỢI từ chối tăng dần; tiêu chí sống
   còn duy nhất là không có lỗi 5xx dù tải cao (429 chấp nhận được, 5xx thì không). Việc
   này cũng ngầm kiểm luôn trần rate-limit trả 429 có kiểm soát thay vì lỗi 500.
4. **04-spike-test.js** (Spike) — bơm 10→150 VU trong 10 giây rồi giữ 30 giây, rút về
   ngay, theo dõi 2 phút xem hệ thống có hồi phục hay không. Đọc kết quả theo dòng thời
   gian, không phải một con số tổng.
5. **05-soak-test.js** (Soak) — 15 VU giữ liên tục 2 giờ (mặc định, đổi bằng
   `LOAD_SOAK_DURATION`), bắt rò rỉ bộ nhớ/cạn kết nối DB mà lượt tải ngắn không thấy
   được. Soak "chuẩn" hay chạy 4-24 giờ, kéo dài thêm khi cần đo sâu hơn.

## Chưa làm được (ghi theo báo cáo mục 5.4/5.7)

Đo trên máy dev sẽ đẹp hơn thực tế vì bỏ qua độ trễ mạng Railway↔Supabase Singapore
(~50ms/lượt). Số đo có ý nghĩa phải chạy nhắm vào Railway thật, và như ghi ở mục "Bắn từ
nhiều IP", đo sức chịu tải thật (không bị trần IP che khuất) cần ít nhất 2-3 máy/nguồn
IP khác nhau hoặc tài khoản k6 Cloud — hiện chưa có sẵn.
