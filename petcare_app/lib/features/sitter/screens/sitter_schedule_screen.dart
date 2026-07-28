import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/sitter/screens/working_hours_screen.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_availability_view.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_mode_toggle.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_orders_view.dart';
import 'package:petcare_app/shared/widgets/green_title_header.dart';

// Tab Lịch của NCC
class SitterScheduleScreen extends StatefulWidget {
  const SitterScheduleScreen({super.key});

  @override
  State<SitterScheduleScreen> createState() => _SitterScheduleScreenState();
}

class _SitterScheduleScreenState extends State<SitterScheduleScreen> {
  ScheduleMode _mode = ScheduleMode.lichDon;

  // Màn dùng mock nên push thẳng, chưa cần route riêng.
  Future<void> _moGioLamViec() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const WorkingHoursScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          GreenTitleHeader(
            title: l10n.lich,
            subtitle: l10n.quanLyNgayGioNhanDon,
            bottom: ScheduleModeToggle(
              mode: _mode,
              onChanged: (m) => setState(() => _mode = m),
            ),
          ),
          if (_mode == ScheduleMode.lichDon)
            Expanded(
              child: ScheduleOrdersView(
                onSuaGioRanh: () =>
                    setState(() => _mode = ScheduleMode.gioRanh),
              ),
            )
          else
            Expanded(
              child: ScheduleAvailabilityView(onMoGioLamViec: _moGioLamViec),
            ),
        ],
      ),
    );
  }
}
