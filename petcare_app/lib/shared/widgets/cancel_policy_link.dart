import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Liên kết tới trang chính sách huỷ
class CancelPolicyLink extends StatelessWidget {
  const CancelPolicyLink({super.key, this.nhan, this.duongDan});
  final String? nhan;
  final String? duongDan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(duongDan ?? AppRoutes.cancelPolicy),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 17,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 10),
            Text(
              nhan ?? context.l10n.chinhSachHuy,
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
