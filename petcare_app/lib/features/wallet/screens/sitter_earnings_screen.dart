import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet_api.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/features/wallet/widgets/transaction_card.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';
import 'package:petcare_app/shared/widgets/bar_chart_ky.dart';
import 'package:petcare_app/shared/widgets/tom_tat_ky_card.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';

// Mã kỳ gửi lên server, đúng thứ tự tab
const _maKy = ['week', 'month', 'year'];

class SitterEarningsScreen extends ConsumerStatefulWidget {
  const SitterEarningsScreen({super.key});

  @override
  ConsumerState<SitterEarningsScreen> createState() =>
      _SitterEarningsScreenState();
}

class _SitterEarningsScreenState extends ConsumerState<SitterEarningsScreen> {
  int _tab = 0;
  int? _selectedBar;

  void _doiTab(int i) {
    setState(() {
      _tab = i;
      _selectedBar = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = ref.watch(thuNhapTheoKyProvider(_maKy[_tab]));
    if (trangThai.hasError) {
      return AppScreen(
        backgroundColor: AppColors.background,
        header: AppScreenHeader(title: l10n.thuNhap),
        body: AppNetworkError(
          onRetry: () => ref.invalidate(thuNhapTheoKyProvider(_maKy[_tab])),
        ),
      );
    }
    final ThuNhapApi? api = trangThai.value;
    if (api == null) {
      return AppScreen(
        backgroundColor: AppColors.background,
        header: AppScreenHeader(title: l10n.thuNhap),
        body: const AppSkeletonList(soThe: 3, caoThe: 120),
      );
    }
    final period = thuNhapTuApi(l10n, api);
    final chiSoCot = _selectedBar ?? period.highlightBar;
    final selBar = period.bars.isEmpty
        ? const ThongKeCot(label: '', amount: 0, upcoming: true)
        : period.bars[chiSoCot.clamp(0, period.bars.length - 1)];
    final recent = api.transactions;
    final conNua = recent.length >= 5;
    return AppScreen(
      backgroundColor: AppColors.background,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.thuNhap),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.blockGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          AppSegmentedTabs(
            labels: [l10n.donViTuan, l10n.donViThang, l10n.donViNam],
            selectedIndex: _tab,
            onChanged: _doiTab,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          TomTatKyCard(period: period),
          const SizedBox(height: AppSpacing.groupGap),
          Row(
            children: [
              Text(period.chartTitle, style: AppTextStyles.h3),
              const Spacer(),
              if (!selBar.upcoming)
                Text(
                  '${selBar.label} · ${dinhDangTien(selBar.amount)}đ',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          BarChartKy(
            bars: period.bars,
            selected: chiSoCot,
            onSelect: (i) => setState(() => _selectedBar = i),
          ),
          const SizedBox(height: AppSpacing.groupGap),
          Row(
            children: [
              Text(l10n.giaoDichGanDay, style: AppTextStyles.h3),
              const Spacer(),
              if (conNua)
                InkWell(
                  onTap: () => context.push(AppRoutes.sitterTransactions),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.xemTatCa,
                        style: AppTextStyles.label.copyWith(
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
          for (final gd in recent) ...[
            TransactionCard(
              giaoDich: giaoDichGanDayThanhGiaoDich(l10n, gd),
              onTap: () => context.push(AppRoutes.sitterTransactionPath(gd.ma)),
            ),
            if (gd != recent.last) const SizedBox(height: AppSpacing.itemGap),
          ],
        ],
      ),
    );
  }
}
