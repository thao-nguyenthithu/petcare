import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Một dòng icon nhỏ rồi tới câu chữ
class IconTextRow extends StatelessWidget {
  const IconTextRow({
    super.key,
    required this.icon,
    required this.chu,
    this.moTa,
    this.mauIcon = AppColors.primaryColor,
    this.mauChu,
    this.coIcon = 18,
    this.hoIcon = 10,
  });

  final IconData icon;
  final String chu;
  final String? moTa;
  final Color mauIcon;
  final Color? mauChu;
  final double coIcon;
  final double hoIcon;

  @override
  Widget build(BuildContext context) {
    final kieuChinh = moTa == null
        ? AppTextStyles.captionSm
        : AppTextStyles.label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: coIcon, color: mauIcon),
        SizedBox(width: hoIcon),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chu,
                style: mauChu == null
                    ? kieuChinh
                    : kieuChinh.copyWith(color: mauChu),
              ),
              if (moTa case final m?) ...[
                const SizedBox(height: AppSpacing.textGap),
                Text(m, style: AppTextStyles.captionSm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
