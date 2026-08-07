import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/widgets/calendar_legend.dart';

const double _oNgay = 34;

class SitterProfileCalendar extends StatelessWidget {
  const SitterProfileCalendar({
    super.key,
    this.ngayKinDon = const [],
    this.ngayNghi = const [],
    this.onXemDayDu,
  });

  final List<DateTime> ngayKinDon;
  final List<DateTime> ngayNghi;
  final VoidCallback? onXemDayDu;

  static bool _trong(List<DateTime> ds, DateTime d) =>
      ds.any((k) => k.year == d.year && k.month == d.month && k.day == d.day);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final now = nowVn();
    final days = [for (var i = 0; i < 7; i++) now.add(Duration(days: i))];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.lichTrongTuanNay, style: AppTextStyles.h3),
            const Spacer(),
            if (onXemDayDu != null)
              InkWell(
                onTap: onXemDayDu,
                child: Row(
                  children: [
                    Text(
                      l10n.xemLichDayDu,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward,
                      size: 13,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final d in days)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      thuNganTheoSo(context.l10n, d.weekday),
                      style: AppTextStyles.captionSm.copyWith(
                        color: _trong(ngayNghi, d)
                            ? AppColors.neutral
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ONgay(
                      ngay: d.day,
                      kin: _trong(ngayKinDon, d),
                      nghi: _trong(ngayNghi, d),
                      laHomNay: cungNgay(d, now),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        const CalendarLegend(hienDaQua: false),
      ],
    );
  }
}

class _ONgay extends StatelessWidget {
  const _ONgay({
    required this.ngay,
    required this.kin,
    required this.nghi,
    required this.laHomNay,
  });

  final int ngay;
  final bool kin;
  final bool nghi;
  final bool laHomNay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _oNgay,
      height: _oNgay,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kin ? AppColors.neutral : null,
        shape: BoxShape.circle,
        border: laHomNay
            ? Border.all(color: AppColors.primaryColor, width: 1.6)
            : null,
      ),
      child: Text(
        '$ngay',
        style: AppTextStyles.label.copyWith(
          color: laHomNay
              ? AppColors.primaryColor
              : kin
              ? AppColors.textSecondary
              : nghi
              ? AppColors.neutral
              : AppColors.textPrimary,
        ),
      ),
    );
  }
}
