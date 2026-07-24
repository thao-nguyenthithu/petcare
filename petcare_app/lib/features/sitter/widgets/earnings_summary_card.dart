import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_earnings.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

// Thẻ tổng thu nhập của kỳ đang chọn
class EarningsSummaryCard extends StatelessWidget {
  const EarningsSummaryCard({super.key, required this.period});

  final EarningsPeriod period;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tang = period.changePercent >= 0;
    final mauChange = tang ? AppColors.primaryColor : AppColors.accent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
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
                        style: AppTextStyles.captionSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: mauChange,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${dinhDangTien(period.total)}đ',
                  style: AppTextStyles.h1.copyWith(fontSize: 26),
                ),
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
