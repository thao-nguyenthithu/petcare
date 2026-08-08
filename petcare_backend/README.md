# Smart Pet Care — Backend (NestJS)

REST API và WebSocket cho nền tảng P2P kết nối chủ nuôi với người chăm thú cưng.

Kiến trúc: NestJS 11 modular monolith · Prisma 7 + Supabase PostgreSQL/PostGIS · Redis (BullMQ,
OTP, Socket.io adapter) · JWT + Firebase Admin · Supabase Storage.

Quy mô hiện tại: 17 cụm module, 39 controller, 197 route, 4 gateway, 5 cron, 50 bộ test
với 756 phép kiểm. Lược đồ dữ liệu 37 model và 22 enum.

## Yêu cầu môi trường

Node.js 24.x · npm 11.x · Docker (chạy Redis tại chỗ, container `petcare_redis`).

## Cài đặt

```bash
npm install
docker compose up -d
npx prisma generate
npm run start:dev
```

Tự tạo file `.env` ở thư mục này theo bảng bên dưới. Bốn biến bắt buộc mới chạy được:
`DATABASE_URL`, `DIRECT_URL`, `JWT_SECRET`, `SUPABASE_URL` kèm `SUPABASE_SERVICE_KEY`.
Máy chủ nghe cổng `PORT` (mặc định 3000), tiền tố API là `/api/v1`.

## Biến môi trường

| Biến | Dùng làm gì |
|---|---|
| `DATABASE_URL` | Kết nối lúc chạy, đi qua pooler Supabase cổng 6543 |
| `DIRECT_URL` | Kết nối trực tiếp cổng 5432 cho `prisma migrate`, khai trong `prisma.config.ts` |
| `SHADOW_DATABASE_URL` | Chỉ cần khi tạo migration mới, xem mục Database |
| `JWT_SECRET`, `JWT_EXPIRES_IN` | Ký token, hạn mặc định `30d` |
| `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` | Tải ảnh lên Storage và ký đường dẫn riêng tư |
| `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` | Social login và đẩy thông báo; thiếu thì Firebase khởi tạo mềm, tính năng liên quan tắt |
| `MAIL_USER`, `MAIL_APP_PASSWORD` | Gửi mail OTP qua Gmail App Password |
| `ANTHROPIC_API_KEY`, `GEMINI_API_KEY` | Hai adapter quét ảnh check-in, thiếu key nào thì adapter đó bị bỏ qua |
| `REDIS_URL` hoặc `REDIS_HOST` + `REDIS_PORT` | BullMQ, OTP, Socket.io adapter |
| `PAYMENT_GATEWAY` | `mock`, `vnpay` hoặc `auto` |
| `VNPAY_TMN_CODE`, `VNPAY_HASH_SECRET`, `VNPAY_PAY_URL`, `VNPAY_RETURN_URL` | Cổng VNPay sandbox |
| `CORS_ORIGINS` | Danh sách origin phân tách bằng dấu phẩy |
| `PORT`, `NODE_ENV`, `DEBUG_PRISMA` | Cổng chạy, chế độ chạy, bật log truy vấn Prisma |

## Database

Toàn bộ lược đồ nằm trong **một** migration nền `prisma/migrations/20260808160000_nen_gop`,
gồm cả `CREATE EXTENSION postgis` và hai chỉ mục GIST viết tay. Sổ migration trên Supabase
đã được đánh dấu khớp với file này.

```bash
npx prisma migrate deploy   # áp lược đồ lên một database mới
npx prisma generate         # sinh lại client sau khi sửa schema
npx prisma studio           # xem dữ liệu
```

Sửa lược đồ thì **sửa thẳng file nền** rồi áp lên database đang chạy, KHÔNG thêm thư mục
migration thứ hai và KHÔNG dùng `migrate dev` (lệnh đó đòi reset database thật):

```bash
npx prisma db push          # đồng bộ nhanh database dev, thêm --accept-data-loss nếu đổi cột
npx prisma generate         # db push không tự sinh lại client
```

Xong thì cập nhật file nền cho khớp và đánh dấu lại sổ migration, nếu không lần dựng
database mới sẽ thiếu đúng phần vừa thêm. Cần shadow database riêng
(`SHADOW_DATABASE_URL`) khi nghiệm thu, vì shadow tạm của Prisma không có PostGIS.

Hai phép nghiệm thu khác nhau, phải chạy cả hai:

```bash
npx prisma migrate diff --from-config-datasource --to-schema prisma/schema.prisma --script
npx prisma migrate diff --from-migrations prisma/migrations --to-schema prisma/schema.prisma --script
```

Câu đầu so database đang chạy với lược đồ, câu sau phát lại thư mục migration lên shadow
database rồi mới so — chỉ câu sau mới nói được nền có dựng lại nổi database hay không. Cả
hai phải in ra `-- This is an empty migration.`

## Scripts

```bash
npm run start:dev    # watch mode
npm run build        # prisma generate + nest build
npm run start:prod   # chạy dist, dùng cho môi trường thật
npm run format       # Prettier
npm run lint         # ESLint kèm --fix
npm test             # Jest, toàn bộ test ở test/
npm run test:cov     # coverage cho báo cáo
```

## Cấu trúc `src/`

```
common/      tiện ích dùng chung: tiền, khoảng cách, thời gian VN, CORS, Redis, filter lỗi
config/      configuration.ts đọc biến môi trường
prisma/      PrismaService (driver adapter pg)
modules/
  addresses/     sổ địa chỉ chủ nuôi
  admin/         13 cụm quản trị nghiệp vụ kèm dto và tiện ích chung, tham số vận hành, nhật ký
  ai/            quét ảnh check-in, adapter Anthropic và Gemini
  auth/          đăng ký, đăng nhập, OTP, social login, tài khoản
  bookings/      máy trạng thái đơn, huỷ, khiếu nại, thanh toán đơn
  firebase/      Firebase Admin, đẩy thông báo
  gps/           theo dõi trực tiếp, waypoint, chốt báo cáo lộ trình
  mail/          nodemailer qua hàng đợi BullMQ
  media/         tải ảnh lên Supabase Storage, ký đường dẫn riêng tư
  messaging/     hội thoại trong đơn
  notifications/ thông báo trong ứng dụng và đẩy
  payments/      cổng mock và VNPay
  pets/          hồ sơ bé, lịch phòng bệnh
  reviews/       đánh giá sau đơn
  search/        tìm người chăm quanh đây bằng PostGIS
  sitter/        bảy cụm phía người chăm: hồ sơ, dịch vụ, lịch, đơn, ví, trang chủ, công khai
  wallet/        ví, rút tiền, tài khoản ngân hàng
```

## WebSocket

Bốn gateway chạy chung cổng với REST, dùng Redis adapter để nhiều tiến trình cùng phát
được. Ứng dụng nối bằng `socket_io_client` kèm JWT.

| Namespace | File | Dùng cho |
|---|---|---|
| `/gps` | `gps/gps.gateway.ts` | Chủ nuôi xem lộ trình phiên dắt theo thời gian thực |
| `/messaging` | `messaging/messaging.gateway.ts` | Hội thoại trong đơn |
| `/notify` | `notifications/notifications.gateway.ts` | Thông báo đẩy trong ứng dụng |
| `/checkin-scan` | `sitter/orders/checkin-scan.gateway.ts` | Đẩy kết quả AI quét ảnh check-in |

Kết quả quét AI đi một chiều từ máy chủ ra, ứng dụng KHÔNG hỏi lại theo nhịp.

## Tác vụ định kỳ

Năm cron chạy trong tiến trình máy chủ, con số ở đây là nhịp chạy chứ không phải hạn
nghiệp vụ — hạn tra bộ luật mục 14:

| Việc | Nhịp | File |
|---|---|---|
| Quét đơn quá hạn: hết hạn nhận, người chăm chưa tới, không ai bắt đầu | mỗi phút | `bookings/booking-sweep.job.ts` |
| Tự chốt đơn chủ nuôi không xác nhận | mỗi 10 phút | `bookings/auto-complete.job.ts` |
| Nhả tiền tạm giữ về ví người chăm | mỗi 10 phút | `wallet/escrow-release.job.ts` |
| Nhắc lịch phòng bệnh | 8 giờ sáng | `pets/prevention-reminder.job.ts` |
| Dọn bản ghi ngày cài riêng đã qua | 3 giờ sáng | `auth/user-cleanup.service.ts` |

Ba nhánh của lượt quét mỗi phút đi chung một truy vấn rồi phân nhánh trong bộ nhớ, đừng
tách thành ba việc chạy song song. Việc tự chốt chạy trước việc nhả tiền để đơn vừa chốt
xong là lượt nhả kế tiếp thấy ngay.

## Điểm cần biết

- **Con số nghiệp vụ**: tra `.claude/so-lieu-nghiep-vu.md` trước khi code, đừng lấy từ mã
  nguồn cũ. Mười bốn tham số vận hành đọc từ bảng `SystemSetting`, đổi ở màn quản trị 15,
  và đóng băng theo đơn — phí nền tảng cùng phí huỷ chốt lúc tạo đơn, mốc nhả tiền chốt
  lúc đơn kết thúc.
- **Múi giờ database phải là `UTC`**: driver adapter của Prisma bỏ phần offset khi đọc
  `timestamptz`, nên đặt session sang giờ Việt Nam là mọi mốc lệch 7 giờ ở cả hai chiều.
  Kiểm bằng `show timezone;`.
- **Redis**: có `REDIS_URL` thì dùng chuỗi đó (kèm mật khẩu, dành cho môi trường thật),
  không có mới rơi về `REDIS_HOST`/`REDIS_PORT`.
- **CORS**: khai `CORS_ORIGINS` phân tách bằng dấu phẩy. Bỏ trống lúc chạy máy là mở hết,
  bỏ trống ở môi trường thật là chặn mọi trình duyệt. Ứng dụng di động không gửi `Origin`
  nên không bị ảnh hưởng.
- **Cổng thanh toán**: `NODE_ENV=production` mà còn `PAYMENT_GATEWAY=mock` thì máy chủ
  không khởi động (bộ luật mục 15).
- **Swagger** ở `/api/docs`, tiền tố API là `/api/v1`.

## Deploy

```bash
railway up --service petcare-backend --detach
```

Biến môi trường khai trong Railway Dashboard, không dùng file `.env` trên máy chủ.
Healthcheck trỏ `/api/docs`. Push vào `main` sẽ tự chạy job deploy ở
`.github/workflows/deploy.yml`.
