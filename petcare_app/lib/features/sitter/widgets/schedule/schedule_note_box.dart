import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Hộp ghi chú một dòng trong các sheet giờ rảnh
class ScheduleNoteBox extends StatelessWidget {
  const ScheduleNoteBox({
    super.key,
    required this.noiDung,
    this.canhBao = false,
  });

  final String noiDung;
  final bool canhBao;

  @override
  Widget build(BuildContext context) {
    final mau = canhBao ? AppColors.accent : AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.itemGap),
      decoration: BoxDecoration(
        color: canhBao ? mau.withValues(alpha: 0.12) : AppColors.cardMint,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            canhBao ? Icons.warning_amber_rounded : Icons.info_outline,
            size: 18,
            color: mau,
          ),
          const SizedBox(width: AppSpacing.labelGap),
          Expanded(
            child: Text(
              noiDung,
              style: AppTextStyles.captionSm.copyWith(color: mau),
            ),
          ),
        ],
      ),
    );
  }
}
