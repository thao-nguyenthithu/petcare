import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Header xanh gọn dùng cho các tab NCC không có
class GreenTitleHeader extends StatelessWidget {
  const GreenTitleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.bottom,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (onBack != null) ...[
                    _BackButton(onTap: onBack!),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.textWhite.withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ],
                ],
              ),
              if (bottom != null) ...[const SizedBox(height: 16), bottom!],
            ],
          ),
        ),
      ),
    );
  }
}

// Nút back trắng trên header xanh
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: const SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.textWhite,
        ),
      ),
    );
  }
}
