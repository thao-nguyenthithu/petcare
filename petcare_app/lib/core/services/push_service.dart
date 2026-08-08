import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:petcare_app/core/services/tin_realtime.dart';
import 'package:petcare_app/core/storage/locale_storage.dart';
import 'package:petcare_app/features/notification/services/notifications_api_service.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final _api = NotificationsApiService();
  String? _tokenHienTai;
  String _ngonNgu = 'vi';

  String get _nenTang {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  // Gọi sau khi đăng nhập xong
  Future<void> dangKy() async {
    try {
      final quyen = await FirebaseMessaging.instance.requestPermission();
      if (quyen.authorizationStatus == AuthorizationStatus.denied) return;

      _ngonNgu = await const LocaleStorage().readLanguageCode() ?? 'vi';
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      _tokenHienTai = token;
      await _api.luuThietBi(token, _nenTang, _ngonNgu);

      // Firebase xoay token khi cài lại app, không nghe thì push rơi mất
      FirebaseMessaging.instance.onTokenRefresh.listen((moi) async {
        _tokenHienTai = moi;
        try {
          await _api.luuThietBi(moi, _nenTang, _ngonNgu);
        } catch (e) {
          debugPrint('Không gửi được token mới: $e');
        }
      });
    } catch (e) {
      debugPrint('Không đăng ký được nhận thông báo đẩy: $e');
    }
  }

  // Đổi tiếng giữa chừng mà không báo lại thì push vẫn tiếng cũ
  Future<void> doiNgonNgu(String ma) async {
    _ngonNgu = ma;
    final token = _tokenHienTai;
    if (token == null) return;
    try {
      await _api.luuThietBi(token, _nenTang, ma);
    } catch (e) {
      debugPrint('Không cập nhật được ngôn ngữ nhận push: $e');
    }
  }

  Future<void> huyDangKy() async {
    final token = _tokenHienTai;
    if (token == null) return;
    _tokenHienTai = null;
    try {
      await _api.xoaThietBi(token);
    } catch (e) {
      debugPrint('Không gỡ được thiết bị khỏi danh sách nhận push: $e');
    }
  }

  void ngheTinKhiDangMo(void Function(TinRealtime tin) khiCoTinMoi) {
    FirebaseMessaging.onMessage.listen((tin) => khiCoTinMoi(_doc(tin)));
    FirebaseMessaging.onMessageOpenedApp.listen(
      (tin) => khiCoTinMoi(_doc(tin)),
    );
  }

  TinRealtime _doc(RemoteMessage tin) => TinRealtime(
    id: tin.data['notifId'] as String?,
    loai: tin.data['type'] as String?,
    tieuDe: tin.notification?.title,
    noiDung: tin.notification?.body,
  );
}
