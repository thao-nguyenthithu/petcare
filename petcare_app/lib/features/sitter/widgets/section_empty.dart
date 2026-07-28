import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Trạng thái rỗng gọn cho một section
class SectionEmpty extends StatelessWidget {
  const SectionEmpty({super.key, required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 28),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}
