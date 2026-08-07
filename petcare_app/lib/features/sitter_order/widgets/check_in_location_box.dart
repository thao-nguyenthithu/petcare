import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Khối xác thực vị trí, dùng chung cho dắt và grooming
class CheckInLocationBox extends StatelessWidget {
  const CheckInLocationBox({
    super.key,
    required this.met,
    required this.gio,
    required this.duGan,
    required this.tieuDeGan,
    required this.tieuDeXa,
  });

  final int met;
  final String gio;
  final bool duGan;

  final String tieuDeGan;
  final String tieuDeXa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mau = duGan ? AppColors.primaryColor : AppColors.accent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mau.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 18, color: mau),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(duGan ? tieuDeGan : tieuDeXa, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(
                  l10n.cachDiaChiHenDaXacThuc('$met', gio),
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
