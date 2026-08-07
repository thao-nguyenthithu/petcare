import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class GpsDiem {
  const GpsDiem({required this.viTri, required this.serverTs});

  final LatLng viTri;
  final DateTime serverTs;
}

class GpsSocketService {
  GpsSocketService({required String serverGoc, required String token})
    : _serverGoc = serverGoc,
      _token = token;

  final String _serverGoc;
  final String _token;

  io.Socket? _socket;
  String? _bookingId;

  final _viTriCtrl = StreamController<GpsDiem>.broadcast();
  final _ketNoiCtrl = StreamController<bool>.broadcast();
  final _loiCtrl = StreamController<String>.broadcast();

  Stream<GpsDiem> get viTriMoi => _viTriCtrl.stream;
  Stream<bool> get dangKetNoi => _ketNoiCtrl.stream;
  Stream<String> get loi => _loiCtrl.stream;

  bool get daKetNoi => _socket?.connected ?? false;

  void ketNoi({required String bookingId}) {
    _bookingId = bookingId;
    final socket = io.io(
      '$_serverGoc/gps',
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
    socket.on('booking:joined', (_) => _bao(_ketNoiCtrl, true));
    socket.onDisconnect((_) => _bao(_ketNoiCtrl, false));
    socket.on('gps:updated', (data) {
      if (data is! Map) return;
      final lat = data['lat'];
      final lng = data['lng'];
      final ts = data['serverTs'];
      if (lat is! num || lng is! num) return;
      _bao(
        _viTriCtrl,
        GpsDiem(
          viTri: LatLng(lat.toDouble(), lng.toDouble()),
          serverTs: ts is num
              ? DateTime.fromMillisecondsSinceEpoch(ts.toInt())
              : DateTime.now(),
        ),
      );
    });
    socket.on('gps:error', (data) {
      final code = data is Map ? data['code'] : null;
      if (code is String) _bao(_loiCtrl, code);
    });
    socket.connect();
  }

  void guiViTri({required double lat, required double lng}) {
    final bookingId = _bookingId;
    if (bookingId == null) return;
    _socket?.emit('gps:update', {
      'bookingId': bookingId,
      'lat': lat,
      'lng': lng,
    });
  }

  void _bao<T>(StreamController<T> ctrl, T giaTri) {
    if (!ctrl.isClosed) ctrl.add(giaTri);
  }

  void dong() {
    _socket?.dispose();
    _socket = null;
    _viTriCtrl.close();
    _ketNoiCtrl.close();
    _loiCtrl.close();
  }
}
