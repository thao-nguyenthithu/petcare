import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';

const double _caoDongNhanThu = 20;

// Dải chọn ngày trong tuần, nhận ngày đang chọn chứ không nhận thứ
class ScheduleWeekStrip extends StatelessWidget {
  const ScheduleWeekStrip({
    super.key,
    required this.days,
    required this.ngayChon,
    required this.onSelect,
  });

  final List<ScheduleDay> days;
  final DateTime? ngayChon;
  final ValueChanged<DateTime> onSelect;

  static double chieuCao(BuildContext context) {
    final caoNhanThu = MediaQuery.textScalerOf(context).scale(_caoDongNhanThu);
    return AppSpacing.itemGap * 2 + 12 + caoNhanThu + 6 + 40 + 5 + 5;
  }

  @override
  Widget build(BuildContext context) {
    final chon = ngayChon;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.itemGap,
      ),
      child: Row(
        children: [
          for (final d in days)
            Expanded(
              child: _DayCell(
                day: d,
                selected: chon != null && cungNgay(d.date, chon),
                onTap: () => onSelect(d.date),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final ScheduleDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daQua = day.date.isBefore(homNayVn());
    final vienHomNay = day.isToday && !selected;
    final kinDon = day.kinCho;
    final Color soColor = selected
        ? AppColors.textWhite
        : vienHomNay
        ? AppColors.primaryColor
        : kinDon
        ? AppColors.textSecondary
        : (day.ngayNghi || daQua)
        ? AppColors.neutral
        : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(
              thuNgan(l10n, day.date),
              style: AppTextStyles.label.copyWith(
                color: selected
                    ? AppColors.primaryColor
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryColor
                    : kinDon
                    ? AppColors.neutral
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: vienHomNay
                    ? Border.all(color: AppColors.primaryColor, width: 1.6)
                    : null,
              ),
              child: Text(
                day.date.day.toString(),
                style: AppTextStyles.label.copyWith(color: soColor),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: day.coLichHen ? AppColors.accent : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
