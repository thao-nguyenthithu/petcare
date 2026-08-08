import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Chip lọc bo tròn
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.backgroundColor = AppColors.background,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelStyle: AppTextStyles.label.copyWith(
        color: selected ? AppColors.primaryColor : AppColors.textSecondary,
      ),
      backgroundColor: backgroundColor,
      selectedColor: AppColors.cardMint,
      elevation: 0,
      pressElevation: 0,
      side: BorderSide(
        color: selected ? AppColors.primaryColor : AppColors.neutralLight,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }
}
