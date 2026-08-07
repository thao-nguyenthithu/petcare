import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';

// Chú thích ý nghĩa 4 màu trạng thái
class PreventionLegend extends StatelessWidget {
  const PreventionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.itemGap,
      runSpacing: AppSpacing.labelGap,
      children: [
        for (final trangThai in PreventionStatus.values)
          if (trangThai != PreventionStatus.chuaGhi) _Muc(trangThai: trangThai),
      ],
    );
  }
}

class _Muc extends StatelessWidget {
  const _Muc({required this.trangThai});

  final PreventionStatus trangThai;

  @override
  Widget build(BuildContext context) {
    final kieu = preventionLegendStyle(trangThai);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(kieu.icon, size: 16, color: kieu.mau),
        const SizedBox(width: AppSpacing.textGap),
        Text(
          preventionStatusLabel(context, trangThai),
          style: AppTextStyles.captionSm,
        ),
      ],
    );
  }
}
