import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Ô nhập tìm kiếm dùng chung
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.autofocus = false,
    this.height = 40,
    this.fillColor = AppColors.background,
    this.elevation = 0,
    this.filterOpen = false,
    this.onToggleFilter,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool autofocus;
  final double height;
  final Color fillColor;
  final double elevation;
  final bool filterOpen; // hàng lọc đang mở
  final VoidCallback? onToggleFilter;

  void _clear() {
    controller.clear();
    onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final box = ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return Material(
          color: fillColor,
          elevation: elevation,
          shadowColor: AppColors.shadow,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                const SizedBox(width: AppSpacing.cardPadding),
                SvgPicture.asset('assets/icons/icon_search.svg', width: 20),
                const SizedBox(width: AppSpacing.itemGap),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    autofocus: autofocus,
                    textInputAction: TextInputAction.search,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: hintText,
                      hintStyle: AppTextStyles.body,
                    ),
                  ),
                ),
                if (value.text.isNotEmpty)
                  IconButton(
                    onPressed: _clear,
                    icon: const Icon(Icons.cancel, size: 18),
                    color: AppColors.neutral,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).deleteButtonTooltip,
                  ),
                const SizedBox(width: AppSpacing.labelGap),
              ],
            ),
          ),
        );
      },
    );

    if (onToggleFilter == null) return box;
    return Row(
      children: [
        Expanded(child: box),
        const SizedBox(width: AppSpacing.labelGap),
        IconButton(
          onPressed: onToggleFilter,
          icon: const Icon(Icons.tune_rounded),
          color: filterOpen ? AppColors.primaryColor : AppColors.textSecondary,
        ),
      ],
    );
  }
}
