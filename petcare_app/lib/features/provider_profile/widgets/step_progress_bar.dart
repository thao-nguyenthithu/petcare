import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? AppColors.primaryColor
                  : AppColors.neutral,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
