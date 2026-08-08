import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _kenh = AndroidNotificationChannel(
  'petcare_tin',
  'Thông báo Smart Pet Care',
  description: 'Đơn hàng, hồ sơ, ví tiền và nhắc lịch',
  importance: Importance.high,
);

// Android nuốt push của FCM khi app đang mở, tin lúc đó phải tự dựng lấy
class LocalNotifService {
  LocalNotifService._();
  static final LocalNotifService instance = LocalNotifService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _daKhoiTao = false;

  Future<void> khoiTao() async {
    if (_daKhoiTao || kIsWeb) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_kenh);
      _daKhoiTao = true;
    } catch (e) {
      debugPrint('Không dựng được kênh thông báo: $e');
    }
  }

  // Cùng khoá thì thay thế bản cũ, tin về hai đường không nhân đôi trên thanh
  Future<void> hien({
    required String? khoa,
    required String tieuDe,
    String? noiDung,
  }) async {
    if (!_daKhoiTao || kIsWeb) return;
    try {
      await _plugin.show(
        id: (khoa ?? tieuDe).hashCode & 0x7fffffff,
        title: tieuDe,
        body: noiDung,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _kenh.id,
            _kenh.name,
            channelDescription: _kenh.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Không hiện được thông báo: $e');
    }
  }
}
