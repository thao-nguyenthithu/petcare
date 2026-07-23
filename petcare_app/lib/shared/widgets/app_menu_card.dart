import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Chip icon tròn nền nhạt, dùng cho đầu dòng menu và các thẻ tương tự.
class AppIconChip extends StatelessWidget {
  const AppIconChip({
    super.key,
    required this.icon,
    this.size = 36, // đường kính chip
    this.iconSize = 18,
    this.background = AppColors.cardMint,
    this.iconColor = AppColors.primaryColor,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color background;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: iconSize, color: iconColor),
    );
  }
}

// Một dòng trong thẻ menu: chip icon (tuỳ chọn) + nhãn + phụ đề (tuỳ chọn) +
// phần đuôi (mặc định mũi tên). danger = true tô màu accent nhấn mạnh.
class AppMenuTile extends StatelessWidget {
  const AppMenuTile({
    super.key,
    this.icon,
    required this.label,
    this.labelStyle,
    this.subtitle,
    this.onTap,
    this.danger = false,
    this.trailing,
  });

  final IconData? icon; // null thì không hiện chip icon
  final String label;
  final TextStyle? labelStyle; // null là AppTextStyles.label
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger; // dòng nhấn mạnh
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final baseStyle = labelStyle ?? AppTextStyles.label;
    final styleNhan = danger
        ? baseStyle.copyWith(color: AppColors.accent)
        : baseStyle;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: 14,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                AppIconChip(
                  icon: icon!,
                  background: danger
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.cardMint,
                  iconColor: danger ? AppColors.accent : AppColors.primaryColor,
                ),
                const SizedBox(width: AppSpacing.itemGap),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: styleNhan),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: AppTextStyles.captionSm),
                    ],
                  ],
                ),
              ),
              trailing ??
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// Gom các dòng menu, chèn kẻ ngăn thụt đều giữa các dòng ngang
class AppMenuCard extends StatelessWidget {
  const AppMenuCard({super.key, required this.tiles});

  final List<AppMenuTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0)
            const Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacing.cardPadding,
              endIndent: AppSpacing.cardPadding,
              color: AppColors.neutralLight,
            ),
          tiles[i],
        ],
      ],
    );
  }
}
