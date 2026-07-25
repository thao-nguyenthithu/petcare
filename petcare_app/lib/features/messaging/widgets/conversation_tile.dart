import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/data/conversation.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Thẻ một hội thoại trong danh sách Tin nhắn
class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key, required this.conversation, this.onTap});

  final Conversation conversation;
  final VoidCallback? onTap;

  ({String label, Color background, Color textColor}) _statusStyle(
    BuildContext context,
  ) {
    final l10n = context.l10n;
    switch (conversation.state) {
      case ConversationState.sapToi:
        return (
          label: l10n.sapToi,
          background: AppColors.accent.withValues(alpha: 0.12),
          textColor: AppColors.accent,
        );
      case ConversationState.dangDienRa:
        return (
          label: l10n.dangDienRa,
          background: AppColors.primaryColor,
          textColor: AppColors.textWhite,
        );
      case ConversationState.daHoanTat:
        return (
          label: l10n.daHoanTat,
          background: AppColors.cardMint,
          textColor: AppColors.primaryColor,
        );
      case ConversationState.daKetThuc:
        return (
          label: l10n.daKetThuc,
          background: AppColors.neutralLight,
          textColor: AppColors.textSecondary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = conversation;
    final ketThuc = c.daKetThuc;
    final status = _statusStyle(context);
    final preview = c.fromMe
        ? '${l10n.banTienTo}${c.lastMessage}'
        : c.lastMessage;
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: ketThuc ? 0.45 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                name: c.partnerName,
                imageUrl: c.partnerAvatar,
                size: 48,
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  c.partnerName,
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.labelGap),
                              AppStatusBadge(
                                label: status.label,
                                background: status.background,
                                textColor: status.textColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.labelGap),
                        Text(
                          c.timeLabel,
                          style: AppTextStyles.captionSm.copyWith(
                            fontSize: 11,
                            color: c.chuaDoc
                                ? AppColors.primaryColor
                                : AppColors.textSecondary,
                            fontWeight: c.chuaDoc
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${c.serviceContext} · ${c.bookingCode}',
                            style: AppTextStyles.captionSm.copyWith(
                              fontSize: 13,
                              color: ketThuc
                                  ? AppColors.textSecondary
                                  : AppColors.primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (c.chuaDoc) ...[
                          const SizedBox(width: AppSpacing.labelGap),
                          const _UnreadDot(),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      preview,
                      style: AppTextStyles.captionSm.copyWith(
                        fontSize: 13,
                        color: c.chuaDoc
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: c.chuaDoc
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadDot extends StatelessWidget {
  const _UnreadDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    );
  }
}
