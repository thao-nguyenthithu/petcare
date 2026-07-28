import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Thanh chuyển chế độ Lịch đơn, Giờ rảnh
enum ScheduleMode { lichDon, gioRanh }

class ScheduleModeToggle extends StatelessWidget {
  const ScheduleModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ScheduleMode mode;
  final ValueChanged<ScheduleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Segment(
            label: l10n.lichDon,
            selected: mode == ScheduleMode.lichDon,
            onTap: () => onChanged(ScheduleMode.lichDon),
          ),
          _Segment(
            label: l10n.gioRanh,
            selected: mode == ScheduleMode.gioRanh,
            onTap: () => onChanged(ScheduleMode.gioRanh),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 14,
              color: selected ? AppColors.primaryColor : AppColors.textWhite,
            ),
          ),
        ),
      ),
    );
  }
}
