import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/grooming_form.dart';
import 'package:petcare_app/features/sitter/data/service_summary.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/widgets/services/grooming_tier_card.dart';

const double _khoangHo = 10;

// Bảng giá 4 mức cân của MỘT gói grooming
class GroomingPriceTable extends StatelessWidget {
  const GroomingPriceTable({
    super.key,
    required this.goi,
    required this.form,
    required this.hienLoi,
    required this.onChanged,
  });

  final GroomingPackage goi;
  final GroomingForm form;

  final bool hienLoi;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(groomingPackageName(context, goi), style: AppTextStyles.label),
            const Spacer(),
            Text(l10n.giaVaThoiLuongMoiBe, style: AppTextStyles.captionSm),
          ],
        ),
        const SizedBox(height: _khoangHo),
        for (final muc in WeightTier.values) ...[
          if (muc != WeightTier.values.first) const SizedBox(height: _khoangHo),
          GroomingTierCard(
            nhan: weightTierLabel(context, muc),
            hintGia: groomingHintGia[muc]!,
            hintPhut: '${groomingPhutGoiY[goi]![muc]}',
            gia: form.gia[goi]![muc]!,
            phut: form.phut[goi]![muc]!,
            oGia: form.oGia[goi]![muc]!,
            oPhut: form.oPhut[goi]![muc]!,
            chon: form.nhanMuc(goi, muc),
            loi: hienLoi ? form.loiMuc(goi, muc) : null,
            onToggle: (bat) {
              form.doiMuc(goi, muc, bat);
              onChanged();
            },
          ),
        ],
        if (hienLoi && form.thieuMuc(goi)) ...[
          const SizedBox(height: 8),
          Text(
            l10n.chonItNhatMotMucCan,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
