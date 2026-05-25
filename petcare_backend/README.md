# Smart Pet Care — Backend API (NestJS)

Backend cho ứng dụng Smart Pet Care Service Platform.  
Kiến trúc: **NestJS Modular Monolith** · **Supabase PostgreSQL + PostGIS** · **Firebase** · **Redis + BullMQ**

---

## Yêu cầu môi trường

| Tool | Version |
|---|---|
| Node.js | v24.x LTS |
| npm | 11.x |
| NestJS CLI | Latest |

---

## Cài đặt

### 1. Clone và cài dependencies

```bash
git clone <repo-url>
cd petcare_backend
npm install
```

### 2. Tạo file môi trường

```bash
cp .env.example .env
```

Điền đầy đủ các biến trong `.env`:

```env
# App
NODE_ENV=development
PORT=3000

# Database (Supabase)
DATABASE_URL=postgresql://postgres.[PROJECT]:[PASSWORD]@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true
DIRECT_URL=postgresql://postgres.[PROJECT]:[PASSWORD]@db.[PROJECT].supabase.co:5432/postgres

# Redis
REDIS_URL=redis://localhost:6379

# Supabase Storage
SUPABASE_URL=https://[PROJECT].supabase.co
SUPABASE_SERVICE_KEY=your_service_role_key

# JWT
JWT_SECRET=your_jwt_secret
JWT_EXPIRES_IN=7d
JWT_REFRESH_EXPIRES_IN=30d

# Firebase
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@project.iam.gserviceaccount.com
FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com

# AI
ANTHROPIC_API_KEY=sk-ant-...

# Google Maps
GOOGLE_MAPS_API_KEY=AIza...
```

### 3. Chạy migration database

```bash
npx prisma migrate dev
npx prisma generate
```

### 4. Chạy ứng dụng

```bash
# Development (watch mode)
npm run start:dev

# Production
npm run start:prod
```

---

## Cấu trúc thư mục

```
src/
├── app.module.ts
├── main.ts
└── modules/
    ├── admin/          ← Quản trị hệ thống
    ├── ai/             ← Claude Vision API + Owner Override (ADR-001)
    ├── auth/           ← JWT + Firebase Auth
    ├── bookings/       ← Booking State Machine (ADR-003)
    ├── location/       ← PostGIS geosearch + Geofencing
    ├── media/          ← Supabase Storage (Service Key)
    ├── notification/   ← FCM Push Notification + BullMQ
    ├── pets/           ← Pet CRUD
    ├── reports/        ← Báo cáo vi phạm
    ├── reviews/        ← Đánh giá dịch vụ
    ├── services/       ← Service Catalog (Walking/Boarding/Grooming)
    └── users/          ← User Profile
```

---

## Scripts

```bash
# Development
npm run start:dev       # Chạy với watch mode

# Build
npm run build           # Build production

# Testing
npm run test            # Unit tests
npm run test:cov        # Test coverage
npm run test:e2e        # E2E tests

# Database
npx prisma migrate dev  # Tạo và apply migration mới
npx prisma generate     # Regenerate Prisma Client
npx prisma studio       # Mở Prisma Studio (GUI)
npx prisma db seed      # Chạy seed data
```

---

## API Documentation

Swagger UI: `http://localhost:3000/api/docs`

---

## Lưu ý quan trọng

### GIST Spatial Index — PostGIS

Index `idx_service_provider_location` **không thể** tạo qua `prisma migrate dev` vì Prisma shadow database là DB tạm tự tạo mới — không có PostGIS extension, dù Supabase Primary Database đã bật PostGIS sẵn.

**Đã apply thủ công** qua Supabase SQL Editor (task B02.4).

Nếu reset DB, chạy lại SQL trong:
```
prisma/migrations/20260525083625_add_spatial_index/migration.sql
```

Hoặc chạy thủ công trong Supabase SQL Editor:
```sql
CREATE INDEX IF NOT EXISTS idx_service_provider_location
ON "ServiceProvider"
USING GIST (ST_SetSRID(ST_MakePoint(lng, lat), 4326));
```

### Supabase Storage

- Flutter upload ảnh **trực tiếp** lên Supabase Storage bằng Firebase JWT — không qua NestJS
- NestJS chỉ dùng `SUPABASE_SERVICE_KEY` cho admin operations (xóa ảnh vi phạm, seed data)
- `SUPABASE_SERVICE_KEY` là server-side secret — **không bao giờ** đưa vào Flutter app

### Firebase Auth

- Dự án dùng Firebase Auth cho Social Login (Google/Facebook)
- Supabase đã cấu hình Third-party Auth với Firebase Project ID: `smart-pet-care-vn`
- RLS policy trên Storage dùng `auth.uid() IS NOT NULL` — hoạt động nhờ Firebase JWT verification qua Google JWKS

---

## Architecture Decision Records

| ADR | Tóm tắt |
|---|---|
| ADR-001 | AI fail 3 lần → Owner Override 5 phút (thay Admin Manual Review) |
| ADR-002 | GPS Dual Stream: Firebase RTDB (live) + REST batch (history). Anti-Fraud: clientTs vs serverTs |
| ADR-003 | Optimistic Lock bằng `updatedAt` cho Booking State Machine — tránh Race Condition |

---

## Docker (Local Development)

```bash
# Khởi động PostgreSQL + Redis + Adminer
docker-compose up -d

# Dừng
docker-compose down
```

---

## Deployment

Deploy lên Railway:

```bash
# Cài Railway CLI
npm install -g @railway/cli

# Deploy
railway up --service petcare-api
```

Biến môi trường được cấu hình trong Railway Dashboard — không dùng file `.env` trên server.