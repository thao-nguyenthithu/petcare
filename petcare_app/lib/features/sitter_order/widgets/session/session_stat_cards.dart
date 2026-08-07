import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Một thẻ số liệu của màn tác nghiệp
typedef TheSoLieu = ({
  IconData icon,
  String so,
  String nhan,
  bool noiBat,
  bool canhBao,
});

class SessionStatCards extends StatelessWidget {
  const SessionStatCards({super.key, required this.the});

  final List<TheSoLieu> the;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, t) in the.indexed) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(child: _The(the: t)),
        ],
      ],
    );
  }
}

class _The extends StatelessWidget {
  const _The({required this.the});

  final TheSoLieu the;

  @override
  Widget build(BuildContext context) {
    final mau = the.canhBao ? AppColors.accent : AppColors.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: the.noiBat
            ? (the.canhBao ? mau.withValues(alpha: 0.12) : AppColors.cardMint)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(
          color: the.noiBat ? Colors.transparent : AppColors.neutralLight,
        ),
      ),
      child: Column(
        children: [
          Icon(
            the.icon,
            size: 20,
            color: the.noiBat ? mau : AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            the.so,
            style: AppTextStyles.h3.copyWith(
              color: the.noiBat ? mau : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            the.nhan,
            style: AppTextStyles.captionSm.copyWith(
              color: the.noiBat ? mau : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
