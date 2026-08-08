import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/widgets/booking_step_progress.dart';

// Khối trạng thái
class BookingStatusBlock extends StatelessWidget {
  const BookingStatusBlock({
    super.key,
    required this.icon,
    required this.tieuDe,
    required this.moTa,
    required this.soBuocXong,
    required this.buocHienTai,
    this.mocPhu,
    this.mauMocPhu,
    this.mauNhanManh,
    this.dangChay = false,
  });

  final IconData icon;
  final String tieuDe;
  final String moTa;
  final int soBuocXong;
  final BuocDon buocHienTai;

  final String? mocPhu;
  final Color? mauMocPhu;

  final Color? mauNhanManh;
  final bool dangChay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: mauNhanManh ?? AppColors.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tieuDe,
                style: AppTextStyles.label.copyWith(color: mauNhanManh),
              ),
            ),
            if (mocPhu case final moc?) ...[
              const SizedBox(width: 10),
              Text(
                moc,
                style: AppTextStyles.label.copyWith(
                  color: mauMocPhu ?? AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(moTa, style: AppTextStyles.captionSm),
        const SizedBox(height: 20),
        BookingStepProgress(
          soBuocXong: soBuocXong,
          buocHienTai: buocHienTai,
          dangChay: dangChay,
        ),
      ],
    );
  }
}
