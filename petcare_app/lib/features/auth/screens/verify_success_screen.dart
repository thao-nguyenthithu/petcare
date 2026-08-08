import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/success_badge.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class VerifySuccessScreen extends StatelessWidget {
  const VerifySuccessScreen({super.key});

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
                l10n.xacThucEmailThanhCong,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.taiKhoanSanSang,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 24),
              AppCard(
                nen: AppColors.cardMint,
                vien: false,
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset('assets/icons/paw.svg', width: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.moiDangKyNcc,
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
                text: l10n.dangNhap,
                height: 56,
                onTap: () => context.go(AppRoutes.login),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
