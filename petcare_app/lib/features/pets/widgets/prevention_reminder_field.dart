import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/features/pets/widgets/prevention_due_preview.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';

// Khối khai mốc nhắc cho một hạng mục
class PreventionReminderField extends StatelessWidget {
  const PreventionReminderField({
    super.key,
    required this.coNhacLai,
    required this.soChuKyController,
    required this.donVi,
    required this.chuKy,
    required this.ngayToiHan,
    required this.onDoiCheDo,
    required this.onDoiDonVi,
    required this.onDoiSo,
  });

  final bool coNhacLai;
  final TextEditingController soChuKyController;
  final CycleUnit donVi;
  final PreventionCycle? chuKy;
  final DateTime? ngayToiHan;
  final ValueChanged<bool> onDoiCheDo;
  final ValueChanged<CycleUnit> onDoiDonVi;
  final VoidCallback onDoiSo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.nhacLaiLanKeTiep, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.labelGap),
        AppSegmentedTabs(
          nhat: true,
          labels: [l10n.coNhacLai, l10n.khongNhacLai],
          selectedIndex: coNhacLai ? 0 : 1,
          onChanged: (i) => onDoiCheDo(i == 0),
        ),
        // Chọn nhắc lại thì
        if (coNhacLai) ...[
          const SizedBox(height: AppSpacing.itemGap),
          Text(l10n.sauChuKy, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.labelGap),
          _ONhapChuKy(
            controller: soChuKyController,
            donVi: donVi,
            onDoiDonVi: onDoiDonVi,
            onDoiSo: onDoiSo,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          PreventionDuePreview(ngayToiHan: ngayToiHan),
          if (chuKy case final ky?) ...[
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              l10n.moTaNgayToiHanTinh(preventionCycleLabel(context, ky)),
              style: AppTextStyles.captionSm,
            ),
          ],
        ],
      ],
    );
  }
}

// Ô khai mốc nhắc lại
class _ONhapChuKy extends StatelessWidget {
  const _ONhapChuKy({
    required this.controller,
    required this.donVi,
    required this.onDoiDonVi,
    required this.onDoiSo,
  });

  final TextEditingController controller;
  final CycleUnit donVi;
  final ValueChanged<CycleUnit> onDoiDonVi;
  final VoidCallback onDoiSo;
  static const double _rongONhapSo = 80;
  static const int _soChuSoToiDa = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        SizedBox(
          width: _rongONhapSo,
          child: AppTextField(
            label: '',
            hint: l10n.hintSoChuKy,
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_soChuSoToiDa),
            ],
            onChanged: (_) => onDoiSo(),
            height: AppTextField.caoGon,
          ),
        ),
        const SizedBox(width: AppSpacing.itemGap),
        Expanded(
          child: AppSegmentedTabs(
            nhat: true,
            labels: [
              for (final muc in CycleUnit.values) cycleUnitLabel(context, muc),
            ],
            selectedIndex: CycleUnit.values.indexOf(donVi),
            onChanged: (i) => onDoiDonVi(CycleUnit.values[i]),
          ),
        ),
      ],
    );
  }
}
