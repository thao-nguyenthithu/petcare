import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Ô icon nền sáng bo góc dùng lại ở nhiều khối của tab Công việc.
class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
    this.iconColor = AppColors.primaryColor,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}
