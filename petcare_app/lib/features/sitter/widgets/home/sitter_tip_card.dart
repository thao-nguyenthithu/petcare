import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/widgets/icon_box.dart';

// Mẹo tăng đơn
class SitterTipCard extends StatelessWidget {
  const SitterTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBox(
            icon: Icons.lightbulb_outline,
            size: 38,
            iconSize: 20,
            iconColor: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.meoTangDon,
                  style: AppTextStyles.label.copyWith(fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.textGap),
                Text(l10n.meoTangDonMoTa, style: AppTextStyles.captionSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
