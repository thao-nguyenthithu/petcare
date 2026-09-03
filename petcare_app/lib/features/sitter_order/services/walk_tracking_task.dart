import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petcare_app/shared/services/gps_socket_service.dart';

const String gpsKeyToken = 'gps_token';
const String gpsKeyBookingId = 'gps_booking_id';
const String gpsKeyApiUrl = 'gps_api_url';
const String gpsKeyServerGoc = 'gps_server_goc';
const String gpsKeyNhipGiay = 'gps_nhip_giay';
const String gpsGoiViTri = 'vi_tri';
const String gpsGoiLoi = 'loi';

const int gpsDistanceFilterMet = 10;
const int gpsNhipEnrouteGiay = 15;
const int gpsNhipWorkingGiay = 30;
const int gpsSoDiemMoiBatch = 10;
const Duration gpsFlushToiDa = Duration(minutes: 2);

const int _tranBufferDiem = 500;

const double _nguongSpikeKmh = 40;

@pragma('vm:entry-point')
void walkTrackingTaskKhoiDong() {
  FlutterForegroundTask.setTaskHandler(WalkTrackingTaskHandler());
}

class _DiemGo {
  const _DiemGo({
    required this.lat,
    required this.lng,
    required this.clientTs,
    required this.isMocked,
  });

  final double lat;
  final double lng;
  final DateTime clientTs;
  final bool isMocked;

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'clientTs': clientTs.toUtc().toIso8601String(),
    'isMocked': isMocked,
  };
}

class WalkTrackingTaskHandler extends TaskHandler {
  String? _bookingId;
  Dio? _dio;
  GpsSocketService? _socket;
  StreamSubscription<Position>? _subViTri;

  final List<_DiemGo> _buffer = [];
  DateTime _flushCuoi = DateTime.now();
  bool _dangFlush = false;

  Position? _moiNhat;
  Position? _diemTruoc;
  DateTime? _tsCuoi;
  double _kmDaDi = 0;
  bool _daGuiDiemDau = false;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final token = await FlutterForegroundTask.getData<String>(key: gpsKeyToken);
    final bookingId = await FlutterForegroundTask.getData<String>(
      key: gpsKeyBookingId,
    );
    final apiUrl = await FlutterForegroundTask.getData<String>(
      key: gpsKeyApiUrl,
    );
    final serverGoc = await FlutterForegroundTask.getData<String>(
      key: gpsKeyServerGoc,
    );
    if (token == null ||
        bookingId == null ||
        apiUrl == null ||
        serverGoc == null) {
      FlutterForegroundTask.sendDataToMain(const {
        'loai': gpsGoiLoi,
        'code': 'THIEU_DU_LIEU_KHOI_DONG',
      });
      await FlutterForegroundTask.stopService();
      return;
    }

    _bookingId = bookingId;
    _dio = Dio(
      BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    _socket = GpsSocketService(serverGoc: serverGoc, token: token)
      ..ketNoi(bookingId: bookingId);
    _batDauNgheViTri();
    unawaited(_diemMocDauPhien());
  }

  // Thiếu điểm mốc này thì bản đồ chủ nuôi trống tới khi người chăm đi đủ 10 m
  Future<void> _diemMocDauPhien() async {
    try {
      _nhanViTri(
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 20),
          ),
        ),
      );
    } on Exception {
      FlutterForegroundTask.sendDataToMain(const {
        'loai': gpsGoiLoi,
        'code': 'GPS_BI_TAT',
      });
    }
  }

  void _batDauNgheViTri() {
    _subViTri?.cancel();
    _subViTri =
        Geolocator.getPositionStream(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: gpsDistanceFilterMet,
          ),
        ).listen(
          _nhanViTri,
          onError: (Object e) {
            _subViTri = null;
            FlutterForegroundTask.sendDataToMain(const {
              'loai': gpsGoiLoi,
              'code': 'GPS_BI_TAT',
            });
          },
        );
  }

  void _nhanViTri(Position p) {
    // Luồng đọc một lần và luồng theo dõi cùng phát fix đầu tiên, không chặn thì lưu trùng
    if (_tsCuoi == p.timestamp) return;
    _tsCuoi = p.timestamp;
    _moiNhat = p;
    _congQuangDuong(p);
    _buffer.add(
      _DiemGo(
        lat: p.latitude,
        lng: p.longitude,
        clientTs: p.timestamp,
        isMocked: p.isMocked,
      ),
    );
    if (_buffer.length > _tranBufferDiem) _buffer.removeAt(0);

    if (!_daGuiDiemDau) {
      _daGuiDiemDau = true;
      _socket?.guiViTri(lat: p.latitude, lng: p.longitude);
    }
    FlutterForegroundTask.sendDataToMain({
      'loai': gpsGoiViTri,
      'lat': p.latitude,
      'lng': p.longitude,
      'kmDaDi': _kmDaDi,
    });
    if (_buffer.length >= gpsSoDiemMoiBatch) unawaited(_flush());
  }

  void _congQuangDuong(Position p) {
    final truoc = _diemTruoc;
    _diemTruoc = p;
    if (truoc == null) return;
    final met = Geolocator.distanceBetween(
      truoc.latitude,
      truoc.longitude,
      p.latitude,
      p.longitude,
    );
    final giay = p.timestamp.difference(truoc.timestamp).inMilliseconds / 1000;
    if (giay <= 0) return;
    final kmh = (met / giay) * 3.6;
    if (kmh <= _nguongSpikeKmh) _kmDaDi += met / 1000;
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    final p = _moiNhat;
    if (p != null) _socket?.guiViTri(lat: p.latitude, lng: p.longitude);
    if (_subViTri == null) _batDauNgheViTri();
    final quaHan = DateTime.now().difference(_flushCuoi) >= gpsFlushToiDa;
    if (_buffer.isNotEmpty && quaHan) unawaited(_flush());
  }

  Future<void> _flush() async {
    final dio = _dio;
    final bookingId = _bookingId;
    if (_dangFlush || dio == null || bookingId == null || _buffer.isEmpty) {
      return;
    }
    _dangFlush = true;
    final goi = List<_DiemGo>.from(_buffer);
    _buffer.clear();
    try {
      await dio.post(
        '/gps/waypoints/batch',
        data: {
          'bookingId': bookingId,
          'waypoints': goi.map((d) => d.toJson()).toList(),
        },
      );
      _flushCuoi = DateTime.now();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403 || status == 404) {
        FlutterForegroundTask.sendDataToMain(const {
          'loai': gpsGoiLoi,
          'code': 'MAT_QUYEN_GHI_LO_TRINH',
        });
        await FlutterForegroundTask.stopService();
      } else if (status == 400) {
        FlutterForegroundTask.sendDataToMain(const {
          'loai': gpsGoiLoi,
          'code': 'BATCH_BI_TU_CHOI',
        });
      } else {
        _buffer.insertAll(0, goi);
        if (_buffer.length > _tranBufferDiem) {
          _buffer.removeRange(0, _buffer.length - _tranBufferDiem);
        }
      }
    } finally {
      _dangFlush = false;
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _subViTri?.cancel();
    _subViTri = null;
    await _flush();
    _socket?.dong();
    _socket = null;
  }
}
