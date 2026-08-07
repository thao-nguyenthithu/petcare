import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Khối chọn có danh sách xổ dính liền ngay dưới, cùng một khung viền
class ExpandSelectBox extends StatelessWidget {
  const ExpandSelectBox({
    super.key,
    required this.dong,
    required this.dangMo,
    required this.onMoDong,
    this.danhSach,
    this.mauVien,
    this.mauNen,
    this.doDayVien = 1.5,
  });

  final Widget dong;
  final bool dangMo;
  final VoidCallback? onMoDong;
  final Widget? danhSach;
  final Color? mauVien;
  final Color? mauNen;
  final double doDayVien;

  @override
  Widget build(BuildContext context) {
    final bo = BorderRadius.circular(AppRadius.radius14);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: mauNen ?? AppColors.surface,
        borderRadius: bo,
      ),
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: mauVien ?? AppColors.primaryColor,
          width: doDayVien,
        ),
        borderRadius: bo,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMoDong,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  Expanded(child: dong),
                  Icon(
                    dangMo ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (dangMo && danhSach != null) ...[const AppDongKe(), danhSach!],
        ],
      ),
    );
  }
}
