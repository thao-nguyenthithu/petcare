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
    required this.message,
    this.circleColor = AppColors.surface,
    this.iconColor = AppColors.primaryColor,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color circleColor;
  final Color iconColor;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.groupGap),
          Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.labelGap),
          Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.groupGap),
            action!,
          ],
        ],
      ),
    );
  }
}
