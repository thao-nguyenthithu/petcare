import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Nút tròn nền đen mờ đặt trên ảnh header trang cá nhân
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.3),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textWhite),
        ),
      ),
    );
  }
}
