import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    fontFamily: 'Inter',
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textWhite,
        disabledBackgroundColor: AppColors.neutral,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      height: 60,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryColor
              : AppColors.textSecondary,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTextStyles.captionSm.copyWith(
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryColor
              : AppColors.textSecondary,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primaryColor,
      showCheckmark: false,
      // Không viền — chip nổi bằng bóng, cùng độ nổi với card trong màn
      side: BorderSide.none,
      shape: const StadiumBorder(),
      elevation: 2,
      pressElevation: 4,
      shadowColor: AppColors.shadow,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      labelStyle: AppTextStyles.label.copyWith(
        fontWeight: FontWeight.w400,
        color: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.textWhite
              : AppColors.textPrimary,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.neutral, width: 1.5),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
        ),
        textStyle: AppTextStyles.label,
      ),
    ),
  );
}
