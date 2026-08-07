import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Icon kèm chấm báo đang bật ở góc trên phải
class ActiveDotIcon extends StatelessWidget {
  const ActiveDotIcon({
    super.key,
    required this.icon,
    required this.dangBat,
    this.size = 24,
  });

  static const double _coCham = 8;
  final IconData icon;
  final bool dangBat;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          icon,
          size: size,
          color: dangBat ? AppColors.primaryColor : AppColors.textSecondary,
        ),
        if (dangBat)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: _coCham,
              height: _coCham,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
