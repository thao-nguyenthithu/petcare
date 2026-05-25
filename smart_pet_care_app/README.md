# Smart Pet Care — Flutter Mobile App

Ứng dụng kết nối chủ nuôi thú cưng với người cung cấp dịch vụ theo mô hình On-Demand P2P.
3 dịch vụ: Dắt thú cưng · Trông giữ · Chăm sóc tại nhà.

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
cd smart_pet_care_app
flutter pub get
```

### 2. Tạo file secrets

Sao chép file mẫu và điền API key thật:

```bash
cp secrets.env.example secrets.env
```

Nội dung `secrets.env`:
```
MAPS_API_KEY=your_google_maps_api_key_here
```

Điền thêm Android keys trong `android/gradle.properties`:
```
MAPS_API_KEY=your_google_maps_api_key_here
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
│   │   ├── app_colors.dart        ← Brand colors (primary, secondary, error...)
│   │   ├── app_text_styles.dart   ← Typography
│   │   └── app_theme.dart         ← ThemeData config
│   ├── router/
│   │   └── app_router.dart        ← GoRouter config + redirect theo role
│   ├── constants/
│   │   ├── api_constants.dart     ← BASE_URL, endpoint paths
│   │   └── app_constants.dart     ← GPS batch size (5), flush interval (2min), etc.
│   ├── network/
│   │   ├── dio_client.dart        ← Dio instance + interceptors (auth header, refresh token)
│   │   └── api_exception.dart     ← Custom exception: ApiException, NetworkException
│   ├── l10n/                      ← i18n — VI (mặc định) + EN
│   │   ├── app_vi.arb             ← Tiếng Việt
│   │   └── app_en.arb             ← Tiếng Anh
│   └── storage/
│       └── token_storage.dart     ← TokenStorageService: saveTokens(), getAccessToken(), clearTokens()
│
├── data/
│   ├── models/
│   │   ├── user.dart              ← User, UserRole enum
│   │   ├── pet.dart               ← Pet
│   │   ├── booking.dart           ← Booking, BookingStatus enum (gồm AWAITING_OWNER_APPROVAL [ADR-001])
│   │   ├── service.dart           ← Service, ServiceType enum
│   │   └── location_track.dart    ← WaypointDto (lat, lng, clientTs) [ADR-002]
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── booking_repository.dart
│   │   ├── pet_repository.dart
│   │   └── gps_repository.dart    ← saveBatch() gọi POST /gps/waypoints/batch [ADR-002]
│   └── mock/
│       └── mock_data.dart         ← Dữ liệu giả để dev không cần backend
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
│   │   │   └── owner_override_screen.dart  ← [ADR-001] Màn hình Owner Override khi AI fail
│   │   └── providers/
│   │       └── booking_provider.dart       ← updatedAt gửi kèm request [ADR-003]
│   ├── tracking/
│   │   ├── services/
│   │   │   └── gps_buffer_service.dart     ← [ADR-002] Buffer + flush batch
│   │   └── screens/
│   │       └── live_map_screen.dart        ← Owner xem live marker
│   ├── pets/
│   │   └── screens/pet_profile_screen.dart
│   ├── provider_dashboard/
│   │   └── screens/provider_home_screen.dart
│   └── account/
│       └── screens/account_screen.dart     ← Có nút chọn ngôn ngữ VI/EN
│
└── shared/
    └── widgets/
        ├── primary_button.dart
        ├── app_text_field.dart
        └── loading_overlay.dart
```

---

## Đa ngôn ngữ (i18n)

App hỗ trợ **Tiếng Việt** (mặc định) và **Tiếng Anh**.
User tự chọn trong Settings → preference lưu bằng `flutter_secure_storage`.

---

## Secret Management

| File | Mô tả | Commit? |
|---|---|---|
| `secrets.env` | API keys thật | Không |
| `secrets.env.example` | Template không có giá trị thật | Có |
| `android/gradle.properties` | MAPS_API_KEY + FACEBOOK_APP_ID + FACEBOOK_CLIENT_TOKEN cho Gradle | Không |

---

## Architecture Decision Records

| ADR | Tóm tắt | Sprint |
|---|---|---|
| ADR-001 | AI fail 3 lần → Owner Override 5 phút (thay Admin Manual Review) | BE S4 · Flutter S5 |
| ADR-002 | GPS Dual Stream: Firebase RTDB (live) + REST batch (history). Anti-Fraud: clientTs vs serverTs | BE S4 · Flutter S4 |
| ADR-003 | Optimistic Lock bằng `updatedAt` cho Booking State Machine — tránh Race Condition | BE S3 |
