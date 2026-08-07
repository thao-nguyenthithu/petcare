import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

typedef DongTien = ({String nhan, int tien});

// Mục Tạm tính
class BookingPriceSummary extends StatelessWidget {
  const BookingPriceSummary({
    super.key,
    required this.dong,
    required this.ghiChu,
  });

  final List<DongTien> dong;
  final String ghiChu;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.tamTinh, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final d in dong)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: Text(d.nhan, style: AppTextStyles.captionSm)),
                const SizedBox(width: 12),
                Text('${dinhDangTien(d.tien)}đ', style: AppTextStyles.label),
              ],
            ),
          ),
        AppNoteBox(text: ghiChu),
      ],
    );
  }
}
