# Smart Pet Care Service Platform

Nền tảng On-Demand P2P Marketplace kết nối chủ nuôi thú cưng với người cung cấp dịch vụ.

---

## Giới thiệu

Hệ thống gồm 3 loại dịch vụ:

- Dắt thú cưng (Dog Walking) - theo dõi GPS realtime trong suốt buổi dắt
- Trông giữ thú cưng (Pet Boarding) - photo log định kỳ theo phiên
- Chăm sóc tại nhà (Home Grooming) - xác minh vị trí bằng geofencing

3 vai trò người dùng: Pet Owner, Service Provider, Admin.

---

## Cấu trúc Monorepo

```
smart-pet-care/
├── petcare_backend/    - NestJS API, Prisma, Supabase PostgreSQL + PostGIS
├── petcare_app/        - Flutter Mobile App (Owner + Service Provider)
└── .github/workflows/  - CI/CD pipeline (GitHub Actions)
```

Mỗi thành phần có README riêng với hướng dẫn setup chi tiết:

- [petcare_backend/README.md](./petcare_backend/README.md)
- [petcare_app/README.md](./petcare_app/README.md)

---

## Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Backend | NestJS 10 + TypeScript, Prisma ORM (Driver Adapter pattern) |
| Mobile | Flutter + Riverpod |
| Database | Supabase PostgreSQL + PostGIS (Southeast Asia) |
| Auth | Firebase Auth (Social Login) |
| Push Notification | Firebase Cloud Messaging (FCM) |
| Realtime | Socket.io + Redis adapter - GPS Realtime và In-session Chat |
| Storage | Supabase Storage (RLS + Firebase JWT Third-party Auth) |
| Queue | BullMQ + Redis |
| AI | Anthropic Claude Vision API - xác minh ảnh dây xích/rọ mõm |
| Bản đồ | flutter_map / OpenStreetMap |
| Deploy | Railway (backend), GitHub Actions CI/CD |

---

## Architecture Decision Records

| ADR | Tóm tắt |
|---|---|
| ADR-001 | AI fail 3 lần - Owner Override 5 phút (thay Admin Manual Review) |
| ADR-002 | (Deprecated bởi ADR-004) GPS Dual Stream Firebase RTDB |
| ADR-003 | Optimistic Lock bằng `updatedAt` cho Booking State Machine - tránh Race Condition |
| ADR-004 | WebSocket (Socket.io + Redis adapter) thay Firebase RTDB cho GPS Realtime và In-session Chat |
| ADR-005 | flutter_map (OpenStreetMap) thay google_maps_flutter |

---

## Timeline

6 sprint, từ 12/05/2026 đến 31/07/2026.

| Sprint | Thời gian | Nội dung chính |
|---|---|---|
| Sprint 1 | 12/05 - 25/05 | Init NestJS + Flutter, Database schema, Supabase Storage |
| Sprint 2 | 26/05 - 08/06 | Kiến trúc tổng thể, API Contract, Auth API, UI/UX wireframe |
| Sprint 3 | 09/06 - 22/06 | Booking State Machine, Service Catalog, Provider API |
| Sprint 4 | 23/06 - 06/07 | WebSocket Gateway (GPS + Chat), Evidence Storage API |
| Sprint 5 | 07/07 - 20/07 | AI Photo Verification, Review/Report API, Admin |
| Sprint 6 | 21/07 - 31/07 | Integration, Unit Test, Deploy, Hoàn thiện báo cáo |

---

## Liên kết

- Backend đang chạy: https://petcare-backend.up.railway.app
- Swagger API Docs: https://petcare-backend.up.railway.app/api/docs
- Repository: https://github.com/thao-nguyenthithu/petcare