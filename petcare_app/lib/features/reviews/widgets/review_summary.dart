import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/review_stars.dart';

const double _dayThanh = 6;

// Khối tổng đầu màn đánh giá, số liệu của toàn bộ chứ không phải trang đang xem
class ReviewSummaryBlock extends StatelessWidget {
  const ReviewSummaryBlock({super.key, required this.thongKe});

  final ThongKeDanhGia thongKe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cao = thongKe.mucCaoNhat;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              thongKe.diemTrungBinh.toStringAsFixed(1).replaceAll('.', ','),
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: AppSpacing.textGap),
            ReviewStars(so: thongKe.diemTrungBinh.round()),
            const SizedBox(height: AppSpacing.textGap),
            Text(
              l10n.soDanhGia('${thongKe.tongSo}'),
              style: AppTextStyles.captionSm,
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.blockGap),
        Expanded(
          child: Column(
            children: [
              for (var sao = 5; sao >= 1; sao--) ...[
                if (sao != 5) const SizedBox(height: AppSpacing.textGap),
                Row(
                  children: [
                    Text('$sao', style: AppTextStyles.captionSm),
                    const SizedBox(width: AppSpacing.labelGap),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: cao == 0
                              ? 0
                              : (thongKe.phanBoSao[sao] ?? 0) / cao,
                          minHeight: _dayThanh,
                          backgroundColor: AppColors.neutralLight,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
