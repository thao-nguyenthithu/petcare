import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Link chữ cam
class ScheduleTextLink extends StatelessWidget {
  const ScheduleTextLink({super.key, required this.nhan, required this.onTap});

  final String nhan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppTextStyles.label.copyWith(fontSize: 13),
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(nhan),
    );
  }
}
