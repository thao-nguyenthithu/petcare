import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Card button chọn có dot
class ButtonSelect extends StatelessWidget {
  const ButtonSelect({
    super.key,
    required this.selected,
    required this.title,
    this.titleColor,
    this.titleMaxLines = 1,
    this.subtitle,
    this.subtitleMaxLines,
    this.subtitleColor,
    this.borderColor,
    this.note,
    this.badge,
    this.leading,
    this.showIndicator = true,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  final bool selected;
  final String title;
  final Color? titleColor;
  final int titleMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Color? subtitleColor;
  final Color? borderColor;
  final String? note;
  final Widget? badge;
  final Widget? leading;
  final bool showIndicator;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.cardMint : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(
              color:
                  borderColor ??
                  (selected ? AppColors.primaryColor : AppColors.neutralLight),
            ),
          ),
          child: Row(
            children: [
              if (showIndicator) ...[
                leading ?? _SelectionDot(selected: selected),
                const SizedBox(width: AppSpacing.itemGap),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTextStyles.label.copyWith(
                              color: titleColor,
                            ),
                            maxLines: titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: AppSpacing.labelGap),
                          badge!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.textGap),
                      Text(
                        subtitle!,
                        style: AppTextStyles.captionSm.copyWith(
                          color: subtitleColor,
                        ),
                        maxLines: subtitleMaxLines,
                        overflow: subtitleMaxLines == null
                            ? null
                            : TextOverflow.ellipsis,
                      ),
                    ],
                    if (note != null && note!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.textGap),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.sticky_note_2_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              note!,
                              style: AppTextStyles.captionSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.labelGap),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionDot extends StatelessWidget {
  const _SelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryColor : AppColors.neutralLight,
          width: 1,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
