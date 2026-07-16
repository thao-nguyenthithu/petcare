import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();
  static const String _f = 'Inter';

  // w700
  static const TextStyle h1 = TextStyle(
    fontFamily: _f,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 30 / 24,
    color: AppColors.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _f,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 26 / 20,
    color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _f,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 24 / 18,
    color: AppColors.textPrimary,
  );
  static const TextStyle button = TextStyle(
    fontFamily: _f,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    height: 24 / 15,
    color: AppColors.textWhite,
  );

  // w600
  static const TextStyle label = TextStyle(
    fontFamily: _f,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  // w400
  static const TextStyle captionSm = TextStyle(
    fontFamily: _f,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _f,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _f,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 24 / 15,
    color: AppColors.textSecondary,
  );
}
