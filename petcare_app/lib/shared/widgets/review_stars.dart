import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

class ReviewStars extends StatelessWidget {
  const ReviewStars({super.key, required this.so, this.co = 14});

  final int so;
  final double co;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < so ? Icons.star_rounded : Icons.star_outline_rounded,
            size: co,
            color: AppColors.accent,
          ),
      ],
    );
  }
}
