import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/sitter_profile.dart';

// Ba cột số liệu điểm đánh giá, lượt đánh giá, đơn hoàn thành
class SitterProfileStats extends StatelessWidget {
  const SitterProfileStats({super.key, required this.view});

  final SitterProfile view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Cot(so: view.ratingAvg.toStringAsFixed(1), nhan: l10n.diemDanhGia),
        const _Vach(),
        _Cot(so: '${view.totalReviews}', nhan: l10n.luotDanhGia),
        const _Vach(),
        _Cot(so: '${view.completedOrders}', nhan: l10n.donHoanThanh),
      ],
    );
  }
}

class _Cot extends StatelessWidget {
  const _Cot({required this.so, required this.nhan});

  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(so, style: AppTextStyles.h3),
          const SizedBox(height: 3),
          Text(
            nhan,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Vach extends StatelessWidget {
  const _Vach();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: AppColors.neutralLight);
}
