import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/widgets/dashed_border.dart';

// Ô thêm mới nền mint nhạt, viền đứt
class DashedAddButton extends StatelessWidget {
  const DashedAddButton({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: CustomPaint(
          painter: const DashedBorderPainter(boGoc: AppRadius.radius14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.cardPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 18, color: AppColors.primaryColor),
                const SizedBox(width: AppSpacing.labelGap),
                Text(
                  text,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
