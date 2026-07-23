import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_home/data/mock_provider_home.dart';
import 'package:petcare_app/features/provider_home/widgets/section_empty.dart';

// Hiệu suất tháng này: 3 chỉ số.
class MonthlyPerformanceCard extends StatelessWidget {
  const MonthlyPerformanceCard({super.key, required this.data});

  final MockProviderDashboard data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hieuSuatThangNay, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        if (data.completedThisMonth == 0)
          SectionEmpty(
            icon: Icons.insights_outlined,
            message: l10n.chuaCoHieuSuat,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardMint,
              borderRadius: BorderRadius.circular(AppRadius.radius14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _PerfStat(
                    icon: Icons.star,
                    iconColor: AppColors.accent,
                    value: data.rating.toString().replaceAll('.', ','),
                    label: l10n.diemDanhGia,
                  ),
                ),
                const _PerfDivider(),
                Expanded(
                  child: _PerfStat(
                    icon: Icons.check,
                    iconColor: AppColors.primaryColor,
                    value: '${data.acceptRate}%',
                    label: l10n.tyLeNhan,
                  ),
                ),
                const _PerfDivider(),
                Expanded(
                  child: _PerfStat(
                    icon: Icons.work_outline,
                    iconColor: AppColors.primaryColor,
                    value: '${data.completedThisMonth}',
                    label: l10n.hoanThanh,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PerfDivider extends StatelessWidget {
  const _PerfDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: AppColors.neutralLight);
  }
}

class _PerfStat extends StatelessWidget {
  const _PerfStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.captionSm.copyWith(fontSize: 11)),
      ],
    );
  }
}
