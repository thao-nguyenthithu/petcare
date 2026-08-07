import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/features/pets/widgets/dashed_add_button.dart';
import 'package:petcare_app/features/pets/widgets/prevention_card.dart';
import 'package:petcare_app/features/pets/widgets/prevention_legend.dart';

// Khối Phòng bệnh định kỳ ở bước 2
class PreventionSection extends StatelessWidget {
  const PreventionSection({
    super.key,
    required this.phongBenh,
    required this.onChonMui,
    required this.onThemMui,
  });

  final List<PreventionRecord> phongBenh;
  final ValueChanged<PreventionRecord> onChonMui;
  final VoidCallback onThemMui;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.phongBenhDinhKy, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.moTaPhongBenhDinhKy, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.itemGap),
        if (phongBenh.isEmpty)
          Text(l10n.chuaCoHangMucNao, style: AppTextStyles.captionSm)
        else ...[
          for (final mui in phongBenh) ...[
            PreventionCard(mui: mui, onTap: () => onChonMui(mui)),
            const SizedBox(height: AppSpacing.itemGap),
          ],
          const PreventionLegend(),
        ],
        const SizedBox(height: AppSpacing.itemGap),
        DashedAddButton(text: l10n.themHangMuc, onTap: onThemMui),
      ],
    );
  }
}
