import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';

// Hai tab: khoản sắp về ví và khoản đang khiếu nại
class SitterHoldingScreen extends ConsumerStatefulWidget {
  const SitterHoldingScreen({super.key});

  @override
  ConsumerState<SitterHoldingScreen> createState() =>
      _SitterHoldingScreenState();
}

class _SitterHoldingScreenState extends ConsumerState<SitterHoldingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = ref.watch(viCuaToiProvider);
    if (trangThai.hasError) {
      return AppScreen(
        backgroundColor: AppColors.background,
        header: AppScreenHeader(title: l10n.tienDangGiuTam),
        body: AppNetworkError(onRetry: () => ref.invalidate(viCuaToiProvider)),
      );
    }
    final api = trangThai.value;
    if (api == null) {
      return AppScreen(
        backgroundColor: AppColors.background,
        header: AppScreenHeader(title: l10n.tienDangGiuTam),
        body: const AppSkeletonList(soThe: 4, caoThe: 92),
      );
    }
    final ViNguoiCham vi = viTuApi(l10n, api);
    final sapVe = vi.sapVeVi;
    final khieuNai = vi.dangKhieuNai;
    final hienThi = _tab == 0 ? sapVe : khieuNai;

    return AppScreen(
      backgroundColor: AppColors.background,
      header: AppScreenHeader(title: l10n.tienDangGiuTam),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.labelGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          _BannerTong(
            tong: vi.tongGiuTam,
            tienSapVe: sapVe.fold(0, (t, k) => t + k.soTien),
            soDonSapVe: sapVe.length,
            tienKhieuNai: khieuNai.fold(0, (t, k) => t + k.soTien),
            soDonKhieuNai: khieuNai.length,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          AppSegmentedTabs(
            labels: [
              l10n.sapVeViSo('${sapVe.length}'),
              l10n.dangKhieuNaiSo('${khieuNai.length}'),
            ],
            selectedIndex: _tab,
            onChanged: (i) => setState(() => _tab = i),
            nhat: true,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          if (hienThi.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.screenEdgeGap),
              child: AppEmptyState(
                icon: Icons.savings_outlined,
                title: l10n.khongCoKhoanGiuTam,
                circleColor: AppColors.cardMint,
              ),
            )
          else
            for (final k in hienThi) ...[
              SitterBookingCard(
                booking: k.don,
                thoiGianGhiDe: l10n.xongLuc(k.motaMoc),
                onTap: () => moChiTietDonNcc(context, k.don),
              ),
              if (k != hienThi.last) const SizedBox(height: AppSpacing.itemGap),
            ],
        ],
      ),
    );
  }
}

class _BannerTong extends StatelessWidget {
  const _BannerTong({
    required this.tong,
    required this.tienSapVe,
    required this.soDonSapVe,
    required this.tienKhieuNai,
    required this.soDonKhieuNai,
  });

  final int tong;
  final int tienSapVe;
  final int soDonSapVe;
  final int tienKhieuNai;
  final int soDonKhieuNai;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.honey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dangGiuTam,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.honey),
          ),
          const SizedBox(height: AppSpacing.textGap),
          Text(
            '${dinhDangTien(tong)}đ',
            style: AppTextStyles.h1.copyWith(color: AppColors.honey),
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Text(
            l10n.moTaGiuTamHaiPhan(
              dinhDangTien(tienSapVe),
              '$soDonSapVe',
              dinhDangTien(tienKhieuNai),
              '$soDonKhieuNai',
            ),
            style: AppTextStyles.captionSm,
          ),
        ],
      ),
    );
  }
}
