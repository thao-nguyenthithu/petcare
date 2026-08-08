import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_controller.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_task.dart';

// Khoảng cách tới điểm trả
class WalkReturnDistance extends StatefulWidget {
  const WalkReturnDistance({
    super.key,
    required this.phien,
    required this.builder,
  });

  final WalkingSession phien;

  // Nghe GPS ở đây nên mỗi gói chỉ dựng lại phần này
  final Widget Function(BuildContext context, WalkingSession phien) builder;

  @override
  State<WalkReturnDistance> createState() => _WalkReturnDistanceState();
}

class _WalkReturnDistanceState extends State<WalkReturnDistance> {
  int? _met;

  @override
  void initState() {
    super.initState();
    WalkTrackingController.ngheDuLieu(_nhanDuLieu);
  }

  @override
  void dispose() {
    WalkTrackingController.thoiNghe(_nhanDuLieu);
    super.dispose();
  }

  void _nhanDuLieu(Object data) {
    final diemTra = widget.phien.don.viTri;
    if (diemTra == null || data is! Map || data['loai'] != gpsGoiViTri) return;
    final lat = data['lat'];
    final lng = data['lng'];
    if (lat is! num || lng is! num) return;
    final met = const Distance()
        .as(LengthUnit.Meter, LatLng(lat.toDouble(), lng.toDouble()), diemTra)
        .round();
    if (met == _met) return;
    setState(() => _met = met);
  }

  @override
  Widget build(BuildContext context) {
    final met = _met;
    return widget.builder(
      context,
      met == null ? widget.phien : widget.phien.copyWith(metConToiDiemTra: met),
    );
  }
}
