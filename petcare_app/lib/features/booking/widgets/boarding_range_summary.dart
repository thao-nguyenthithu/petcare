import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Tóm tắt khoảng ngày của kỳ trông giữ
class BoardingRangeSummary extends StatelessWidget {
  const BoardingRangeSummary({
    super.key,
    required this.tenNcc,
    required this.nhanDau,
    required this.nhanCuoi,
    required this.soDem,
    this.conChoCaKhoang,
  });

  final String? nhanDau;
  final String? nhanCuoi;
  final String tenNcc;
  final int soDem;
  final bool? conChoCaKhoang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (nhanDau == null || nhanCuoi == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.chuaChonKhoangNgay,
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(l10n.chuaChonKhoangNgayMoTa, style: AppTextStyles.captionSm),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: nhanDau),
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_right_alt,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextSpan(text: nhanCuoi),
                  ],
                ),
                style: AppTextStyles.button.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.soDemNhan('$soDem'),
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(switch (conChoCaKhoang) {
          true => l10n.nccConChoCaKhoang(tenNcc),
          false => l10n.coDemDaKinChoTrongKhoang,
          null => l10n.dangKiemChoTrong,
        }, style: AppTextStyles.captionSm),
      ],
    );
  }
}
