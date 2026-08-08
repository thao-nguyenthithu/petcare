import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/widgets/cancel_booking_sheet.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule_appointment_row.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Danh sách đơn đã nhận của một ngày, hiện trong sheet chỉnh giờ rảnh
class DayBookingsList extends StatelessWidget {
  const DayBookingsList({
    super.key,
    required this.donList,
    required this.onHuyDon,
    this.chiXem = false,
  });

  final List<ScheduleAppointment> donList;
  final ValueChanged<ScheduleAppointment> onHuyDon;
  final bool chiXem; // ngày đã qua: chỉ liệt kê, không có nút huỷ

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(l10n.donTrongNgay, style: AppTextStyles.label),
            ),
            Text(
              l10n.soDon(donList.length.toString()),
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        for (final don in donList) ...[
          ScheduleAppointmentRow(
            appt: don,
            hanhDong: chiXem
                ? null
                : _NutHuy(don: don, onHuy: () => onHuyDon(don)),
          ),
          if (don != donList.last) const AppDongKe(),
        ],
      ],
    );
  }
}

// Nút huỷ của một đơn
class _NutHuy extends StatelessWidget {
  const _NutHuy({required this.don, required this.onHuy});
  final ScheduleAppointment don;
  final VoidCallback onHuy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lyDoKhoa = switch (kiemTraHuy(
      dangDienRa: don.dangDienRa,
      daXuatPhat: false,
    )) {
      KhaNangHuy.duoc => null,
      KhaNangHuy.dangDienRa => l10n.dangDienRaKhongHuy,
      KhaNangHuy.daXuatPhat => l10n.daXuatPhatDungKhongTheTiepNhan,
    };
    return Tooltip(
      message: lyDoKhoa ?? '',
      triggerMode: lyDoKhoa == null
          ? TooltipTriggerMode.manual
          : TooltipTriggerMode.tap,
      child: TextButton.icon(
        onPressed: lyDoKhoa == null ? onHuy : null,
        icon: const Icon(Icons.cancel_outlined, size: 16),
        label: Text(l10n.huyDon),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          visualDensity: VisualDensity.compact,
          textStyle: AppTextStyles.label,
        ),
      ),
    );
  }
}
