import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Một icon Material hoặc file svg, kèm nhãn dưới
class IconOption<T> {
  const IconOption({
    required this.value,
    required this.label,
    this.icon,
    this.asset,
    this.size = 26,
  }) : assert(
         (icon == null) != (asset == null),
         'Truyền đúng một trong hai: icon hoặc asset',
       );

  final T value;
  final String label;
  final IconData? icon;
  final String? asset;
  final double size;
}

class IconOptionRow<T> extends StatelessWidget {
  const IconOptionRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChon,
  });

  final List<IconOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in options) ...[
          if (option != options.first) const SizedBox(width: 32),
          _Option(
            option: option,
            chon: option.value == selected,
            onTap: () => onChon(option.value),
          ),
        ],
      ],
    );
  }
}

class _Option<T> extends StatelessWidget {
  const _Option({
    required this.option,
    required this.chon,
    required this.onTap,
  });

  final IconOption<T> option;
  final bool chon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mau = chon ? AppColors.primaryColor : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.labelGap),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.labelGap,
          vertical: AppSpacing.textGap,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (option.asset != null)
              SvgPicture.asset(
                option.asset!,
                width: option.size,
                height: option.size,
                colorFilter: ColorFilter.mode(mau, BlendMode.srcIn),
              )
            else
              Icon(option.icon, size: option.size, color: mau),
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              option.label,
              style: (chon ? AppTextStyles.labelSm : AppTextStyles.captionSm)
                  .copyWith(
                    color: chon
                        ? AppColors.primaryColor
                        : AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.textGap),
            Container(
              width: 22,
              height: 2,
              decoration: BoxDecoration(
                color: chon ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
