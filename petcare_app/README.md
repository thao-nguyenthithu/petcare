# Smart Pet Care — Flutter Mobile App

Ứng dụng kết nối chủ nuôi thú cưng với người cung cấp dịch vụ theo mô hình On-Demand P2P.
3 dịch vụ: Dắt thú cưng - Trông giữ - Chăm sóc tại nhà.

---

## Yêu cầu môi trường

| Tool | Version |
|---|---|
| Flutter | 3.41.x stable |
| Dart | 3.x |
| Android SDK | API 34 |
| Java | 21 (Android Studio JBR) |

---

## Cài đặt

### 1. Clone và cài dependencies

```bash
git clone <repo-url>
cd petcare_app
flutter pub get
```

### 2. Tạo file secrets

Sao chép file mẫu và điền giá trị thật:

```bash
cp secrets.env.example secrets.env
```

Nội dung `secrets.env`:
```
SOCKET_URL=https://petcare-backend.up.railway.app
```

Không cần API key cho bản đồ - dự án dùng `flutter_map` với OpenStreetMap (ADR-005), miễn phí và không yêu cầu đăng ký.

Điền Facebook keys trong `android/gradle.properties` (vẫn cần cho Social Login):
```
FACEBOOK_APP_ID=your_facebook_app_id
FACEBOOK_CLIENT_TOKEN=your_facebook_client_token
```

### 3. Chạy app

```bash
flutter run --dart-define-from-file=secrets.env
```

### 4. Build APK

```bash
flutter build apk --debug --dart-define-from-file=secrets.env
```

---

## Cấu trúc thư mục

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        - Brand colors (primary, secondary, error...)
│   │   ├── app_text_styles.dart   - Typography
│   │   └── app_theme.dart         - ThemeData config
│   ├── router/
│   │   └── app_router.dart        - GoRouter config + redirect theo role
│   ├── constants/
│   │   ├── api_constants.dart     - BASE_URL, endpoint paths
│   │   └── app_constants.dart     - GPS batch size (5), flush interval (2min), etc.
│   ├── network/
│   │   ├── dio_client.dart        - Dio instance + interceptors (auth header, refresh token)
│   │   ├── socket_client.dart     - Socket.io client setup (ADR-004)
│   │   └── api_exception.dart     - Custom exception: ApiException, NetworkException
│   ├── l10n/                      - i18n - VI (mặc định) + EN
│   │   ├── app_vi.arb             - Tiếng Việt
│   │   └── app_en.arb             - Tiếng Anh
│   └── storage/
│       └── token_storage.dart     - TokenStorageService: saveTokens(), getAccessToken(), clearTokens()
│
├── data/
│   ├── models/
│   │   ├── user.dart              - User, UserRole enum
│   │   ├── pet.dart                - Pet
│   │   ├── booking.dart           - Booking, BookingStatus enum (gồm AWAITING_OWNER_APPROVAL, ADR-001)
│   │   ├── service.dart           - Service, ServiceType enum
│   │   ├── location_track.dart    - WaypointDto (lat, lng, clientTs) - REST batch history
│   │   └── message.dart           - Message model cho In-session Chat (ADR-004)
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── booking_repository.dart
│   │   ├── pet_repository.dart
│   │   └── gps_repository.dart    - saveBatch() gọi POST /gps/waypoints/batch (lưu history)
│   └── mock/
│       └── mock_data.dart         - Dữ liệu giả để dev không cần backend
│
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── providers/
│   │       └── auth_provider.dart
│   ├── home/
│   │   └── screens/home_screen.dart
│   ├── services/
│   │   └── screens/service_list_screen.dart
│   ├── booking/
│   │   ├── screens/
│   │   │   ├── booking_flow_screen.dart
│   │   │   └── owner_override_screen.dart  - [ADR-001] Màn hình Owner Override khi AI fail
│   │   └── providers/
│   │       └── booking_provider.dart       - updatedAt gửi kèm request (ADR-003)
│   ├── tracking/
│   │   ├── services/
│   │   │   ├── gps_socket_service.dart     - [ADR-004] WebSocket: gửi/nhận GPS realtime
│   │   │   └── gps_buffer_service.dart     - Buffer + flush batch lên REST (lưu history)
│   │   └── screens/
│   │       └── live_map_screen.dart        - Owner xem live marker qua flutter_map (ADR-005)
│   ├── chat/
│   │   ├── services/
│   │   │   └── chat_socket_service.dart    - [ADR-004] WebSocket: in-session chat
│   │   ├── providers/
│   │   │   └── chat_provider.dart
│   │   └── screens/
│   │       └── chat_screen.dart            - Chat giữa Owner và Service Provider
│   ├── pets/
│   │   └── screens/pet_profile_screen.dart
│   ├── provider_dashboard/
│   │   └── screens/provider_home_screen.dart
│   └── account/
│       └── screens/account_screen.dart     - Có nút chọn ngôn ngữ VI/EN
│
└── shared/
    └── widgets/
        ├── primary_button.dart
        ├── app_text_field.dart
        └── loading_overlay.dart
```

---

## Đa ngôn ngữ (i18n)

App hỗ trợ Tiếng Việt (mặc định) và Tiếng Anh.
User tự chọn trong Settings, preference lưu bằng `flutter_secure_storage`.

iOS permission strings dùng tiếng Anh - Apple yêu cầu, đây là system dialog không phải app UI.

---

## Bản đồ (ADR-005)

Dự án dùng `flutter_map` với OpenStreetMap thay cho `google_maps_flutter`.

Lý do: miễn phí hoàn toàn, không cần API key, không lo billing khi vượt free tier.

Package liên quan: `flutter_map`, `latlong2`.

---

## GPS và Chat Realtime (ADR-004)

GPS Realtime và In-session Chat dùng WebSocket (Socket.io client) kết nối tới NestJS Gateway, không còn dùng Firebase Realtime Database.

- GPS live: cập nhật vị trí qua WebSocket, Owner nhận marker realtime
- GPS history: vẫn lưu qua REST batch (`gps_buffer_service.dart`) để query lại sau khi booking hoàn thành
- Chat: tin nhắn gửi/nhận qua WebSocket, lưu vào PostgreSQL qua backend

Package liên quan: `socket_io_client`.

---

## Secret Management

| File | Mô tả | Commit? |
|---|---|---|
| `secrets.env` | Giá trị thật (SOCKET_URL...) | Không |
| `secrets.env.example` | Template không có giá trị thật | Có |
| `android/gradle.properties` | FACEBOOK_APP_ID + FACEBOOK_CLIENT_TOKEN cho Gradle | Không |

---

## Architecture Decision Records

| ADR | Tóm tắt | Sprint |
|---|---|---|
| ADR-001 | AI fail 3 lần - Owner Override 5 phút (thay Admin Manual Review) | BE S4 - Flutter S5 |
| ADR-002 | (Deprecated bởi ADR-004) GPS Dual Stream Firebase RTDB | - |
| ADR-003 | Optimistic Lock bằng `updatedAt` cho Booking State Machine - tránh Race Condition | BE S3 |
| ADR-004 | WebSocket (Socket.io) thay Firebase RTDB cho GPS Realtime và In-session Chat | BE S4 - Flutter S5 |
| ADR-005 | flutter_map (OpenStreetMap) thay google_maps_flutter | Flutter S5 |