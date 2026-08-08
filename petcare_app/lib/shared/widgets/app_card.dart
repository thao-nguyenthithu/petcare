import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';

// Thẻ nền bo góc dùng chung cho mọi khối nội dung có nền riêng
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.nen = AppColors.surface,
    this.vien = true,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.radius = AppRadius.radius14,
    this.width,
  });

  final Widget child;
  final Color nen;
  final bool vien;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: nen,
        borderRadius: BorderRadius.circular(radius),
        border: vien ? Border.all(color: AppColors.neutralLight) : null,
      ),
      child: child,
    );
  }
}
