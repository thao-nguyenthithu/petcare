import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';

// Chip hệ thống mở phiên hoặc nhắc an toàn
class ChatSystemChip extends StatelessWidget {
  const ChatSystemChip({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final safety = message.systemKind == ChatSystemKind.safety;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: safety ? AppColors.cardMint : AppColors.neutralLight,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (safety) ...[
              const Icon(
                Icons.verified_user_outlined,
                size: 14,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                safety
                    ? l10n.giaoDichTrongApp
                    : l10n.phienBatDauChat(message.text),
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSm.copyWith(
                  fontSize: safety ? 12 : 10,
                  color: safety
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
