import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_map.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Tách hai tab: đơn chưa xong và đơn đang khiếu nại
class OwnerHoldingScreen extends ConsumerStatefulWidget {
  const OwnerHoldingScreen({super.key});

  @override
  ConsumerState<OwnerHoldingScreen> createState() => _OwnerHoldingScreenState();
}

class _OwnerHoldingScreenState extends ConsumerState<OwnerHoldingScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = ref.watch(tienDangTamGiuProvider);
    if (trangThai.hasError) {
      return AppScreen(
        backgroundColor: AppColors.background,
        header: AppScreenHeader(title: l10n.tienDangTamGiu),
        body: AppNetworkError(
          onRetry: () => ref.invalidate(tienDangTamGiuProvider),
        ),
      );
    }
    final api = trangThai.value;
    if (api == null) {
      return AppScreen(
        backgroundColor: AppColors.background,
        header: AppScreenHeader(title: l10n.tienDangTamGiu),
        body: const AppSkeletonList(soThe: 4, caoThe: 92),
      );
    }
    final tt = thanhToanTuApi(l10n, api, 0);
    final dangGiu = tt.dangGiu;
    final khieuNai = tt.dangKhieuNai;
    final hienThi = _tab == 0 ? dangGiu : khieuNai;

    return AppScreen(
      header: AppScreenHeader(title: l10n.tienDangTamGiu),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.labelGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          _BannerTong(
            tong: tt.tongTamGiu,
            gioGiuTien: ref.watch(cauHinhNghiepVuProvider).gioGiuTien,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          AppSegmentedTabs(
            labels: [
              l10n.dangGiuSo('${dangGiu.length}'),
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
                icon: Icons.lock_outline_rounded,
                title: l10n.khongCoKhoanTamGiu,
                circleColor: AppColors.cardMint,
              ),
            )
          else
            for (final k in hienThi) ...[
              SitterBookingCard(
                booking: k.don,
                tienGhiDe: '${dinhDangTien(k.soTien)}đ',
                mauTienGhiDe: AppColors.accent,
                ghiChuGhiDe: k.dangKhieuNai ? l10n.banDangKhieuNai : null,
                onTap: () =>
                    context.push(AppRoutes.bookingDetail, extra: k.don.id),
              ),
              if (k != hienThi.last) const SizedBox(height: AppSpacing.itemGap),
            ],
        ],
      ),
    );
  }
}

class _BannerTong extends StatelessWidget {
  const _BannerTong({required this.tong, required this.gioGiuTien});

  final int tong;
  final int gioGiuTien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      width: double.infinity,
      nen: AppColors.cardMint,
      vien: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dangTamGiu,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: AppSpacing.textGap),
          Text(
            '${dinhDangTien(tong)}đ',
            style: AppTextStyles.h1.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Text(
            l10n.moTaTamGiuChuNuoi('$gioGiuTien'),
            style: AppTextStyles.captionSm,
          ),
        ],
      ),
    );
  }
}
