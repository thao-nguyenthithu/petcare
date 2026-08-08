# Smart Pet Care Service Platform

Nền tảng On-Demand P2P Marketplace kết nối chủ nuôi thú cưng với người cung cấp dịch vụ.

---

## Giới thiệu

Ba loại dịch vụ:

- Dắt thú cưng (Dog Walking) - theo dõi GPS realtime trong suốt buổi dắt
- Trông giữ thú cưng (Pet Boarding) - photo log định kỳ theo phiên
- Chăm sóc tại nhà (Home Grooming) - xác minh vị trí bằng geofencing

Ba vai trò người dùng: chủ nuôi (Owner), người chăm (Sitter), quản trị viên (Admin).
Owner và Sitter dùng chung ứng dụng di động, Admin dùng web quản trị riêng.

---

## Cấu trúc Monorepo

```
smart-pet-care/
├── petcare_backend/    - NestJS 11 API + WebSocket, Prisma 7, Supabase PostgreSQL + PostGIS
├── petcare_app/        - Flutter app cho Owner và Sitter
├── petcare_admin/      - Web quản trị (React 19 + Vite + Tailwind)
├── docs/               - Tài liệu kiến trúc, ADR, thiết kế (đọc docs/README.md trước)
└── .github/workflows/  - CI/CD pipeline (GitHub Actions, deploy Railway)
```

Hướng dẫn setup chi tiết ở README từng thành phần:

- [petcare_backend/README.md](./petcare_backend/README.md)
- [petcare_app/README.md](./petcare_app/README.md)

Web quản trị chạy bằng Vite:

```bash
cd petcare_admin
npm install
npm run dev
```

---

## Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Backend | NestJS 11 + TypeScript, Prisma 7 (Driver Adapter `@prisma/adapter-pg`) |
| Mobile | Flutter 3.41 + Riverpod 3 + go_router, i18n ARB vi/en |
| Web quản trị | React 19 + Vite + TypeScript, Tailwind + Radix UI, TanStack Query, i18next |
| Database | Supabase PostgreSQL + PostGIS (Southeast Asia), 37 model - 22 enum |
| Auth | JWT (passport-jwt) + Firebase Admin cho social login Google/Facebook |
| Push Notification | Firebase Cloud Messaging (FCM) |
| Realtime | Socket.io + Redis adapter - GPS realtime và chat trong đơn |
| Storage | Supabase Storage, đường dẫn riêng tư ký tạm thời |
| Queue - cache | BullMQ + Redis (mail, hết hạn thanh toán, OTP) |
| Mail | nodemailer qua Gmail App Password |
| AI | Vision adapter Anthropic Claude và Google Gemini - xác minh ảnh check-in |
| Thanh toán | VNPay sandbox, cổng mock cho môi trường chạy máy |
| Bản đồ | flutter_map / OpenStreetMap (app), Leaflet (web quản trị) |
| Deploy | Railway (backend), GitHub Actions CI/CD |

---

## Phạm vi chức năng

| Thành phần | Cụm chính |
|---|---|
| Backend | 17 cụm module - 39 controller - 197 route - 6 gateway - 5 cron - 49 bộ test |
| Ứng dụng di động | Owner: tìm kiếm, đặt đơn, thú cưng, địa chỉ, ví, đánh giá, nhắn tin, thông báo · Sitter: đăng ký làm người chăm, dịch vụ, lịch, đơn, ví |
| Web quản trị | Người dùng, người chăm, đơn, khiếu nại, bằng chứng, tài chính, phạt, đánh giá, dịch vụ, thông báo, tham số hệ thống |

---

## Liên kết

- Backend đang chạy: https://petcare-backend.up.railway.app
- Swagger API Docs: https://petcare-backend.up.railway.app/api/docs
- Repository: https://github.com/thao-nguyenthithu/petcare
