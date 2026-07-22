import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Ô nhập tìm kiếm dính đầu màn, kèm nút Huỷ thoát màn
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onHuy,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onHuy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.itemGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: AppColors.surface,
              elevation: 2,
              shadowColor: AppColors.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: AppSpacing.cardPadding),
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.itemGap),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          hintText: l10n.timDichVuNguoiCham,
                          hintStyle: AppTextStyles.body,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.itemGap),
                  ],
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: onHuy,
            child: Text(
              l10n.huy,
              style: AppTextStyles.label.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
