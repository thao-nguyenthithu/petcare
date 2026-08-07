import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet_error.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/features/wallet/widgets/bank_account_sheet.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';

class SitterBankAccountScreen extends ConsumerWidget {
  const SitterBankAccountScreen({super.key});

  // Mở form nhập rồi lưu
  Future<void> _nhap(
    BuildContext context,
    WidgetRef ref,
    TaiKhoanNganHang? dangCo,
  ) async {
    final l10n = context.l10n;
    final ketQua = await showBankAccountSheet(context, dangCo: dangCo);
    if (ketQua == null || !context.mounted) return;
    try {
      await ref
          .read(taiKhoanNhanTienProvider.notifier)
          .luu(
            tenNganHang: ketQua.tenNganHang,
            soTaiKhoan: ketQua.soTaiKhoan,
            tenChuTaiKhoan: ketQua.tenChuTaiKhoan,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.daLuuTaiKhoanNhanTien)));
    } catch (loi) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            moTaLoiVi(
              context,
              loi,
              rutToiThieu: ref.read(cauHinhNghiepVuProvider).rutToiThieu,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(taiKhoanNhanTienProvider);
    if (trangThai.hasError) {
      return AppScreen(
        header: AppScreenHeader(title: l10n.taiKhoanNhanTien),
        body: AppNetworkError(
          onRetry: () => ref.invalidate(taiKhoanNhanTienProvider),
        ),
      );
    }
    if (trangThai.isLoading && !trangThai.hasValue) {
      return AppScreen(
        header: AppScreenHeader(title: l10n.taiKhoanNhanTien),
        body: const AppSkeletonList(soThe: 2, caoThe: 110),
      );
    }
    final TaiKhoanNganHang? taiKhoan = taiKhoanTuApi(trangThai.value);

    return AppScreen(
      header: AppScreenHeader(title: l10n.taiKhoanNhanTien),
      body: taiKhoan == null
          ? _ChuaLienKet(onLienKet: () => _nhap(context, ref, null))
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.labelGap,
                AppSpacing.screenPadding,
                AppSpacing.screenEdgeGap,
              ),
              children: [
                ViCard(
                  child: Column(
                    children: [
                      BankAccountCard(
                        taiKhoan: taiKhoan,
                        duoi: taiKhoan.daXacThuc
                            ? const _NhanDaXacThuc()
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.cardPadding),
                      const AppDongKe(),
                      const SizedBox(height: AppSpacing.cardPadding),
                      // Đổi tài khoản là lưu đè, không có lối gỡ bỏ
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => _nhap(context, ref, taiKhoan),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.cardMint,
                            foregroundColor: AppColors.primaryColor,
                          ),
                          child: Text(l10n.doiTaiKhoan),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NhanDaXacThuc extends StatelessWidget {
  const _NhanDaXacThuc();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        context.l10n.daXacThuc,
        style: AppTextStyles.captionSm.copyWith(color: AppColors.primaryColor),
      ),
    );
  }
}

// Chưa liên kết: khối rỗng và một nút duy nhất
class _ChuaLienKet extends StatelessWidget {
  const _ChuaLienKet({required this.onLienKet});

  final VoidCallback onLienKet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppEmptyState(
            icon: Icons.credit_card_off_outlined,
            title: l10n.chuaLienKetTaiKhoan,
            message: l10n.moTaChuaLienKet,
            circleColor: AppColors.neutralLight,
            iconColor: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.blockGap),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onLienKet,
              child: Text(l10n.lienKetTaiKhoanNganHang),
            ),
          ),
          const SizedBox(height: 84),
        ],
      ),
    );
  }
}
