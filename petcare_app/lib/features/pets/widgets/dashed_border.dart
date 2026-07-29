import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Vẽ viền đứt quanh một khối bo góc
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.boGoc,
    this.mau = AppColors.neutralLight,
    this.doDay = 1,
    this.net = 6,
    this.ho = 4,
  });

  final double boGoc;
  final Color mau;
  final double doDay;

  final double net;
  final double ho;

  @override
  void paint(Canvas canvas, Size size) {
    final duong = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(boGoc)),
      );
    final but = Paint()
      ..color = mau
      ..style = PaintingStyle.stroke
      ..strokeWidth = doDay;
    for (final doan in duong.computeMetrics()) {
      var batDau = 0.0;
      while (batDau < doan.length) {
        final ketThuc = (batDau + net).clamp(0.0, doan.length);
        canvas.drawPath(doan.extractPath(batDau, ketThuc), but);
        batDau = ketThuc + ho;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) =>
      oldDelegate.boGoc != boGoc ||
      oldDelegate.mau != mau ||
      oldDelegate.doDay != doDay;
}
