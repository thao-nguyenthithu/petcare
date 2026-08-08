import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/vai_tro.dart';
import 'package:petcare_app/features/address/widgets/location_permission_sheet.dart';
import 'package:petcare_app/features/dksitter/providers/dksitter_provider.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

// Banner Kết nối với người chăm sóc
class VerifiedBanner extends StatelessWidget {
  const VerifiedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: AppColors.cardMint,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.nguoiChamDaXacMinh, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.search),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.timNgay,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            child: SvgPicture.asset(
              'assets/illustrations/banner_verified_care.svg',
              width: 150,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// Banner mời thêm địa chỉ
class AddAddressBanner extends StatelessWidget {
  const AddAddressBanner({super.key});
  Future<void> _dungViTriHienTai(BuildContext context) async {
    await moSheetQuyenViTri(context);
    if (!context.mounted) return;
    context.push(AppRoutes.addAddress);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: AppColors.cardMint,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.themDiaChiDeTimNguoiCham, style: AppTextStyles.h3),
                const SizedBox(height: 20),
                Row(
                  children: [
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.addAddress),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      child: Text(l10n.themDiaChi),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextButton(
                        onPressed: () => _dungViTriHienTai(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          textStyle: AppTextStyles.label,
                        ),
                        child: Text(l10n.dungViTriHienTai),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SvgPicture.asset('assets/icons/icon_location.svg', height: 65),
        ],
      ),
    );
  }
}

// Banner mời trở thành người cung cấp dịch vụ
class BecomeProviderBanner extends ConsumerWidget {
  const BecomeProviderBanner({super.key});
  Future<void> _moDangKyNcc(BuildContext context, WidgetRef ref) async {
    String? trangThai;
    try {
      trangThai = await showAppLoading(
        context,
        () => ref.read(sitterStatusProvider.future),
      );
    } catch (_) {}
    if (!context.mounted) return;
    context.push(
      trangThai == TrangThaiHoSoNcc.choDuyet
          ? AppRoutes.sitterSubmitted
          : AppRoutes.sitterIntro,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(sitterStatusProvider).asData?.value;
    if (trangThai == TrangThaiHoSoNcc.daDuyet) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: AppColors.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.troThanhNguoiCungCap,
            style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.xacMinhDeNhanDon,
            style: AppTextStyles.body.copyWith(color: AppColors.textWhite),
          ),
          const SizedBox(height: 12),
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => _moDangKyNcc(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.dangKyLamNcc,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.textWhite,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
