import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/widgets/cancel_booking_sheet.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule_appointment_row.dart';

// Danh sách đơn đã nhận của một ngày, hiện trong sheet chỉnh giờ rảnh
class DayBookingsList extends StatelessWidget {
  const DayBookingsList({
    super.key,
    required this.ngay,
    required this.donList,
    required this.onHuyDon,
    this.chiXem = false,
  });

  final DateTime ngay;
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
              child: Text(
                l10n.donTrongNgay,
                style: AppTextStyles.label.copyWith(fontSize: 13),
              ),
            ),
            Text(
              l10n.soDon(donList.length.toString()),
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        for (final don in donList) ...[
          ScheduleAppointmentRow(
            appt: don,
            hanhDong: chiXem
                ? null
                : _NutHuy(ngay: ngay, don: don, onHuy: () => onHuyDon(don)),
          ),
          if (don != donList.last)
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

// Nút huỷ của một đơn
class _NutHuy extends StatelessWidget {
  const _NutHuy({required this.ngay, required this.don, required this.onHuy});

  final DateTime ngay;
  final ScheduleAppointment don;
  final VoidCallback onHuy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lyDoKhoa = switch (kiemTraHuy(
      gioHen: don.gioHenNgay(ngay),
      dangDienRa: don.dangDienRa,
    )) {
      KhaNangHuy.duoc => null,
      KhaNangHuy.dangDienRa => l10n.dangDienRaKhongHuy,
      KhaNangHuy.satGioHen => l10n.khongTheHuyDonNay,
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
          textStyle: AppTextStyles.label.copyWith(fontSize: 13),
        ),
      ),
    );
  }
}
