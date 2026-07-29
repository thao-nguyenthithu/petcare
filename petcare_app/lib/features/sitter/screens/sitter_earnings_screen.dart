import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_earnings.dart';
import 'package:petcare_app/features/sitter/widgets/earnings/earnings_bar_chart.dart';
import 'package:petcare_app/features/sitter/widgets/earnings/earnings_summary_card.dart';
import 'package:petcare_app/features/sitter/widgets/earnings/earnings_transaction_row.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Màn Thu nhập NCC
class SitterEarningsScreen extends StatefulWidget {
  const SitterEarningsScreen({super.key});

  @override
  State<SitterEarningsScreen> createState() => _SitterEarningsScreenState();
}

class _SitterEarningsScreenState extends State<SitterEarningsScreen> {
  int _tab = 0; // mặc định Tuần
  late int _selectedBar = MockSitterEarningsData.periods[_tab].highlightBar;

  void _doiTab(int i) {
    setState(() {
      _tab = i;
      _selectedBar = MockSitterEarningsData.periods[i].highlightBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final period = MockSitterEarningsData.periods[_tab];
    final selBar = period.bars[_selectedBar];
    // Xem trước 5 giao dịch gần nhất
    const gioiHanXemTruoc = 5;
    final recent = period.transactions.take(gioiHanXemTruoc).toList();
    final conNua = period.transactions.length > gioiHanXemTruoc;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenHeader(title: l10n.thuNhap),
            const AppDongKe(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.blockGap,
                  AppSpacing.screenPadding,
                  AppSpacing.screenEdgeGap,
                ),
                children: [
                  AppSegmentedTabs(
                    labels: MockSitterEarningsData.tabs,
                    selectedIndex: _tab,
                    onChanged: _doiTab,
                  ),
                  const SizedBox(height: AppSpacing.stackGap),
                  EarningsSummaryCard(period: period),
                  const SizedBox(height: AppSpacing.groupGap),
                  Row(
                    children: [
                      Text(period.chartTitle, style: AppTextStyles.h3),
                      const Spacer(),
                      if (!selBar.upcoming)
                        Text(
                          '${selBar.label} · ${dinhDangTien(selBar.amount)}đ',
                          style: AppTextStyles.label.copyWith(
                            fontSize: 14,
                            color: AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackGap),
                  EarningsBarChart(
                    bars: period.bars,
                    selected: _selectedBar,
                    onSelect: (i) => setState(() => _selectedBar = i),
                  ),
                  const SizedBox(height: AppSpacing.groupGap),
                  Row(
                    children: [
                      Text(l10n.giaoDichGanDay, style: AppTextStyles.h3),
                      const Spacer(),
                      if (conNua)
                        InkWell(
                          // TODO: → AppRoutes.sitterEarningsHistory khi có màn.
                          onTap: () => baoDangPhatTrien(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.xemTatCa,
                                style: AppTextStyles.captionSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                size: 16,
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.itemGap),
                  for (final tx in recent) ...[
                    EarningsTransactionRow(
                      tx: tx,
                      onTap: () => baoDangPhatTrien(context),
                    ),
                    if (tx != recent.last) const AppDongKe(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
