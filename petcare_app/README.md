# Smart Pet Care — Ứng dụng Flutter

Ứng dụng của nền tảng P2P kết nối chủ nuôi với người chăm thú cưng. Một mã nguồn phục vụ
hai vai, đổi vai ngay trong ứng dụng: **chủ nuôi** đặt và theo dõi đơn, **người chăm**
nhận đơn và tác nghiệp.

Ba dịch vụ: dắt đi dạo có định vị trực tiếp, trông giữ qua đêm có nhật ký ảnh, tắm và cắt
tỉa tại nhà.

## Yêu cầu môi trường

| Thứ | Bản |
|---|---|
| Flutter | 3.41.x stable |
| Dart SDK | ^3.11.5 |
| Android | minSdk 31, biên dịch theo `flutter.compileSdkVersion` |
| Java | 17 (JBR của Android Studio) |

Máy Android **thật** mới chạy được phần đáng thử nhất: máy ảnh, định vị nền, thông báo
đẩy. Máy ảo chỉ hợp để soát giao diện.

## Cài đặt

```bash
flutter pub get
```

Tạo `secrets.env` ở thư mục này, đúng một biến:

```
API_URL=http://10.0.2.2:3000/api/v1
```

Máy Android thật thì thay bằng địa chỉ IP của máy chạy máy chủ trong cùng mạng LAN, ví dụ
`http://192.168.1.10:3000/api/v1`; dùng máy chủ đã triển khai thì trỏ
`https://petcare-backend.up.railway.app/api/v1`. Địa chỉ WebSocket **không khai riêng**:
ứng dụng cắt phần `/api/v1` khỏi `API_URL` để ra gốc máy chủ rồi nối các namespace.

Facebook keys khai trong `android/gradle.properties`, thiếu thì chỉ tắt đăng nhập
Facebook chứ không sập ứng dụng:

```
FACEBOOK_APP_ID=...
FACEBOOK_CLIENT_TOKEN=...
```

Bản đồ không cần khoá nào: dự án dùng `flutter_map` với OpenStreetMap (ADR-005).

## Chạy và build

```bash
flutter run --dart-define-from-file=secrets.env
flutter build apk --debug --dart-define-from-file=secrets.env
```

Thiếu `--dart-define-from-file` thì `API_URL` rơi về `http://localhost:3000/api/v1`, tức
chính máy Android chứ không phải máy chạy máy chủ — mọi lời gọi sẽ lỗi mạng.

Thêm chuỗi hiển thị thì sinh lại l10n, bắt buộc trước khi build:

```bash
flutter gen-l10n
dart format lib
flutter analyze
```

## Cấu trúc `lib/`

Bốn tầng: `main.dart` tối giản, `core/` hạ tầng, `shared/` dùng chung nhiều cụm,
`features/` chia theo nghiệp vụ. Widget thăng cấp dần: `_Xxx` trong màn hình →
`features/<cụm>/widgets/` → `shared/widgets/`.

```
main.dart              khởi tạo Firebase, ProviderScope, router
core/
  config/              tham số nghiệp vụ đọc từ máy chủ
  l10n/                app_vi.arb là nguồn chuỗi, generated/ do gen-l10n sinh
  network/             api_client.dart (Dio + JWT interceptor), api_error.dart
  providers/           container dùng chung
  router/              go_router, chặn đường theo vai và trạng thái hồ sơ
  services/            thông báo đẩy, socket thông báo, thông báo hệ thống
  storage/             lưu JWT bằng flutter_secure_storage
  theme/               AppColors, AppTextStyles, AppTheme, khoảng cách
  utils/               ngày giờ theo múi giờ Việt Nam, kiểm dữ liệu nhập
shared/
  data/                kiểu dữ liệu dùng chung: bé, dịch vụ, khung giờ
  services/            gọi GPS, socket GPS, tìm người chăm
  utils/               khoảng cách, chọn ảnh, mở chỉ đường
  widgets/             nút, thẻ, khung ảnh, kéo làm mới, bộ khung chờ
features/              mỗi cụm gồm data/ providers/ screens/ services/ widgets/ và
                       một file <cụm>_routes.dart
  auth address account pets                     tài khoản và hồ sơ
  home search service booking owner_wallet      phía chủ nuôi
  dksitter sitter sitter_order wallet           phía người chăm
  messaging notification reviews                dùng chung hai vai
```

## Đa ngôn ngữ

Chuỗi hiển thị **không được viết thẳng trong mã**. Thêm khoá vào `lib/core/l10n/app_vi.arb`
(tên khoá tiếng Việt không dấu), chạy `flutter gen-l10n`, rồi gọi `context.l10n.<khoá>`.

Giai đoạn phát triển chỉ nuôi bản tiếng Việt; `app_en.arb` để dịch trọn một lượt ở cuối
dự án, đụng vào sớm là ôm hai bản lệch nhau suốt nhiều tháng. Chuỗi xin quyền của iOS vẫn
để tiếng Anh vì đó là hộp thoại hệ thống.

## Định vị và thời gian thực

- **Định vị phiên dắt**: `geolocator` ghi điểm, `flutter_foreground_task` giữ việc chạy
  khi ứng dụng ở nền, socket `/gps` đẩy vị trí cho chủ nuôi xem. Ngưỡng ghi và gom điểm
  tra bộ luật mục 8, đừng đọc từ mã nguồn cũ.
- **Hội thoại trong đơn** qua socket `/messaging`, **thông báo** qua `/notify`, **kết quả
  AI quét ảnh check-in** qua `/checkin-scan`.
- Kết quả AI do máy chủ **đẩy xuống**, ứng dụng không hỏi lại theo nhịp. Chờ lâu thì đừng
  bấm lại, xem log máy chủ.
- Thông báo đẩy dùng `firebase_messaging`; ứng dụng đang mở thì `flutter_local_notifications`
  dựng thông báo hệ thống, vì FCM không tự hiện khi ứng dụng ở tiền cảnh.

## Quy ước code

Chi tiết ở `.claude/rule/rule-flutter.md`, ba điều hay sai nhất:

- Dùng widget Material 3 gốc (`FilledButton`, `OutlinedButton`, `TextButton`...), style khai
  một lần trong `AppTheme`. Không tự chế lại thứ đã có sẵn.
- Màu và khoảng cách lấy từ `core/theme/`, không viết số đo thô lấy từ Figma.
- Định danh và tên file bằng tiếng Anh; comment, log và thông báo lỗi bằng tiếng Việt,
  mỗi comment đúng một dòng.

Hiệu năng: kiểm tra hình thức dữ liệu ngay ở máy, không gọi máy chủ theo từng phím gõ,
dùng `const`, `ListView.builder`, `cached_network_image` và nhớ `dispose`.

## Quản lý bí mật

| File | Nội dung | Commit? |
|---|---|---|
| `secrets.env` | `API_URL` trỏ máy chủ đang dùng | Không |
| `android/gradle.properties` | `FACEBOOK_APP_ID`, `FACEBOOK_CLIENT_TOKEN` | Không |
| `android/app/google-services.json` | Cấu hình Firebase | Không |

## Quyết định kiến trúc

| ADR | Tóm tắt |
|---|---|
| ADR-003 | Khoá lạc quan bằng `updatedAt` cho máy trạng thái đơn, tránh hai lượt bấm cùng lúc |
| ADR-004 | WebSocket (Socket.io) cho định vị trực tiếp và hội thoại, thay Firebase Realtime Database |
| ADR-005 | `flutter_map` với OpenStreetMap thay `google_maps_flutter`, khỏi khoá API và khỏi lo hoá đơn |
