import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Chip chọn dạng pill trong form cấu hình dịch vụ NCC
class ServiceFormChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ServiceFormChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primaryColor : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected ? null : Border.all(color: AppColors.neutral),
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: selected ? AppColors.textWhite : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
