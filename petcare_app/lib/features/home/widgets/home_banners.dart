import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

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
                    onTap: () => baoDangPhatTrien(context),
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
                      onPressed: () => baoDangPhatTrien(context),
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
                        onPressed: () => baoDangPhatTrien(context),
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
class BecomeProviderBanner extends StatelessWidget {
  const BecomeProviderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              onTap: () => context.push(AppRoutes.providerServices),
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
