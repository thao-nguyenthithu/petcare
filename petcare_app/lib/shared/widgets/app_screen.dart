import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Khung màn dùng chung, tự chừa status bar và thanh điều hướng Android
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.body,
    this.header,
    this.bottomBar,
    this.backgroundColor = AppColors.background,
    this.headerTuLoDinh = false,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final Widget? header;
  final Widget? bottomBar;
  final Color backgroundColor;
  final bool headerTuLoDinh;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final phanThan = SafeArea(
      top: false,
      bottom: bottomBar == null,
      child: body,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Column(
        children: [
          if (header case final h?)
            headerTuLoDinh ? h : SafeArea(bottom: false, child: h),
          Expanded(child: phanThan),
          ?bottomBar,
        ],
      ),
    );
  }
}
