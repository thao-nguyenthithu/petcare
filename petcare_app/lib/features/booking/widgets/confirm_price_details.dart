import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

typedef DongGiaChiTiet = ({String nhan, String? phu, int? tien, String? chu});

class ConfirmPriceDetails extends StatelessWidget {
  const ConfirmPriceDetails({
    super.key,
    required this.dong,
    required this.tong,
    this.ghiChu,
  });

  final List<DongGiaChiTiet> dong;
  final int tong;
  final String? ghiChu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.chiTietGia, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final d in dong)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nhan, style: AppTextStyles.captionSm),
                      if (d.phu != null) ...[
                        const SizedBox(height: 2),
                        Text(d.phu!, style: AppTextStyles.captionSm),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  d.tien != null ? '${dinhDangTien(d.tien!)}đ' : (d.chu ?? ''),
                  style: AppTextStyles.label.copyWith(
                    color: d.tien != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        if (ghiChu case final ghi?)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(ghi, style: AppTextStyles.captionSm),
          ),
        Row(
          children: [
            Expanded(child: Text(l10n.tongThanhToan, style: AppTextStyles.h3)),
            const SizedBox(width: 12),
            Text('${dinhDangTien(tong)}đ', style: AppTextStyles.h2),
          ],
        ),
      ],
    );
  }
}
