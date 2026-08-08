# Smart Pet Care — Backend (NestJS)

REST API và WebSocket cho nền tảng P2P kết nối chủ nuôi với người chăm thú cưng.

Kiến trúc: NestJS 11 modular monolith · Prisma 7 + Supabase PostgreSQL/PostGIS · Redis (BullMQ,
OTP, Socket.io adapter) · JWT + Firebase Admin · Supabase Storage.

Quy mô hiện tại: 17 cụm module, 39 controller, 197 route, 6 gateway, 5 cron, 49 bộ test.
Lược đồ dữ liệu 37 model và 22 enum.

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

Sửa lược đồ thì tạo migration mới bằng `npx prisma migrate dev --name <ten_khong_dau>`,
KHÔNG sửa file nền. Cần shadow database riêng (`SHADOW_DATABASE_URL`) vì shadow tạm của
Prisma không có PostGIS.

Nghiệm thu lược đồ khớp database:

```bash
npx prisma migrate diff --from-config-datasource --to-schema prisma/schema.prisma --script
```

In ra `-- This is an empty migration.` là khớp.

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
  admin/         13 cụm quản trị, tham số vận hành, nhật ký
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

## Tác vụ định kỳ

Năm cron chạy trong tiến trình máy chủ, nhịp cụ thể tra bộ luật:

- tự hoàn tất đơn quá hạn (`bookings/auto-complete.job.ts`)
- quét đơn treo trạng thái (`bookings/booking-sweep.job.ts`)
- nhắc lịch phòng bệnh (`pets/prevention-reminder.job.ts`)
- giải phóng tiền tạm giữ về ví người chăm (`wallet/escrow-release.job.ts`)

## Điểm cần biết

  ngưỡng vận hành đọc từ bảng `SystemSetting` và đóng băng theo đơn.
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
