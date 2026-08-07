import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/conversation.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';

// Hàng các bé của đơn dưới thanh tiêu đề chat, chỉ dùng khi đơn gom nhiều bé
class ChatPetsBar extends StatelessWidget {
  const ChatPetsBar({super.key, required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = conversation;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
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
          PetAvatarStack(pets: c.pets, size: 26),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Text(
              l10n.soBeVaTen('${c.pets.length}', c.moTaBe),
              style: AppTextStyles.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
