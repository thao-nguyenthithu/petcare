import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';

// Ô nhập tìm kiếm dính đầu màn
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilter,
    this.filterOpen = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;
  final bool filterOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.itemGap,
      ),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: AppSearchField(
              controller: controller,
              onChanged: onChanged,
              hintText: context.l10n.timDichVuNguoiCham,
              autofocus: true,
              height: 52,
              fillColor: AppColors.surface,
              elevation: 2,
              filterOpen: filterOpen,
              onToggleFilter: onFilter,
            ),
          ),
        ],
      ),
    );
  }
}
