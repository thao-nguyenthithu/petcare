import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_availability.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/availability_fields.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_filter_sheet.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_text_link.dart';
import 'package:petcare_app/features/sitter/widgets/schedule_appointment_row.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Nội dung của ngày đang chọn của Lịch Đơn
class ScheduleDaySection extends StatelessWidget {
  const ScheduleDaySection({
    super.key,
    required this.day,
    required this.filter,
    required this.onMoLoc,
    required this.onXoaLoc,
    required this.onSuaGioRanh,
    required this.onDoiSoCho,
  });

  final ScheduleDay day;
  final ScheduleFilter filter;
  final VoidCallback onMoLoc;
  final VoidCallback onXoaLoc;
  final VoidCallback onSuaGioRanh;
  final ValueChanged<int> onDoiSoCho; // đổi số chỗ trông giữ của ngày này

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hienThi = day.appointments.where(filter.khop).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                nhanNgayDayDu(l10n, day.date),
                style: AppTextStyles.h3,
              ),
            ),
            Text(
              l10n.soDon(hienThi.length.toString()),
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: onMoLoc,
              padding: const EdgeInsets.only(left: AppSpacing.itemGap),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              tooltip: l10n.boLoc,
              icon: Icon(
                Icons.filter_list,
                size: 20,
                color: filter.coLoc
                    ? AppColors.primaryColor
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        // Số chỗ trông giữ
        SlotStepperField(
          soCho: MockSitterAvailability.cuaNgay(day.date).boardingSlots,
          toiDa: MockSitterAvailability.soChoToiDa,
          onDoi: onDoiSoCho,
          nhan: '${l10n.trongGiu} · ${l10n.conNhanCho}',
          chiXem: day.date.isBefore(homNayVn()),
        ),
        if (day.ngayNghi) ...[
          const SizedBox(height: AppSpacing.labelGap),
          const _BannerNgayNghi(),
        ],
        const SizedBox(height: AppSpacing.labelGap),
        if (!day.coLichHen)
          _RongCaNgay(ngayNghi: day.ngayNghi, onSuaGioRanh: onSuaGioRanh)
        else if (hienThi.isEmpty)
          _RongDoLoc(onXoaLoc: onXoaLoc)
        else
          for (final appt in hienThi) ...[
            ScheduleAppointmentRow(appt: appt),
            if (appt != hienThi.last) const AppDongKe(),
          ],
      ],
    );
  }
}

// Ngày đã đặt nghỉ nhưng vẫn còn đơn nhận từ trước
class _BannerNgayNghi extends StatelessWidget {
  const _BannerNgayNghi();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.itemGap,
        vertical: AppSpacing.labelGap,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutralLight,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.labelGap),
          Expanded(
            child: Text(
              context.l10n.ngayNghiMoTa,
              style: AppTextStyles.captionSm.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

// Ngày không có đơn nào
class _RongCaNgay extends StatelessWidget {
  const _RongCaNgay({required this.ngayNghi, required this.onSuaGioRanh});

  final bool ngayNghi;
  final VoidCallback onSuaGioRanh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.blockGap),
      child: ngayNghi
          ? AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: l10n.ngayNghi,
              message: l10n.ngayNghiMoTa,
              circleColor: AppColors.neutralLight,
              iconColor: AppColors.textSecondary,
              action: ScheduleTextLink(
                nhan: l10n.suaGioRanh,
                onTap: onSuaGioRanh,
              ),
            )
          : AppEmptyState(
              icon: Icons.event_available_outlined,
              title: l10n.khongCoLichHen,
              message: l10n.khongCoLichHenMoTa,
              circleColor: AppColors.cardMint,
            ),
    );
  }
}

// Ngày có đơn nhưng bộ lọc không khớp cái nào
class _RongDoLoc extends StatelessWidget {
  const _RongDoLoc({required this.onXoaLoc});

  final VoidCallback onXoaLoc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.blockGap),
      child: AppEmptyState(
        icon: Icons.filter_list_off,
        title: l10n.khongCoDonKhopLoc,
        message: l10n.khongCoDonKhopLocMoTa,
        circleColor: AppColors.cardMint,
        action: ScheduleTextLink(nhan: l10n.xoaBoLoc, onTap: onXoaLoc),
      ),
    );
  }
}
