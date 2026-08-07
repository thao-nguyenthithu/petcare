import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:petcare_app/features/notification/services/notifications_api_service.dart';

class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final _api = NotificationsApiService();
  String? _tokenHienTai;

  String get _nenTang {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  // Gọi sau khi đăng nhập xong
  Future<void> dangKy() async {
    try {
      final quyen = await FirebaseMessaging.instance.requestPermission();
      if (quyen.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      _tokenHienTai = token;
      await _api.luuThietBi(token, _nenTang);

      // Firebase xoay token khi cài lại app, không nghe thì push rơi mất
      FirebaseMessaging.instance.onTokenRefresh.listen((moi) async {
        _tokenHienTai = moi;
        try {
          await _api.luuThietBi(moi, _nenTang);
        } catch (e) {
          debugPrint('Không gửi được token mới: $e');
        }
      });
    } catch (e) {
      debugPrint('Không đăng ký được nhận thông báo đẩy: $e');
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

  void ngheTinKhiDangMo(void Function(String? loai) khiCoTinMoi) {
    FirebaseMessaging.onMessage.listen((tin) => khiCoTinMoi(_loai(tin)));
    FirebaseMessaging.onMessageOpenedApp.listen(
      (tin) => khiCoTinMoi(_loai(tin)),
    );
  }

  String? _loai(RemoteMessage tin) => tin.data['type'] as String?;
}
