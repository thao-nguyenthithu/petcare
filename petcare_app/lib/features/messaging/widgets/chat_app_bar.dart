import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/data/conversation.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Hành động trong menu 3 chấm của màn chat
enum ChatMenuAction { xemHoSo, xemChiTietDon, canTroGiup }

// Thanh tiêu đề màn chat
class ChatAppBar extends StatelessWidget {
  const ChatAppBar({super.key, required this.conversation, this.countdown});

  final Conversation conversation;
  final String? countdown; // null = không hiện badge đếm ngược

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = conversation;
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.neutralLight, width: 1),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.labelGap,
            AppSpacing.screenPadding,
            AppSpacing.labelGap,
          ),
          child: Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: AppSpacing.itemGap),
              UserAvatar(
                name: c.partnerName,
                imageUrl: c.partnerAvatar,
                size: 40,
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.partnerName,
                            style: AppTextStyles.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (countdown != null) ...[
                          const SizedBox(width: AppSpacing.labelGap),
                          AppStatusBadge(
                            label: l10n.conLai(countdown!),
                            background: AppColors.primaryColor,
                            textColor: AppColors.textWhite,
                            leading: const Icon(
                              Icons.schedule,
                              size: 11,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      '${c.serviceContext}  ${c.bookingCode}',
                      style: AppTextStyles.captionSm.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.textGap),
              PopupMenuButton<ChatMenuAction>(
                icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                position: PopupMenuPosition.under,
                onSelected: (_) => baoDangPhatTrien(context),
                itemBuilder: (context) => [
                  _menuItem(
                    ChatMenuAction.xemHoSo,
                    Icons.person_outline,
                    l10n.xemHoSo,
                  ),
                  _menuItem(
                    ChatMenuAction.xemChiTietDon,
                    Icons.receipt_long_outlined,
                    l10n.xemChiTietDon,
                  ),
                  _menuItem(
                    ChatMenuAction.canTroGiup,
                    Icons.support_agent_outlined,
                    l10n.canTroGiup,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<ChatMenuAction> _menuItem(
    ChatMenuAction value,
    IconData icon,
    String label, {
    Color color = AppColors.textPrimary,
  }) {
    return PopupMenuItem<ChatMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: AppSpacing.itemGap),
          Text(
            label,
            style: AppTextStyles.body.copyWith(fontSize: 14, color: color),
          ),
        ],
      ),
    );
  }
}
