import 'package:flutter/foundation.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/services/tin_realtime.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

// Kênh tin thời gian thực, không phụ thuộc push nên chạy cả trên trình duyệt
class NotifySocketService {
  NotifySocketService._();
  static final NotifySocketService instance = NotifySocketService._();

  io.Socket? _socket;
  void Function(TinRealtime tin)? _khiCoTin;

  void ngheTin(void Function(TinRealtime tin) khiCoTin) => _khiCoTin = khiCoTin;

  Future<void> ketNoi() async {
    final token = await TokenStorageService().getAccessToken();
    if (token == null || token.isEmpty) return;
    dong();
    try {
      final socket = io.io(
        '$serverGoc/notify',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .disableAutoConnect()
            .enableForceNew()
            .enableReconnection()
            .build(),
      );
      _socket = socket;
      // Nối lại sau khi rớt mạng thì phải kéo lại, tin lỡ lúc đứt không phát lại
      socket.onConnect((_) => _khiCoTin?.call(const TinRealtime()));
      socket.on('notify:new', (data) {
        if (data is! Map) return;
        _khiCoTin?.call(
          TinRealtime(
            id: data['id'] as String?,
            loai: data['type'] as String?,
            tieuDe: data['title'] as String?,
            noiDung: data['body'] as String?,
          ),
        );
      });
      socket.connect();
    } catch (e) {
      debugPrint('Không mở được kênh tin thời gian thực: $e');
    }
  }

  void dong() {
    _socket?.dispose();
    _socket = null;
  }
}
