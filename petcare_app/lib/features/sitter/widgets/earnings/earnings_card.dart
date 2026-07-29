import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_home.dart';
import 'package:petcare_app/features/sitter/widgets/icon_box.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Thu nhập tuần này, thống kê nhanh
class EarningsCard extends StatelessWidget {
  const EarningsCard({super.key, required this.data});

  final MockSitterDashboard data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final change = data.earningsChangePercent;
    final tang = change >= 0;
    final mauChange = tang ? AppColors.primaryColor : AppColors.accent;
    return Material(
      color: AppColors.cardMint,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: () => context.push(AppRoutes.sitterEarnings),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const IconBox(
                    icon: Icons.account_balance_wallet_outlined,
                    size: 44,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                l10n.thuNhapTuanNay,
                                style: AppTextStyles.captionSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (data.weekEarnings > 0) ...[
                              const SizedBox(width: 6),
                              Icon(
                                tang ? Icons.trending_up : Icons.trending_down,
                                size: 14,
                                color: mauChange,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$change%',
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
                          '${dinhDangTien(data.weekEarnings)}đ',
                          style: AppTextStyles.h1.copyWith(fontSize: 26),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Text(
                        l10n.chiTiet,
                        style: AppTextStyles.captionSm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const AppDongKe(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatLine(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.primaryColor,
                      text: l10n.donHoanThanhSo('${data.ordersThisWeek}'),
                    ),
                  ),
                  _StatLine(
                    icon: Icons.access_time,
                    iconColor: AppColors.textSecondary,
                    text: data.workedThisWeek,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Một dòng thống kê nhỏ icon, chữ phụ
class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.captionSm,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
