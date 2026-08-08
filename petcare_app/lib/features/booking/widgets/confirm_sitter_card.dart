import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

const double _avatar = 44;

class ConfirmSitterCard extends StatelessWidget {
  const ConfirmSitterCard({super.key, required this.sitter});

  final SitterProfile sitter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coDanhGia = sitter.totalReviews > 0;
    return Row(
      children: [
        UserAvatar(
          name: sitter.fullName,
          imageUrl: sitter.avatarUrl,
          size: _avatar,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sitter.fullName,
                style: AppTextStyles.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (coDanhGia)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      sitter.ratingAvg.toStringAsFixed(1),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${sitter.totalReviews})',
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                )
              else
                Text(l10n.chuaCoDanhGia, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }
}
