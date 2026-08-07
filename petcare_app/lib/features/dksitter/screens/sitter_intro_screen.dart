import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Bước 0 đăng ký NCC giới thiệu
class ProviderIntroScreen extends StatelessWidget {
  const ProviderIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingWide,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.itemGap),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                const SizedBox(height: AppSpacing.blockGap),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      color: AppColors.cardMint,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/paw.svg',
                        width: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.blockGap),
                Text(
                  l10n.troThanhNcc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: AppSpacing.titleGap),
                Text(
                  l10n.gioiThieuNcc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                Text(l10n.quyTrinhDangKy, style: AppTextStyles.label),
                const SizedBox(height: AppSpacing.titleGap),
                _Buoc(
                  so: '1',
                  title: l10n.thongTinCaNhan,
                  desc: l10n.buocThongTinMoTa,
                ),
                _Buoc(
                  so: '2',
                  title: l10n.buocXacMinhCccd,
                  desc: l10n.buocXacMinhMoTa,
                ),
                _Buoc(
                  so: '3',
                  title: l10n.buocCamKetGuiHoSo,
                  desc: l10n.buocCamKetMoTa,
                  cuoiCung: true,
                ),
                const SizedBox(height: AppSpacing.labelGap),
                Text(l10n.khaiDichVuSauDuyet, style: AppTextStyles.captionSm),
                const SizedBox(height: AppSpacing.blockGap),
                AppCard(
                  nen: AppColors.cardMint,
                  vien: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.canChuanBi, style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.labelGap),
                      Text(
                        l10n.canChuanBiCccd,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.groupGap),
                AppButton(
                  text: l10n.batDauDangKy,
                  height: 56,
                  onTap: () => context.push(AppRoutes.sitterPersonalInfo),
                ),
                const SizedBox(height: AppSpacing.itemGap),
                Text(
                  l10n.hoSoDuyet24h,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSm,
                ),
                const SizedBox(height: AppSpacing.groupGap),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Buoc extends StatelessWidget {
  final String so;
  final String title;
  final String desc;
  final bool cuoiCung;

  const _Buoc({
    required this.so,
    required this.title,
    required this.desc,
    this.cuoiCung = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    so,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              ),
              if (!cuoiCung)
                Expanded(child: Container(width: 2, color: AppColors.neutral)),
            ],
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: cuoiCung ? 0 : AppSpacing.stackGap,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(desc, style: AppTextStyles.captionSm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
