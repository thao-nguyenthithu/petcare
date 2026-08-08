import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/icon_text_row.dart';

// Mục An toàn theo quy định, chỉ hiện ở đơn dắt chó
class BookingSafetyRules extends StatelessWidget {
  const BookingSafetyRules({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.anToanTheoQuyDinh, style: AppTextStyles.h3),
        const SizedBox(height: 10),
        Text(l10n.moTaAnToanDatCho, style: AppTextStyles.captionSm),
        const SizedBox(height: 16),
        IconTextRow(
          icon: Icons.check_circle_outline,
          chu: l10n.roMom,
          moTa: l10n.moTaRoMom,
        ),
        const SizedBox(height: 14),
        IconTextRow(
          icon: Icons.check_circle_outline,
          chu: l10n.dayXich,
          moTa: l10n.moTaDayXich,
        ),
      ],
    );
  }
}
