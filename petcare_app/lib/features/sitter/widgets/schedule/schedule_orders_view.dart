import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_availability.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_day_section.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_filter_sheet.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_text_link.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_week_strip.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Trang giữa của PageView
const int _trangTuanHienTai = 5000;

// Chế độ Lịch đơn của tab Lịch NCC
class ScheduleOrdersView extends StatefulWidget {
  const ScheduleOrdersView({super.key, required this.onSuaGioRanh});

  final VoidCallback onSuaGioRanh; // chuyển sang chế độ Giờ rảnh

  @override
  State<ScheduleOrdersView> createState() => _ScheduleOrdersViewState();
}

class _ScheduleOrdersViewState extends State<ScheduleOrdersView> {
  final PageController _pageController = PageController(
    initialPage: _trangTuanHienTai,
  );

  final DateTime _thuHaiGoc = dauTuan(homNayVn());

  int _trang = _trangTuanHienTai;
  late int _thuDangChon = homNayVn().weekday - DateTime.monday;
  ScheduleFilter _filter = const ScheduleFilter();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _thuHaiCuaTrang(int trang) =>
      _thuHaiGoc.add(Duration(days: (trang - _trangTuanHienTai) * 7));

  DateTime get _ngayDangChon =>
      _thuHaiCuaTrang(_trang).add(Duration(days: _thuDangChon));

  Future<void> _moLoc() async {
    final ketQua = await showScheduleFilterSheet(context, _filter);
    if (ketQua != null && mounted) setState(() => _filter = ketQua);
  }

  void _doiSoCho(int soCho) => setState(
    () => MockSitterAvailability.datNgay(
      _ngayDangChon,
      MockSitterAvailability.cuaNgay(
        _ngayDangChon,
      ).copyWith(boardingSlots: soCho),
    ),
  );

  // Nút Hôm nay quay về đúng ngày hôm nay
  void _veHomNay() {
    setState(() => _thuDangChon = homNayVn().weekday - DateTime.monday);
    if (_trang == _trangTuanHienTai) return;
    _pageController.animateToPage(
      _trangTuanHienTai,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.itemGap,
            AppSpacing.screenPadding,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  nhanThangNam(l10n, _ngayDangChon),
                  style: AppTextStyles.label,
                ),
              ),
              ScheduleTextLink(nhan: l10n.homNay, onTap: _veHomNay),
            ],
          ),
        ),
        SizedBox(
          height: ScheduleWeekStrip.chieuCao(context),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (trang) => setState(() => _trang = trang),
            itemBuilder: (context, trang) => ScheduleWeekStrip(
              days: MockSitterScheduleData.tuanTu(_thuHaiCuaTrang(trang)),
              selectedIndex: _thuDangChon,
              onSelect: (i) => setState(() => _thuDangChon = i),
            ),
          ),
        ),
        const AppDongKe(),
        Expanded(
          child: AppRefreshIndicator(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.blockGap,
                    AppSpacing.screenPadding,
                    AppSpacing.screenEdgeGap,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: ScheduleDaySection(
                      day: MockSitterScheduleData.chiTietNgay(_ngayDangChon),
                      filter: _filter,
                      onMoLoc: _moLoc,
                      onXoaLoc: () =>
                          setState(() => _filter = const ScheduleFilter()),
                      onSuaGioRanh: widget.onSuaGioRanh,
                      onDoiSoCho: _doiSoCho,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
