import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_task.dart';

// Phía UI của service GPS: quyền, khởi động, dừng, nghe dữ liệu
class WalkTrackingController {
  static Future<bool> dangChay() => FlutterForegroundTask.isRunningService;

  // Quyền, xin riêng từng nấc theo luật Android
  static Future<bool> coQuyenThongBao() async =>
      await FlutterForegroundTask.checkNotificationPermission() ==
      NotificationPermission.granted;

  // Thiếu quyền này thì service chạy mà không hiện thông báo
  static Future<bool> xinQuyenThongBao() async =>
      await FlutterForegroundTask.requestNotificationPermission() ==
      NotificationPermission.granted;

  static Future<LocationPermission> quyenViTri() =>
      Geolocator.checkPermission();

  // Hộp thoại hệ thống chỉ cấp tới mức khi dùng app
  static Future<LocationPermission> xinQuyenViTri() =>
      Geolocator.requestPermission();

  // Có quyền nền thì tắt màn hình vẫn theo dõi được
  static Future<bool> coQuyenNen() async =>
      await Geolocator.checkPermission() == LocationPermission.always;

  // Quyền nền chỉ chọn được trong trang Cài đặt
  static Future<bool> moCaiDatUngDung() => Geolocator.openAppSettings();

  static Future<bool> daBoToiUuPin() =>
      FlutterForegroundTask.isIgnoringBatteryOptimizations;

  static Future<bool> xinBoToiUuPin() =>
      FlutterForegroundTask.requestIgnoreBatteryOptimization();

  // Vòng đời service
  static Future<bool> batDau({
    required String bookingId,
    required String tieuDeThongBao,
    required String noiDungThongBao,
    required String tenKenhThongBao,
    int nhipGiay = gpsNhipWorkingGiay,
  }) async {
    // Đang chạy là phiên trước chưa đóng, không khởi động chồng
    if (await FlutterForegroundTask.isRunningService) return true;
    final token = await TokenStorageService().getAccessToken();
    if (token == null || token.isEmpty) return false;

    await FlutterForegroundTask.saveData(key: gpsKeyToken, value: token);
    await FlutterForegroundTask.saveData(
      key: gpsKeyBookingId,
      value: bookingId,
    );
    await FlutterForegroundTask.saveData(key: gpsKeyApiUrl, value: apiUrl);
    await FlutterForegroundTask.saveData(
      key: gpsKeyServerGoc,
      value: serverGoc,
    );
    await FlutterForegroundTask.saveData(key: gpsKeyNhipGiay, value: nhipGiay);

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'petcare_walk_gps',
        channelName: tenKenhThongBao,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(nhipGiay * 1000),
        allowWakeLock: true,
      ),
    );
    final ketQua = await FlutterForegroundTask.startService(
      serviceId: 1024,
      serviceTypes: const [ForegroundServiceTypes.location],
      notificationTitle: tieuDeThongBao,
      notificationText: noiDungThongBao,
      callback: walkTrackingTaskKhoiDong,
    );
    return ketQua is ServiceRequestSuccess;
  }

  // Gọi ở mọi nhánh khép phiên, xoá luôn token của isolate
  static Future<void> dungPhien() async {
    // Gói không có bản web, gọi vào là ném giữa luồng đăng xuất
    if (kIsWeb) return;
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
    await FlutterForegroundTask.removeData(key: gpsKeyToken);
    await FlutterForegroundTask.removeData(key: gpsKeyBookingId);
  }

  static void ngheDuLieu(void Function(Object data) callback) =>
      FlutterForegroundTask.addTaskDataCallback(callback);

  static void thoiNghe(void Function(Object data) callback) =>
      FlutterForegroundTask.removeTaskDataCallback(callback);
}
