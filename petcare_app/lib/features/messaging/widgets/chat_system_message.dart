import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/data/chat_message.dart';
import 'package:petcare_app/features/messaging/hanh_dong_tin_he_thong.dart';

// Tin sự kiện của đơn trong luồng chat
class ChatSystemMessage extends StatelessWidget {
  const ChatSystemMessage({
    super.key,
    required this.message,
    required this.bookingId,
    required this.laChuNuoi,
  });

  final ChatMessage message;
  final String? bookingId;
  final bool laChuNuoi;

  @override
  Widget build(BuildContext context) {
    final gap = message.canGap;
    final style = (gap ? AppTextStyles.labelSm : AppTextStyles.captionSm)
        .copyWith(color: gap ? AppColors.accent : AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.blockGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gap) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 12,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: AppSpacing.textGap),
              ],
              Flexible(
                child: Text(
                  message.text,
                  textAlign: TextAlign.center,
                  style: style,
                ),
              ),
            ],
          ),
          if (message.actionLabel != null) ...[
            const SizedBox(height: 3),
            InkWell(
              onTap: () => chayHanhDongTin(
                context,
                message.actionCode,
                bookingId,
                laChuNuoi: laChuNuoi,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.actionLabel!,
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
