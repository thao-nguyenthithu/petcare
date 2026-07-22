import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';

// Header ngang: nút back tròn, tiêu đề cùng hàng, hành động phụ bên phải
class AppScreenHeader extends StatelessWidget {
  const AppScreenHeader({
    super.key,
    required this.title,
    this.action,
    this.onBack,
  });

  final String title;
  final Widget? action;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.itemGap,
      ),
      child: Row(
        children: [
          AppBackButton(onTap: onBack),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
