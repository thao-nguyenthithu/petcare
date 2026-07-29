import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';

// Kẻ ngang dùng chung
class AppDongKe extends StatelessWidget {
  const AppDongKe({
    super.key,
    this.dem = false,
    this.mau = AppColors.neutralLight,
    this.thut = 0,
    this.thutCuoi = 0,
  });

  final bool dem;
  final Color mau;
  final double thut;
  final double thutCuoi;

  @override
  Widget build(BuildContext context) {
    final ke = Divider(
      height: 1,
      thickness: 1,
      color: mau,
      indent: thut,
      endIndent: thutCuoi,
    );
    if (!dem) return ke;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.blockGap),
      child: ke,
    );
  }
}

class AppDongKeDoc extends StatelessWidget {
  const AppDongKeDoc({super.key, required this.cao});

  final double cao;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: cao, color: AppColors.neutralLight);
}
