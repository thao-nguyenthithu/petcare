import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_day_section.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_filter_sheet.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_text_link.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_week_strip.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Trang giữa của PageView
const int _trangTuanHienTai = 5000;

// Chế độ Lịch đơn của tab Lịch NCC
class ScheduleOrdersView extends ConsumerStatefulWidget {
  const ScheduleOrdersView({super.key, required this.onSuaGioRanh});

  final VoidCallback onSuaGioRanh; // chuyển sang chế độ Giờ rảnh

  @override
  ConsumerState<ScheduleOrdersView> createState() => _ScheduleOrdersViewState();
}

class _ScheduleOrdersViewState extends ConsumerState<ScheduleOrdersView> {
  final PageController _pageController = PageController(
    initialPage: _trangTuanHienTai,
  );

  final DateTime _thuHaiGoc = dauTuan(homNayVn());

  int _trang = _trangTuanHienTai;
  DateTime _ngayDangChon = homNayVn();
  ScheduleFilter _filter = const ScheduleFilter();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _thuHaiCuaTrang(int trang) =>
      _thuHaiGoc.add(Duration(days: (trang - _trangTuanHienTai) * 7));

  DateTime get _chuNhatDangXem =>
      _thuHaiCuaTrang(_trang).add(const Duration(days: 6));

  Future<void> _moLoc() async {
    final ketQua = await showScheduleFilterSheet(context, _filter);
    if (ketQua != null && mounted) setState(() => _filter = ketQua);
  }

  void _doiTrang(int trang) {
    setState(() => _trang = trang);
    final thuHai = _thuHaiCuaTrang(trang);
    ref
        .read(sitterScheduleProvider.notifier)
        .damBaoKhoang(thuHai, thuHai.add(const Duration(days: 6)));
  }

  Future<void> _doiSoCho(int soCho) async {
    try {
      await ref
          .read(sitterScheduleProvider.notifier)
          .doiSoCho(_ngayDangChon, soCho);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.luuThatBai)));
    }
  }

  // Nút Hôm nay quay về đúng ngày hôm nay
  void _veHomNay() {
    setState(() => _ngayDangChon = homNayVn());
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
    final lich = ref.watch(sitterScheduleProvider);
    return lich.when(
      loading: () => const AppSkeletonList(soThe: 4, caoThe: 96),
      error: (_, _) => AppNetworkError(
        onRetry: () => ref.invalidate(sitterScheduleProvider),
      ),
      data: (data) => Column(
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
                    nhanThangNam(l10n, _thuHaiCuaTrang(_trang)),
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
              onPageChanged: _doiTrang,
              itemBuilder: (context, trang) => ScheduleWeekStrip(
                days: data.tuanTu(_thuHaiCuaTrang(trang)),
                ngayChon: _ngayDangChon,
                onSelect: (ngay) => setState(() => _ngayDangChon = ngay),
              ),
            ),
          ),
          const AppDongKe(),
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: () => ref
                  .read(sitterScheduleProvider.notifier)
                  .taiLai(_thuHaiCuaTrang(_trang), _chuNhatDangXem),
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
                        day: data.chiTietNgay(_ngayDangChon),
                        soCho: data.soChoConNhan(_ngayDangChon),
                        soChoToiDa: data.soChoToiDaCuaNgay(_ngayDangChon),
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
      ),
    );
  }
}
