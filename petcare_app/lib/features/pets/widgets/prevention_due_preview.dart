import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Ô chỉ đọc hiện ngày tới hạn mũi kế tiếp
class PreventionDuePreview extends StatelessWidget {
  const PreventionDuePreview({super.key, required this.ngayToiHan});

  final DateTime? ngayToiHan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.ngayToiHanKeTiep,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        AppCard(
          width: double.infinity,
          nen: AppColors.cardMint,
          vien: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ngayToiHan == null
                    ? l10n.chuaChonNgayTiem
                    : ngayThangNam(ngayToiHan!),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.textGap),
              Text(l10n.ghiChuNgayToiHan, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }
}
