import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/success_badge.dart';

class ProfileSubmittedScreen extends StatelessWidget {
  const ProfileSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              const Center(child: SuccessBadge()),
              const SizedBox(height: 32),
              Text(
                l10n.daGuiHoSo,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.hoSoDangXemXet,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardMint,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/icons/paw.svg', width: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.trongLucChoDungChuNuoi,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              AppButton(
                text: l10n.veTrangChu,
                height: 56,
                onTap: () {
                  // TODO (router): về trang chủ Owner khi có màn Home
                  context.go(AppRoutes.login);
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO (router): màn trạng thái hồ sơ sẽ làm sau
                  },
                  child: Text(
                    l10n.xemTrangThaiHoSo,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
