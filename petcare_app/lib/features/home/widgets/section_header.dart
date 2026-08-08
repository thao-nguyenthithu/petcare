import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Tiêu đề section trên màn Home, kèm nút mũi tên xem thêm
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onTapMore});

  final String title;
  final VoidCallback? onTapMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.h3)),
          if (onTapMore != null)
            IconButton(
              onPressed: onTapMore,
              icon: const Icon(Icons.chevron_right, color: AppColors.accent),
            ),
        ],
      ),
    );
  }
}
