import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_radius.dart';

// Tỉ lệ thẻ CCCD chuẩn 85.6 x 54 mm
const double tiLeTheCccd = 85.6 / 54;

const double tiLeRongKhungNgam = 0.88;

// Khung ngắm 4 góc dùng góc thay viền kín để không che mép thẻ
class IdCardFrame extends StatelessWidget {
  final Widget child;
  final Color color;

  const IdCardFrame({super.key, required this.child, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _KhungNgamPainter(mauGoc: color),
      child: child,
    );
  }
}

// Khung ngắm giữa màn camera
class IdCardViewfinder extends StatelessWidget {
  final Color color;

  const IdCardViewfinder({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _KhungNgamPainter(mauGoc: color, phuMoBenNgoai: true),
    );
  }
}

class _KhungNgamPainter extends CustomPainter {
  final Color mauGoc;
  final bool phuMoBenNgoai;

  static const double _canhGoc = 26;
  static const double _boGoc = 10;

  _KhungNgamPainter({required this.mauGoc, this.phuMoBenNgoai = false});

  @override
  void paint(Canvas canvas, Size size) {
    final khung = phuMoBenNgoai ? _khungGiua(size) : Offset.zero & size;
    if (phuMoBenNgoai) _veLopMo(canvas, size, khung);
    _veBonGoc(canvas, khung);
  }

  Rect _khungGiua(Size size) {
    final rong = size.width * tiLeRongKhungNgam;
    return Rect.fromCenter(
      center: size.center(Offset.zero),
      width: rong,
      height: rong / tiLeTheCccd,
    );
  }

  void _veLopMo(Canvas canvas, Size size, Rect khung) {
    final lo = RRect.fromRectAndRadius(
      khung,
      const Radius.circular(AppRadius.radius14),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(lo),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
  }

  void _veBonGoc(Canvas canvas, Rect r) {
    final duong = Path()
      ..moveTo(r.left, r.top + _canhGoc)
      ..lineTo(r.left, r.top + _boGoc)
      ..quadraticBezierTo(r.left, r.top, r.left + _boGoc, r.top)
      ..lineTo(r.left + _canhGoc, r.top)
      ..moveTo(r.right - _canhGoc, r.top)
      ..lineTo(r.right - _boGoc, r.top)
      ..quadraticBezierTo(r.right, r.top, r.right, r.top + _boGoc)
      ..lineTo(r.right, r.top + _canhGoc)
      ..moveTo(r.right, r.bottom - _canhGoc)
      ..lineTo(r.right, r.bottom - _boGoc)
      ..quadraticBezierTo(r.right, r.bottom, r.right - _boGoc, r.bottom)
      ..lineTo(r.right - _canhGoc, r.bottom)
      ..moveTo(r.left + _canhGoc, r.bottom)
      ..lineTo(r.left + _boGoc, r.bottom)
      ..quadraticBezierTo(r.left, r.bottom, r.left, r.bottom - _boGoc)
      ..lineTo(r.left, r.bottom - _canhGoc);
    canvas.drawPath(
      duong,
      Paint()
        ..color = mauGoc
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _KhungNgamPainter oldDelegate) =>
      mauGoc != oldDelegate.mauGoc ||
      phuMoBenNgoai != oldDelegate.phuMoBenNgoai;
}
