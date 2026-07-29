import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';

// Thẻ một hạng mục phòng bệnh
class PreventionCard extends StatelessWidget {
  const PreventionCard({super.key, required this.mui, required this.onTap});

  final PreventionRecord mui;
  final VoidCallback onTap;

  static const double _thutDongDuoi = 16 + AppSpacing.labelGap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = mui.trangThai;
    final kieu = preventionCardStyle(trangThai);
    final mauHan = switch (trangThai) {
      PreventionStatus.sapToiHan => AppColors.honey,
      PreventionStatus.quaHan => AppColors.accent,
      PreventionStatus.conHan ||
      PreventionStatus.khongNhac ||
      PreventionStatus.chuaGhi => AppColors.textSecondary,
    };
    final nhanManh =
        trangThai == PreventionStatus.sapToiHan ||
        trangThai == PreventionStatus.quaHan;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutralLight),
            borderRadius: BorderRadius.circular(AppRadius.radius14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(kieu.icon, size: 16, color: kieu.mau),
                  const SizedBox(width: AppSpacing.labelGap),
                  Expanded(
                    child: Text(
                      tenCuaHangMuc(context, mui),
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Text(
                    preventionCountLabel(context, mui),
                    style: AppTextStyles.captionSm,
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.labelGap),
              Padding(
                padding: const EdgeInsets.only(left: _thutDongDuoi),
                child: Row(
                  children: [
                    if (trangThai == PreventionStatus.khongNhac) ...[
                      const Icon(
                        Icons.notifications_off_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.textGap),
                    ],
                    Expanded(
                      child: Text(
                        preventionDueLabel(context, mui),
                        style: AppTextStyles.captionSm.copyWith(
                          color: mauHan,
                          fontWeight: nhanManh ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                    if (mui.anh.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.labelGap),
                      const Icon(
                        Icons.attach_file,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.textGap),
                      Text(
                        l10n.soAnhKem('${mui.anh.length}'),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
