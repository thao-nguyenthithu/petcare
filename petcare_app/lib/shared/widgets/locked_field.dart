import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Ô chỉ đọc nền xám có icon khoá
class LockedField extends StatelessWidget {
  const LockedField({super.key, this.label, required this.value});

  final String? label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final o = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.neutralLight,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              (value != null && value!.isNotEmpty) ? value! : '—',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
    if (label == null) return o;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.labelGap),
        o,
      ],
    );
  }
}
