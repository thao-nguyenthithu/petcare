import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';

// Dải chọn ngày trong tuần
class ScheduleWeekStrip extends StatelessWidget {
  const ScheduleWeekStrip({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ScheduleDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  static double chieuCao(BuildContext context) {
    final caoNhanThu = MediaQuery.textScalerOf(context).scale(16);
    return AppSpacing.itemGap * 2 + 12 + caoNhanThu + 6 + 40 + 5 + 5;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.itemGap,
      ),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: _DayCell(
                day: days[i],
                selected: i == selectedIndex,
                onTap: () => onSelect(i),
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
    final Color soColor = selected
        ? AppColors.textWhite
        : (day.isToday
              ? AppColors.primaryColor
              : (day.ngayNghi
                    ? AppColors.textSecondary
                    : AppColors.textPrimary));
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(
              thuNgan(l10n, day.date),
              style: AppTextStyles.captionSm.copyWith(
                color: selected
                    ? AppColors.primaryColor
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Ngày đã đặt nghỉ tô nền xám nhạt
                color: selected
                    ? AppColors.primaryColor
                    : (day.ngayNghi
                          ? AppColors.neutralLight
                          : Colors.transparent),
                shape: BoxShape.circle,
                border: (!selected && day.isToday)
                    ? Border.all(color: AppColors.primaryColor, width: 1.5)
                    : null,
              ),
              child: Text(
                day.date.day.toString(),
                style: AppTextStyles.label.copyWith(
                  fontSize: 15,
                  color: soColor,
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Chấm báo có lịch hẹn
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: day.coLichHen
                    ? (selected ? AppColors.primaryColor : AppColors.accent)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
