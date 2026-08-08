import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';

// Thanh nút cố định dưới cùng màn Lưu, Xoá
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child, this.vien = true});

  final Widget child;
  final bool vien;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: vien
            ? const Border(top: BorderSide(color: AppColors.neutralLight))
            : null,
      ),
      child: SafeArea(top: false, child: child),
    );
  }
}
