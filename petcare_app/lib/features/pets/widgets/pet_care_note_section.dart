import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

// Khối Lưu ý chăm sóc ở bước 1, nhập một lần dùng cho mọi đơn
class PetCareNoteSection extends StatelessWidget {
  const PetCareNoteSection({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.luuYChamSoc, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.moTaLuuYChamSoc, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.labelGap),
        AppTextField(
          label: '',
          hint: l10n.hintLuuYChamSoc,
          controller: controller,
          maxLines: 3,
        ),
      ],
    );
  }
}
