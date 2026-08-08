import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/block_days_off_sheet.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/day_availability_sheet.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/calendar_legend.dart';
import 'package:petcare_app/shared/widgets/month_calendar.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Chế độ Giờ rảnh của tab Lịch
class ScheduleAvailabilityView extends ConsumerStatefulWidget {
  const ScheduleAvailabilityView({super.key, required this.onMoGioLamViec});

  // Điều hướng do màn view chỉ dựng lại sau khi màn đóng
  final Future<void> Function() onMoGioLamViec;

  @override
  ConsumerState<ScheduleAvailabilityView> createState() =>
      _ScheduleAvailabilityViewState();
}

class _ScheduleAvailabilityViewState
    extends ConsumerState<ScheduleAvailabilityView> {
  DateTime? _ngayChon;
  DateTime _thangDangXem = DateTime(homNayVn().year, homNayVn().month);

  DateTime get _cuoiThang =>
      DateTime(_thangDangXem.year, _thangDangXem.month + 1, 0);

  @override
  void initState() {
    super.initState();
    ref
        .read(sitterScheduleProvider.notifier)
        .damBaoKhoang(_thangDangXem, _cuoiThang);
  }

  void _doiThang(DateTime thang) {
    setState(() => _thangDangXem = thang);
    ref
        .read(sitterScheduleProvider.notifier)
        .damBaoKhoang(thang, DateTime(thang.year, thang.month + 1, 0));
  }

  Future<void> _taiLai() => ref
      .read(sitterScheduleProvider.notifier)
      .taiLai(_thangDangXem, _cuoiThang);

  void _baoLoiLuu() {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.luuThatBai)));
  }

  Future<void> _moChinhNgay(DateTime ngay, SitterSchedule lich) async {
    setState(() => _ngayChon = ngay);
    final ketQua = await showDayAvailabilitySheet(
      context,
      ngay,
      lich.cuaNgay(ngay),
    );
    if (!mounted) return;
    setState(() => _ngayChon = null);
    if (ketQua == null) return;
    try {
      await ref.read(sitterScheduleProvider.notifier).luuNgay(ngay, ketQua);
    } catch (_) {
      _baoLoiLuu();
    }
  }

  Future<void> _moGioLamViec() async {
    await widget.onMoGioLamViec();
    if (mounted) setState(() {});
  }

  Future<void> _moChanKhoang() async {
    final khoang = await showBlockDaysOffSheet(context);
    if (khoang == null || !mounted) return;
    try {
      await ref
          .read(sitterScheduleProvider.notifier)
          .datNghiKhoang(khoang.tu, khoang.den, khoang.lyDo);
    } catch (_) {
      _baoLoiLuu();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ref
        .watch(sitterScheduleProvider)
        .when(
          loading: () => const AppSkeletonList(soThe: 3, caoThe: 140),
          error: (_, _) => AppNetworkError(
            onRetry: () => ref.invalidate(sitterScheduleProvider),
          ),
          data: (lich) => AppRefreshIndicator(
            onRefresh: _taiLai,
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
                  _CardGioLamViec(lich: lich, onTap: _moGioLamViec),
                  const SizedBox(height: AppSpacing.groupGap),
                  Text(l10n.chinhTheoTungNgay, style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    l10n.chinhTheoTungNgayMoTa,
                    style: AppTextStyles.captionSm,
                  ),
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
                      child: Column(
                        children: [
                          // Người chăm ấn được MỌI ngày, kể cả ngày đã qua
                          MonthCalendar(
                            chon: _ngayChon,
                            laNgayKin: lich.kinCho,
                            choPhep: (ngay) =>
                                !lich.ngayNghi(ngay) &&
                                !ngay.isBefore(homNayVn()),
                            coCham: (ngay) => lich.lichCuaNgay(ngay).isNotEmpty,
                            chamMoiNgay: true,
                            nutHomNay: true,
                            onDoiThang: _doiThang,
                            onChon: (ngay) => _moChinhNgay(ngay, lich),
                          ),
                          const SizedBox(height: AppSpacing.itemGap),
                          const CalendarLegend(chonDuoc: true, hienCoDon: true),
                        ],
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
          ),
        );
  }
}

// Khung giờ nhận đơn mặc định áp cho mọi ngày
class _CardGioLamViec extends StatelessWidget {
  const _CardGioLamViec({required this.lich, required this.onTap});

  final SitterSchedule lich;
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
                      l10n.khungGio(lich.gioBatDau, lich.gioKetThuc),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${moTaCacThu(l10n, lich.ngayLamViec, khiRong: l10n.chuaChonNgayLamViec)}'
                      ' · ${l10n.trongGiuNhanTheoNgay}',
                      style: AppTextStyles.captionSm,
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
