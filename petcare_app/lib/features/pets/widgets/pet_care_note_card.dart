import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Khối Lưu ý chăm sóc ở màn hồ sơ bé
class PetCareNoteCard extends StatelessWidget {
  const PetCareNoteCard({
    super.key,
    required this.tieuDe,
    required this.noiDung,
    this.ghiChu,
  });

  final String tieuDe;
  final String noiDung;
  final String? ghiChu;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      nen: AppColors.cardMint,
      vien: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tieuDe,
            style: AppTextStyles.label.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Text(
            noiDung,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (ghiChu != null) ...[
            const SizedBox(height: AppSpacing.labelGap),
            Text(ghiChu!, style: AppTextStyles.captionSm),
          ],
        ],
      ),
    );
  }
}
