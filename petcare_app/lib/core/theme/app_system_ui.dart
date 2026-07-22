import 'package:flutter/services.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Kiểu hiển thị thanh hệ thống
class AppSystemUi {
  AppSystemUi._();

  // Dùng cho màn nền sáng
  static const SystemUiOverlayStyle onLightBackground = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  // Dùng cho màn có header nền tối
  static const SystemUiOverlayStyle onDarkBackground = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
