import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class MapNoticeBanner extends StatelessWidget {
  const MapNoticeBanner({
    super.key,
    required this.tieuDe,
    required this.moTa,
    required this.nhanChinh,
    required this.nhanPhu,
    required this.onChinh,
    required this.onPhu,
  });

  final String tieuDe;
  final String moTa;
  final String nhanChinh;
  final String nhanPhu;
  final VoidCallback onChinh;
  final VoidCallback onPhu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.radius14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tieuDe, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.textGap),
            Text(moTa, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.itemGap),
            Row(
              children: [
                Expanded(
                  child: AppButton(text: nhanChinh, height: 40, onTap: onChinh),
                ),
                const SizedBox(width: AppSpacing.itemGap),
                Expanded(
                  child: AppButton(
                    text: nhanPhu,
                    outlined: true,
                    height: 40,
                    onTap: onPhu,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MapCurrentLocationBanner extends StatelessWidget {
  const MapCurrentLocationBanner({super.key, required this.onLuu});

  final VoidCallback onLuu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: AppCard(
        nen: AppColors.cardMint,
        vien: false,
        child: Row(
          children: [
            const Icon(
              Icons.my_location_rounded,
              size: 20,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.dangTimQuanhViTriHienTai,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  Text(
                    l10n.khongPhaiDiaChiDaLuu,
                    style: AppTextStyles.captionSm,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onLuu,
              child: Text(
                l10n.luuLai,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
