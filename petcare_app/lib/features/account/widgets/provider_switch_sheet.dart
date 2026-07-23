import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Bottom sheet chuyển sang chế độ Người cung cấp
Future<bool?> showProviderSwitchSheet(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.cardMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.chuyenSangCheDoNguoiCungCap,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.radius14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.dangChoOCheDoNCC, style: AppTextStyles.label),
                      const SizedBox(height: 3),
                      Text(l10n.tomTatDonCho, style: AppTextStyles.captionSm),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppButton(
            text: l10n.chuyenCheDo,
            onTap: () => Navigator.pop(sheetContext, true),
          ),
          const SizedBox(height: 6),
          AppButton(
            text: l10n.oLaiCheDoChuNuoi,
            flat: true,
            color: AppColors.textSecondary,
            onTap: () => Navigator.pop(sheetContext, false),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
