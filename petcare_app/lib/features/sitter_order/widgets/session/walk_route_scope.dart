import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_controller.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_task.dart';
import 'package:petcare_app/shared/services/gps_api_service.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';

// Lộ trình phiên dắt cho phía người chăm, nạp lịch sử rồi nối tiếp bằng điểm realtime
class WalkRouteScope extends StatefulWidget {
  const WalkRouteScope({
    super.key,
    required this.phien,
    required this.builder,
    this.chayDongHo = true,
  });

  final WalkingSession phien;

  // Màn chỉ vẽ bản đồ thì tắt đi, không dựng lại cả bản đồ mỗi giây
  final bool chayDongHo;

  final Widget Function(
    BuildContext context,
    WalkingSession phien,
    List<LatLng> duongDi,
  )
  builder;

  @override
  State<WalkRouteScope> createState() => _WalkRouteScopeState();
}

class _WalkRouteScopeState extends State<WalkRouteScope> {
  final List<LatLng> _duongDi = [];
  Timer? _dongHo;

  String get _bookingId => widget.phien.bookingId ?? widget.phien.don.bookingId;

  @override
  void initState() {
    super.initState();
    WalkTrackingController.ngheDuLieu(_nhanDuLieu);
    _napLichSu();
    if (widget.chayDongHo) {
      _dongHo = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    WalkTrackingController.thoiNghe(_nhanDuLieu);
    super.dispose();
  }

  // Không có bước này thì đăng nhập lại là mất trắng quãng đường đang nằm trên máy chủ
  Future<void> _napLichSu() async {
    try {
      final lichSu = await GpsApiService().lichSuLoTrinh(_bookingId);
      if (!mounted || lichSu.isEmpty) return;
      setState(() => _duongDi.addAll(lichSu));
    } catch (_) {}
  }

  void _nhanDuLieu(Object data) {
    if (!mounted || data is! Map || data['loai'] != gpsGoiViTri) return;
    final lat = data['lat'];
    final lng = data['lng'];
    if (lat is! num || lng is! num) return;
    final diem = LatLng(lat.toDouble(), lng.toDouble());
    if (_duongDi.isNotEmpty && _duongDi.last == diem) return;
    setState(() => _duongDi.add(diem));
  }

  @override
  Widget build(BuildContext context) {
    final goc = widget.phien;
    final bayGio = nowVn();
    final het = goc.ketThucLuc;
    final batDau = goc.batDauLuc;
    final phien = goc.copyWith(
      kmDaDi: _duongDi.length < 2 ? null : kmTuLoTrinh(_duongDi),
      conLai: het == null ? null : dongHoPhutGiay(het.difference(bayGio)),
      phutDaDat: batDau == null
          ? null
          : math.max(0, bayGio.difference(batDau).inMinutes),
    );
    return widget.builder(context, phien, _duongDi);
  }
}
