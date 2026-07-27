import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';

// Trạng thái lỗi mạng dùng chung
class AppNetworkError extends StatelessWidget {
  const AppNetworkError({super.key, required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: AppEmptyState(
        icon: Icons.wifi_off_rounded,
        title: l10n.khongTaiDuocDuLieu,
        message: message ?? l10n.loiMangMoTa,
        circleColor: AppColors.accent.withValues(alpha: 0.12),
        iconColor: AppColors.accent,
        action: SizedBox(
          width: 160,
          child: AppButton(
            text: l10n.thuLai,
            icon: Icons.refresh_rounded,
            onTap: onRetry,
          ),
        ),
      ),
    );
  }
}
