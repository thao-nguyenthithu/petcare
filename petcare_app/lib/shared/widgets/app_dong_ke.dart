import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';

// Kẻ ngang dùng chung
class AppDongKe extends StatelessWidget {
  const AppDongKe({super.key, this.dem = false});

  final bool dem;

  @override
  Widget build(BuildContext context) {
    const ke = Divider(height: 1, thickness: 1, color: AppColors.neutralLight);
    if (!dem) return ke;
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.blockGap),
      child: ke,
    );
  }
}
