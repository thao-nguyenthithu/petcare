import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Mục Giới thiệu bản thân
class SitterProfileBio extends StatelessWidget {
  const SitterProfileBio({super.key, this.bio = ''});

  final String bio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trong = bio.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.gioiThieu, style: AppTextStyles.h3),
        const SizedBox(height: 8),
        Text(
          trong ? l10n.chuaCo : bio,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            fontStyle: trong ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}
