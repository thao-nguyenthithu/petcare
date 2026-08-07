import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_map.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/features/owner_wallet/widgets/owner_wallet_blocks.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';
import 'package:petcare_app/shared/widgets/bar_chart_ky.dart';
import 'package:petcare_app/shared/widgets/tom_tat_ky_card.dart';

const List<String> _maKy = ['week', 'month', 'year'];

class OwnerSpendingScreen extends ConsumerStatefulWidget {
  const OwnerSpendingScreen({super.key});

  @override
  ConsumerState<OwnerSpendingScreen> createState() =>
      _OwnerSpendingScreenState();
}

class _OwnerSpendingScreenState extends ConsumerState<OwnerSpendingScreen> {
  int _tab = 0;

  int? _cotChon;

  void _doiTab(int i) => setState(() {
    _tab = i;
    _cotChon = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = ref.watch(chiTieuTheoKyProvider(_maKy[_tab]));
    final lichSu = ref.watch(lichSuThanhToanProvider(null));
    if (trangThai.hasError) {
      return AppScreen(
        header: AppScreenHeader(title: l10n.chiTieu),
        body: AppNetworkError(
          onRetry: () => ref.invalidate(chiTieuTheoKyProvider(_maKy[_tab])),
        ),
      );
    }
    final api = trangThai.value;
    if (api == null) {
      return AppScreen(
        header: AppScreenHeader(title: l10n.chiTieu),
        body: const AppSkeletonList(soThe: 3, caoThe: 120),
      );
    }
    final ky = chiTieuTuApi(api);
    final chiSoCot = _cotChon ?? ky.highlightBar;
    final cot = ky.bars.isEmpty
        ? const ThongKeCot(label: '', amount: 0, upcoming: true)
        : ky.bars[chiSoCot.clamp(0, ky.bars.length - 1)];
    const gioiHanXemTruoc = 4;
    final tatCa = [
      for (final g in lichSu.value ?? const []) giaoDichChuNuoiTuApi(l10n, g),
    ]..sort((a, b) => b.thoiDiem.compareTo(a.thoiDiem));
    final ganDay = tatCa.take(gioiHanXemTruoc).toList();

    return AppScreen(
      header: Column(
        children: [
          AppScreenHeader(title: l10n.chiTieu),
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
          TomTatKyCard(period: ky),
          const SizedBox(height: AppSpacing.groupGap),
          Row(
            children: [
              Text(ky.chartTitle, style: AppTextStyles.h3),
              const Spacer(),
              if (!cot.upcoming)
                Text(
                  '${cot.label} · ${dinhDangTien(cot.amount)}đ',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          BarChartKy(
            bars: ky.bars,
            selected: chiSoCot,
            onSelect: (i) => setState(() => _cotChon = i),
          ),
          const SizedBox(height: AppSpacing.groupGap),
          OwnerSpendByService(dong: chiTieuTheoDichVuTuApi(api)),
          const SizedBox(height: AppSpacing.groupGap),
          Row(
            children: [
              Text(l10n.giaoDichGanDay, style: AppTextStyles.h3),
              const Spacer(),
              InkWell(
                onTap: () => context.push(AppRoutes.ownerTransactions),
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
          for (final g in ganDay) ...[
            OwnerTransactionCard(
              giaoDich: g,
              onTap: () => context.push(AppRoutes.ownerTransactionPath(g.ma)),
            ),
            if (g != ganDay.last) const SizedBox(height: AppSpacing.itemGap),
          ],
        ],
      ),
    );
  }
}
