import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';

// Một dòng lịch hẹn dùng chung cho tab Lịch và Lịch hôm nay ở tab Công việc
class ScheduleAppointmentRow extends StatelessWidget {
  const ScheduleAppointmentRow({
    super.key,
    required this.appt,
    this.onTap,
    this.hanhDong,
  });

  final ScheduleAppointment appt;
  final VoidCallback? onTap;
  final Widget? hanhDong;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, bg, txt) = switch (appt.status) {
      ScheduleApptStatus.sapToi => (
        l10n.sapToi,
        AppColors.accent.withValues(alpha: 0.12),
        AppColors.accent,
      ),
      ScheduleApptStatus.dangDienRa => (
        l10n.dangDienRa,
        AppColors.primaryColor,
        AppColors.textWhite,
      ),
      ScheduleApptStatus.choXacNhan => (
        l10n.trangThaiChoXacNhan,
        AppColors.cardMint,
        AppColors.primaryColor,
      ),
      ScheduleApptStatus.hoanThanh => (
        l10n.hoanThanh,
        AppColors.neutralLight,
        AppColors.textSecondary,
      ),
    };

    final quanCuaDon = appt.district;

    final (gioChinh, dongDuoi) = switch (appt.phanNgay) {
      PhanNgayTrongGiu.nhan => (appt.startTime, l10n.nhanBeNgan),
      PhanNgayTrongGiu.tra => (appt.endTime, l10n.traBeNgan),
      PhanNgayTrongGiu.troc => (l10n.caNgay, ''),
      null => (appt.startTime, appt.endTime),
    };

    // Đơn trải nhiều ngày
    final tenDichVu = appt.nhieuNgay
        ? '${appt.serviceName} · '
              '${l10n.ngayThuTrenTong(appt.ngayThu.toString(), appt.tongNgay.toString())}'
        : appt.serviceName;

    // Material trong suốt để hiệu ứng chạm hiện đúng trên nền màn
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // Chạm một dòng lịch là mở đúng đơn đó; màn chi tiết tự tải đơn theo id
        onTap:
            onTap ??
            () => context.push(AppRoutes.sitterOrderDetailPath(appt.id)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gioChinh,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryColor,
                          ),
                          maxLines: 1,
                          softWrap: false,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dongDuoi,
                          style: AppTextStyles.captionSm,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    // Dải avatar rồi cột chữ
                    child: Row(
                      children: [
                        PetAvatarStack(pets: appt.pets),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: tenDichVu,
                                      style: AppTextStyles.label,
                                    ),
                                    TextSpan(
                                      text: ' · #${appt.code}',
                                      style: AppTextStyles.captionSm,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                appt.pets.length == 1
                                    ? moTaCacBe(l10n, appt.pets)
                                    : l10n.soBeVaTen(
                                        appt.pets.length.toString(),
                                        moTaCacBe(l10n, appt.pets),
                                      ),
                                style: AppTextStyles.captionSm.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              // Chủ nuôi, khu vực và nhãn trạng thái
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      quanCuaDon == null
                                          ? appt.ownerName
                                          : '${appt.ownerName} · $quanCuaDon',
                                      style: AppTextStyles.captionSm,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AppStatusBadge(
                                    label: label,
                                    background: bg,
                                    textColor: txt,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hanhDong != null)
                Align(alignment: Alignment.centerRight, child: hanhDong!),
            ],
          ),
        ),
      ),
    );
  }
}
