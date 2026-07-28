import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_availability.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/availability_month_calendar.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/block_days_off_sheet.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/day_availability_sheet.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';

// Chế độ Giờ rảnh của tab Lịch
class ScheduleAvailabilityView extends StatefulWidget {
  const ScheduleAvailabilityView({super.key, required this.onMoGioLamViec});

  // Điều hướng do màn view chỉ dựng lại sau khi màn đóng
  final Future<void> Function() onMoGioLamViec;

  @override
  State<ScheduleAvailabilityView> createState() =>
      _ScheduleAvailabilityViewState();
}

class _ScheduleAvailabilityViewState extends State<ScheduleAvailabilityView> {
  DateTime _thang = homNayVn();

  @override
  void initState() {
    super.initState();
    MockSitterAvailability.napMauNeuTrong();
  }

  Future<void> _moChinhNgay(DateTime ngay) async {
    final ketQua = await showDayAvailabilitySheet(
      context,
      ngay,
      MockSitterAvailability.cuaNgay(ngay),
    );
    if (!mounted) return;
    // NCC có thể đã huỷ đơn ngay trong sheet dù không bấm Lưu
    setState(() {
      if (ketQua != null) MockSitterAvailability.datNgay(ngay, ketQua);
    });
  }

  // Sửa khung giờ làm việc mặc định rồi dựng lại card cho đúng giá trị mới
  Future<void> _moGioLamViec() async {
    await widget.onMoGioLamViec();
    if (mounted) setState(() {});
  }

  Future<void> _moChanKhoang() async {
    final khoang = await showBlockDaysOffSheet(context);
    if (khoang == null || !mounted) return;
    setState(
      () =>
          MockSitterAvailability.nghiKhoang(khoang.tu, khoang.den, khoang.lyDo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppRefreshIndicator(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.blockGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.gioLamViec, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(l10n.gioLamViecMoTa, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.itemGap),
            _CardGioLamViec(onTap: _moGioLamViec),
            const SizedBox(height: AppSpacing.groupGap),
            Text(l10n.chinhTheoTungNgay, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(l10n.chinhTheoTungNgayMoTa, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.itemGap),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.itemGap),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  border: Border.all(color: AppColors.neutralLight),
                ),
                child: AvailabilityMonthCalendar(
                  thang: _thang,
                  ngayNghi: MockSitterAvailability.ngayNghi,
                  coDon: (ngay) =>
                      MockSitterScheduleData.lichCuaNgay(ngay).isNotEmpty,
                  onChonNgay: _moChinhNgay,
                  onDoiThang: (buoc) => setState(
                    () => _thang = DateTime(_thang.year, _thang.month + buoc),
                  ),
                  onVeHomNay: () => setState(() => _thang = homNayVn()),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: l10n.chanKhoangNgayNghi,
              icon: Icons.add,
              onTap: _moChanKhoang,
            ),
          ],
        ),
      ),
    );
  }
}

// Khung giờ nhận đơn mặc định áp cho mọi ngày
class _CardGioLamViec extends StatelessWidget {
  const _CardGioLamViec({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.itemGap),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.cardMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 20,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.khungGio(
                        MockSitterAvailability.gioBatDau,
                        MockSitterAvailability.gioKetThuc,
                      ),
                      style: AppTextStyles.label.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${moTaCacThu(l10n, MockSitterAvailability.ngayLamViec, khiRong: l10n.chuaChonNgayLamViec)}'
                      ' · ${l10n.trongGiuNhanTheoNgay}',
                      style: AppTextStyles.captionSm.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
