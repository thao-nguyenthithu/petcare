import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Trường chỉ đọc
class LockedField extends StatelessWidget {
  const LockedField({
    super.key,
    this.label,
    required this.value,
    this.nhanTrong = false,
    this.verified = false,
    this.khoa = true,
  });

  final String? label;
  final String? value;
  final bool nhanTrong;
  final bool verified;
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chu = (value != null && value!.isNotEmpty) ? value! : '—';
    final o = Container(
      padding: nhanTrong
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: nhanTrong ? AppColors.background : AppColors.neutralLight,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(
          color: nhanTrong ? AppColors.neutralLight : AppColors.neutral,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: nhanTrong
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label ?? '', style: AppTextStyles.captionSm),
                      const SizedBox(height: 2),
                      Text(chu, style: AppTextStyles.body),
                    ],
                  )
                : Text(
                    chu,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
          ),
          if (verified)
            Row(
              children: [
                const Icon(
                  Icons.verified,
                  size: 16,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.daXacMinh,
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            )
          else if (khoa)
            Icon(
              Icons.lock_outline,
              size: nhanTrong ? 16 : 18,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
    if (label == null || nhanTrong) return o;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.labelGap),
        o,
      ],
    );
  }
}
