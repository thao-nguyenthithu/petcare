import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_map.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_wallet.dart';
import 'package:petcare_app/features/owner_wallet/widgets/owner_wallet_blocks.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_menu_card.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/bar_chart_ky.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';

// Màn Thanh toán của chủ nuôi: tiền đang bị giữ và chi tiêu trong tháng
class OwnerWalletScreen extends ConsumerWidget {
  const OwnerWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final giu = ref.watch(tienDangTamGiuProvider);
    final thangNay = ref.watch(chiTieuTheoKyProvider('month'));
    if (giu.hasError || thangNay.hasError) {
      return AppScreen(
        header: AppScreenHeader(title: l10n.thanhToan),
        body: AppNetworkError(
          onRetry: () {
            ref.invalidate(tienDangTamGiuProvider);
            ref.invalidate(chiTieuTheoKyProvider('month'));
          },
        ),
      );
    }
    final giuData = giu.value;
    final thangData = thangNay.value;
    if (giuData == null || thangData == null) {
      return AppScreen(
        header: AppScreenHeader(title: l10n.thanhToan),
        body: const AppSkeletonList(soThe: 4, caoThe: 96),
      );
    }
    final ThanhToanChuNuoi tt = thanhToanTuApi(l10n, giuData, thangData.total);
    final thang = chiTieuTuApi(thangData);

    return AppScreen(
      header: AppScreenHeader(title: l10n.thanhToan),
      body: AppRefreshIndicator(
        onRefresh: () async {
          await ref.read(tienDangTamGiuProvider.notifier).taiLai();
          ref.invalidate(chiTieuTheoKyProvider('month'));
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.labelGap,
            AppSpacing.screenPadding,
            AppSpacing.screenEdgeGap,
          ),
          children: [
            OwnerHoldingCard(
              tongTamGiu: tt.tongTamGiu,
              soDon: tt.khoanTamGiu.length,
              chiTieuThangNay: tt.chiTieuThangNay,
              thang: tt.thangHienTai,
              onXemTatCa: () => context.push(AppRoutes.ownerWalletHolding),
            ),
            if (tt.khoanTamGiu.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.stackGap),
              OwnerHoldingBlock(
                khoan: tt.khoanTamGiu,
                onXemTatCa: () => context.push(AppRoutes.ownerWalletHolding),
              ),
            ],
            const SizedBox(height: AppSpacing.stackGap),
            _TheChiTieu(
              tong: tt.chiTieuThangNay,
              chart: BarChartKy(
                bars: thang.bars,
                selected: thang.highlightBar,
                onSelect: (_) => context.push(AppRoutes.ownerSpending),
              ),
              onTap: () => context.push(AppRoutes.ownerSpending),
            ),
            const SizedBox(height: AppSpacing.stackGap),
            _TheMenu(
              icon: Icons.history_rounded,
              nhan: l10n.lichSuGiaoDich,
              phu: l10n.thanhToanVaHoanTien,
              onTap: () => context.push(AppRoutes.ownerTransactions),
            ),
          ],
        ),
      ),
    );
  }
}

class _TheChiTieu extends StatelessWidget {
  const _TheChiTieu({
    required this.tong,
    required this.chart,
    required this.onTap,
  });

  final int tong;
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
                    child: Text(l10n.chiTieuThangNay, style: AppTextStyles.h3),
                  ),
                  Text(
                    '${dinhDangTien(tong)}đ',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
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
              Text(l10n.chamDeXemChiTieu, style: AppTextStyles.captionSm),
              const SizedBox(height: AppSpacing.stackGap),
              chart,
            ],
          ),
        ),
      ),
    );
  }
}

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
