import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/shared/widgets/dashed_border.dart';

// Khung nét đứt bao nội dung, dùng cho các ô thêm mới
class DottedBox extends StatelessWidget {
  const DottedBox({super.key, required this.child, this.onTap, this.dem = 18});

  final Widget child;
  final VoidCallback? onTap;
  final double dem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: CustomPaint(
        painter: const DashedBorderPainter(
          boGoc: AppRadius.radius14,
          mau: AppColors.neutral,
          doDay: 1.2,
          net: 5,
          ho: 5,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: dem),
          child: child,
        ),
      ),
    );
  }
}
