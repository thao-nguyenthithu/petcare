import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Chấm chỉ số trang
class PageDots extends StatelessWidget {
  const PageDots({
    super.key,
    required this.count,
    required this.current,
    this.dotSize = 8,
    this.activeWidth = 22,
    this.gap = 10,
  });

  final int count;
  final int current;
  final double dotSize;
  final double activeWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: gap / 2),
          width: active ? activeWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryColor : AppColors.neutral,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
