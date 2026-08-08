import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Thẻ tổng thu nhập của kỳ đang chọn
class TomTatKyCard extends StatelessWidget {
  const TomTatKyCard({super.key, required this.period});

  final ThongKeKy period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tang = period.changePercent >= 0;
    final mauChange = tang ? AppColors.primaryColor : AppColors.accent;
    return AppCard(
      width: double.infinity,
      nen: AppColors.cardMint,
      vien: false,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        period.rangeLabel,
                        style: AppTextStyles.captionSm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (period.changePercent != 0) ...[
                      const SizedBox(width: 6),
                      Icon(
                        tang ? Icons.trending_up : Icons.trending_down,
                        size: 14,
                        color: mauChange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${period.changePercent}%',
                        style: AppTextStyles.label.copyWith(color: mauChange),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${dinhDangTien(period.total)}đ', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text(
                  '${l10n.soDonHoanThanh(period.ordersDone.toString())} · ${period.hoursWorked}',
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
