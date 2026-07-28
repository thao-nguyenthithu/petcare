import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_text_link.dart';

// Lịch tháng của chế độ Giờ rảnh
class AvailabilityMonthCalendar extends StatelessWidget {
  const AvailabilityMonthCalendar({
    super.key,
    required this.thang,
    required this.ngayNghi,
    required this.coDon,
    required this.onChonNgay,
    required this.onDoiThang,
    required this.onVeHomNay,
  });

  final DateTime thang; // ngày bất kỳ trong tháng đang xem
  final bool Function(DateTime) ngayNghi;
  final bool Function(DateTime) coDon;
  final ValueChanged<DateTime> onChonNgay;
  final ValueChanged<int> onDoiThang;
  final VoidCallback onVeHomNay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dauThang = DateTime(thang.year, thang.month);
    final soNgay = DateTime(thang.year, thang.month + 1, 0).day;
    final oTrong = dauThang.weekday - DateTime.monday;

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => onDoiThang(-1),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_left, size: 22),
              color: AppColors.textPrimary,
            ),
            Text(nhanThangNam(l10n, dauThang), style: AppTextStyles.label),
            IconButton(
              onPressed: () => onDoiThang(1),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.chevron_right, size: 22),
              color: AppColors.textPrimary,
            ),
            const Spacer(),
            ScheduleTextLink(nhan: l10n.homNay, onTap: onVeHomNay),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    thuNgan(l10n, dauThang.add(Duration(days: i - oTrong))),
                    style: AppTextStyles.captionSm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: i == 6
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1,
          children: [
            for (var i = 0; i < oTrong; i++) const SizedBox.shrink(),
            ...List.generate(soNgay, (i) {
              final ngay = DateTime(thang.year, thang.month, i + 1);
              return _ONgay(
                date: ngay,
                nghi: ngayNghi(ngay),
                coDon: coDon(ngay),
                onTap: onChonNgay,
              );
            }),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ChuThich(mau: AppColors.primaryColor, nhan: l10n.homNay),
            const SizedBox(width: AppSpacing.stackGap),
            _ChuThich(mau: AppColors.neutralLight, nhan: l10n.daNghi),
            const SizedBox(width: AppSpacing.stackGap),
            _ChuThich(mau: AppColors.accent, nhan: l10n.coDon),
          ],
        ),
      ],
    );
  }
}

class _ONgay extends StatelessWidget {
  const _ONgay({
    required this.date,
    required this.nghi,
    required this.coDon,
    required this.onTap,
  });

  final DateTime date;
  final bool nghi;
  final bool coDon;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final homNay = cungNgay(date, homNayVn());
    final daQua = date.isBefore(homNayVn());
    final Color mauChu = homNay
        ? AppColors.textWhite
        : (daQua || nghi ? AppColors.textSecondary : AppColors.textPrimary);

    // Ngày đã qua vẫn mở được xem lại lịch
    return InkWell(
      onTap: () => onTap(date),
      customBorder: const CircleBorder(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: homNay
                  ? AppColors.primaryColor
                  : (nghi ? AppColors.neutralLight : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Text(
              date.day.toString(),
              style: AppTextStyles.label.copyWith(fontSize: 14, color: mauChu),
            ),
          ),
          const SizedBox(height: 3),
          // Chấm cam báo ngày đã có đơn
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: coDon ? AppColors.accent : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChuThich extends StatelessWidget {
  const _ChuThich({required this.mau, required this.nhan});

  final Color mau;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: mau, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.textGap),
        Text(nhan, style: AppTextStyles.captionSm.copyWith(fontSize: 11)),
      ],
    );
  }
}
