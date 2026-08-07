import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';

class SitterProfileStats extends StatelessWidget {
  const SitterProfileStats({super.key, required this.view});

  final SitterProfile view;
  static String _phanTram(int? so) => so == null ? '—' : '$so%';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Cot(so: _phanTram(view.acceptRate), nhan: l10n.tyLeNhanDon),
        const _Vach(),
        _Cot(so: _phanTram(view.lateCancelRate), nhan: l10n.tyLeHuyMuon),
        const _Vach(),
        _Cot(so: '${view.completedOrders}', nhan: l10n.donHoanThanh),
      ],
    );
  }
}

class _Cot extends StatelessWidget {
  const _Cot({required this.so, required this.nhan});

  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(so, style: AppTextStyles.h3),
          const SizedBox(height: 3),
          Text(
            nhan,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Vach extends StatelessWidget {
  const _Vach();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: AppColors.neutralLight);
}
