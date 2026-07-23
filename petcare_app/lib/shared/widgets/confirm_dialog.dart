import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Dialog xác nhận dùng chung màn hình: đăng xuất
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String? cancelLabel,
  IconData icon = Icons.help_outline_rounded,
  bool danger = false,
}) async {
  final l10n = context.l10n;
  final mauNhan = danger ? AppColors.accent : AppColors.primaryColor;
  final ketQua = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 16, 20),
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, // đường kính vòng tròn bọc icon
                height: 56,
                decoration: BoxDecoration(
                  color: mauNhan.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: mauNhan, size: 28),
              ),
              const SizedBox(height: 16),
              Text(title, textAlign: TextAlign.center, style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 20),
              AppButton(
                text: confirmLabel,
                color: danger ? AppColors.accent : null,
                onTap: () => Navigator.pop(dialogContext, true),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: cancelLabel ?? l10n.huy,
                outlined: true,
                onTap: () => Navigator.pop(dialogContext, false),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              icon: const Icon(Icons.close_rounded, size: 22),
              color: AppColors.textSecondary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    ),
  );
  return ketQua ?? false;
}
