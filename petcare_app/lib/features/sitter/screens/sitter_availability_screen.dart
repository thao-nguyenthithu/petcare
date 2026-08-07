import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/calendar_legend.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/month_calendar.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

typedef SitterAvailabilityArgs = ({
  String tenNcc,
  List<DateTime> ngayKinDon,
  List<DateTime> ngayNghi,
});

// Trang xem lịch đầy đủ của NCC, dùng nguyên lịch của trang chọn ngày giờ
class SitterAvailabilityScreen extends StatelessWidget {
  const SitterAvailabilityScreen({super.key, required this.args});

  final SitterAvailabilityArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bayGio = nowVn();
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.lichTrong, subtitle: args.tenNcc),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          FlatSection(
            child: MonthCalendar(
              laNgayKin: kinTheoDanhSach(args.ngayKinDon),
              choPhep: (d) => ngayChonDuoc(d, bayGio, args.ngayNghi),
            ),
          ),
          const SizedBox(height: 16),
          const FlatSection(child: CalendarLegend()),
          const FlatDivider(),
          FlatSection(
            child: AppNoteBox(
              text: l10n.ghiChuDatTruocToiDaNNgay('$maxAdvanceDays'),
            ),
          ),
          const SizedBox(height: 10),
          FlatSection(child: AppNoteBox(text: l10n.ghiChuLichCoTheDoi)),
        ],
      ),
    );
  }
}
