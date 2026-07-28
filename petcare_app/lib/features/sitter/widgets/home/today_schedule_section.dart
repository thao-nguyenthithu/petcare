import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule_appointment_row.dart';
import 'package:petcare_app/features/sitter/widgets/section_empty.dart';

// Lịch hôm nay dùng chung với tab Lịch
class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({super.key, required this.items});

  final List<ScheduleAppointment> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.lichHomNay, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.labelGap),
        if (items.isEmpty)
          SectionEmpty(icon: Icons.event_busy, message: l10n.chuaCoLichHomNay)
        else
          for (final appt in items) ...[
            ScheduleAppointmentRow(appt: appt),
            if (appt != items.last)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutralLight,
              ),
          ],
      ],
    );
  }
}
