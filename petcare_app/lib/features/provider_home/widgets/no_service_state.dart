import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';

// NCC vừa được duyệt nhưng chưa thêm dịch vụ nào
class NoServiceState extends StatelessWidget {
  const NoServiceState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox(height: 32),
        AppEmptyState(
          icon: Icons.add_business_outlined,
          title: l10n.chuaCoDichVu,
          message: l10n.chuaCoDichVuMoTa,
          circleColor: AppColors.cardMint,
        ),
        const SizedBox(height: AppSpacing.groupGap),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AppButton(
            text: l10n.themDichVu,
            icon: Icons.add,
            onTap: () => context.push(AppRoutes.providerServices),
          ),
        ),
      ],
    );
  }
}
