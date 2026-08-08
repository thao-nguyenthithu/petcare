import 'dart:async';

import 'package:petcare_app/features/sitter_order/data/ai_scan.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

const String _namespace = '/checkin';

// Nghe kết quả quét của một lô ảnh check-in
class CheckinScanSocketService {
  CheckinScanSocketService({required String serverGoc, required String token})
    : _serverGoc = serverGoc,
      _token = token;

  final String _serverGoc;
  final String _token;

  io.Socket? _socket;
  String? _bookingId;

  final _ketQuaCtrl = StreamController<KetQuaLoQuet>.broadcast();

  Stream<KetQuaLoQuet> get ketQua => _ketQuaCtrl.stream;

  void ketNoi({required String bookingId}) {
    _bookingId = bookingId;
    final socket = io.io(
      '$_serverGoc$_namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': _token})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      socket.emit('booking:join', {'bookingId': _bookingId});
    });
    socket.on('checkin.scan.done', (data) {
      if (data is! Map) return;
      _bao(KetQuaLoQuet.fromJson(Map<String, dynamic>.from(data)));
    });
    socket.connect();
  }

  void _bao(KetQuaLoQuet ketQua) {
    if (!_ketQuaCtrl.isClosed) _ketQuaCtrl.add(ketQua);
  }

  void dong() {
    _socket?.dispose();
    _socket = null;
    _ketQuaCtrl.close();
  }
}
