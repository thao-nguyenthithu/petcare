import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Trạng thái rỗng: vòng tròn icon, tiêu đề, mô tả căn giữa
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.circleColor = AppColors.surface,
    this.iconColor = AppColors.primaryColor,
    this.action,
    this.gon = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Color circleColor;
  final Color iconColor;
  final Widget? action;
  final bool gon;

  @override
  Widget build(BuildContext context) {
    final canhVong = gon ? 56.0 : 120.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gon ? 0 : 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: canhVong,
            height: canhVong,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: gon ? 20 : 44, color: iconColor),
          ),
          SizedBox(height: gon ? AppSpacing.cardPadding : AppSpacing.groupGap),
          Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
          if (message case final mota?) ...[
            const SizedBox(height: AppSpacing.labelGap),
            Text(mota, style: AppTextStyles.body, textAlign: TextAlign.center),
          ],
          if (action case final nut?) ...[
            SizedBox(
              height: gon ? AppSpacing.cardPadding : AppSpacing.groupGap,
            ),
            nut,
          ],
        ],
      ),
    );
  }
}
