import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/shared/widgets/bar_chart_ky.dart';
import 'package:petcare_app/features/wallet/widgets/wallet_balance_card.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';
import 'package:petcare_app/features/wallet/widgets/wallet_holding_block.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_menu_card.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';

class SitterWalletScreen extends ConsumerWidget {
  const SitterWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(viCuaToiProvider);
    return AppScreen(
      backgroundColor: AppColors.background,
      header: AppScreenHeader(title: l10n.viVaThuNhap),
      body: trangThai.when(
        loading: () => const AppSkeletonList(soThe: 4, caoThe: 96),
        error: (_, _) =>
            AppNetworkError(onRetry: () => ref.invalidate(viCuaToiProvider)),
        data: (api) => _NoiDung(vi: viTuApi(l10n, api)),
      ),
    );
  }
}

class _NoiDung extends ConsumerWidget {
  const _NoiDung({required this.vi});

  final ViNguoiCham vi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppRefreshIndicator(
      onRefresh: () => ref.read(viCuaToiProvider.notifier).taiLai(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.labelGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          WalletBalanceCard(
            soDu: vi.soDuKhaDung,
            daNhanTrongThang: vi.daNhanTrongThang,
            thang: vi.thangHienTai,
            // Chưa liên kết ngân hàng thì không rút được
            onRutTien: vi.nganHang == null
                ? null
                : () => context.push(AppRoutes.sitterWithdraw),
          ),
          if (vi.khoanGiuTam.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.stackGap),
            WalletHoldingBlock(
              khoan: vi.khoanGiuTam,
              onXemTatCa: () => context.push(AppRoutes.sitterWalletHolding),
            ),
          ],
          const SizedBox(height: AppSpacing.stackGap),
          _TheThuNhapTuan(
            tongTuan: vi.thuNhapTuanNay,
            chart: BarChartKy(
              bars: cotTuanTuVi(l10n, vi),
              selected: vi.chiSoHomNay,
              onSelect: (_) => context.push(AppRoutes.sitterEarnings),
            ),
            onTap: () => context.push(AppRoutes.sitterEarnings),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _TheMenu(
            icon: Icons.history_rounded,
            nhan: l10n.lichSuGiaoDich,
            phu: l10n.moiBienDongSoDuVi,
            onTap: () => context.push(AppRoutes.sitterTransactions),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _TheMenu(
            icon: Icons.credit_card,
            nhan: l10n.taiKhoanNhanTien,
            phu: vi.nganHang == null
                ? l10n.chuaLienKetTaiKhoan
                : '${vi.nganHang!.nhan} · ${l10n.daXacThuc}',
            onTap: () => context.push(AppRoutes.sitterBankAccount),
          ),
        ],
      ),
    );
  }
}

// Thẻ thu nhập tuần, biểu đồ dùng lại của màn Thu nhập
class _TheThuNhapTuan extends StatelessWidget {
  const _TheThuNhapTuan({
    required this.tongTuan,
    required this.chart,
    required this.onTap,
  });

  final int tongTuan;
  final Widget chart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: ViCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.thuNhapTuanNay, style: AppTextStyles.h3),
                  ),
                  Text(
                    '+${dinhDangTien(tongTuan)}đ',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.textGap),
              Text(l10n.chamDeXemThongKe, style: AppTextStyles.captionSm),
              const SizedBox(height: AppSpacing.stackGap),
              chart,
            ],
          ),
        ),
      ),
    );
  }
}

// Thẻ menu một dòng, dùng lại dòng menu chung
class _TheMenu extends StatelessWidget {
  const _TheMenu({
    required this.icon,
    required this.nhan,
    required this.phu,
    required this.onTap,
  });

  final IconData icon;
  final String nhan;
  final String phu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(color: AppColors.neutralLight),
        ),
        child: AppMenuTile(
          icon: icon,
          label: nhan,
          subtitle: phu,
          onTap: onTap,
        ),
      ),
    );
  }
}
