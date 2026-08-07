import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/grooming_form.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/widgets/services/choice_pill_row.dart';
import 'package:petcare_app/features/sitter/widgets/services/grooming_package_note.dart';
import 'package:petcare_app/features/sitter/widgets/services/grooming_price_table.dart';

// Ô nào có giá thì bắt buộc có thời lượng kèm
class GroomingFields extends StatelessWidget {
  const GroomingFields({
    super.key,
    required this.form,
    required this.hienLoi,
    required this.onChanged,
  });

  final GroomingForm form;
  final bool hienLoi;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thieuGoi = hienLoi && form.goiNhan.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.goiNayGom, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.titleGap),
        ChoicePillRow(
          items: [
            for (final goi in GroomingPackage.values)
              (
                nhan: groomingPackageName(context, goi),
                chon: form.goiNhan.contains(goi),
                onTap: () {
                  form.doiGoi(goi);
                  onChanged();
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(
          thieuGoi ? l10n.chonItNhatMotGoi : l10n.chonGoiBanCungCap,
          style: AppTextStyles.captionSm.copyWith(
            color: thieuGoi ? AppColors.error : null,
          ),
        ),
        const SizedBox(height: 14),
        const GroomingPackageNote(),
        for (final goi in GroomingPackage.values)
          if (form.goiNhan.contains(goi)) ...[
            const SizedBox(height: AppSpacing.blockGap),
            GroomingPriceTable(
              goi: goi,
              form: form,
              hienLoi: hienLoi,
              onChanged: onChanged,
            ),
          ],
      ],
    );
  }
}
