import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Hàng gợi ý trả lời nhanh
class QuickReplyBar extends StatelessWidget {
  const QuickReplyBar({
    super.key,
    required this.isOwner,
    required this.onSelect,
  });

  final bool isOwner;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final replies = isOwner
        ? [
            l10n.goiYChuBeTheNao,
            l10n.goiYChuXinAnh,
            l10n.goiYChuToiChua,
            l10n.goiYChuUongNuoc,
            l10n.goiYChuCamOn,
          ]
        : [
            l10n.goiYNccDangToi,
            l10n.goiYNccBeNgoan,
            l10n.goiYNccSapXong,
            l10n.goiYNccHoanThanh,
            l10n.goiYNccHenGap,
          ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: replies.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (context, i) =>
            _Chip(label: replies[i], onTap: () => onSelect(replies[i])),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.neutral),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionSm.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
