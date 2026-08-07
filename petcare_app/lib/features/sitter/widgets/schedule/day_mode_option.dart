import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/sitter_availability.dart';

// Một lựa chọn cách nhận đơn trong ngày
class DayModeOption extends StatelessWidget {
  const DayModeOption({
    super.key,
    required this.mode,
    required this.dangChon,
    required this.tieuDe,
    required this.onTap,
    this.moTa,
    this.duoi,
    this.khoa = false,
  });

  final DayMode mode;
  final bool dangChon;
  final String tieuDe;
  final VoidCallback onTap;
  final String? moTa;
  final Widget? duoi;
  final bool khoa;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: dangChon ? AppColors.cardMint : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: khoa ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.itemGap),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(
              color: dangChon ? AppColors.primaryColor : AppColors.neutralLight,
              width: dangChon ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Radio<DayMode>(value: mode, enabled: !khoa),
                  const SizedBox(width: AppSpacing.textGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tieuDe,
                          style: AppTextStyles.label.copyWith(
                            color: khoa
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (moTa != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            moTa!,
                            style: AppTextStyles.captionSm.copyWith(
                              color: khoa
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (duoi != null) ...[
                const SizedBox(height: AppSpacing.labelGap),
                duoi!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
