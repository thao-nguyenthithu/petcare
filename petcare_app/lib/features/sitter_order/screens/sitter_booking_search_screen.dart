import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_card_map.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_orders_api_service.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_booking_filter.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';
import 'package:petcare_app/features/sitter_order/widgets/bookings/sitter_booking_filter_sheet.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/text_normalize.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';

// Một nhóm kết quả của cùng một tháng
typedef _NhomThang = ({DateTime moc, List<SitterBooking> dons});

// Màn Tra cứu đơn, lọc ngay trên dữ liệu đã tải nên không gọi API theo phím gõ
class SitterBookingSearchScreen extends ConsumerStatefulWidget {
  const SitterBookingSearchScreen({super.key});

  @override
  ConsumerState<SitterBookingSearchScreen> createState() =>
      _SitterBookingSearchScreenState();
}

// Tra cứu đi khắp lịch sử nên bộ lọc mặc định bỏ ràng buộc kỳ
const _macDinh = BoLocDon(ky: KyThongKe(LoaiKy.tatCa));

class _SitterBookingSearchScreenState
    extends ConsumerState<SitterBookingSearchScreen> {
  // Lấy tất cả đơn rồi lọc trên máy vì server chỉ nhận chip trạng thái
  List<SitterBooking> get _tatCa {
    final l10n = context.l10n;
    final trang = ref.watch(sitterBookingsProvider(ChipDonNcc.tatCa, null));
    return [
      for (final d in trang.value?.items ?? const []) cardDonNccTuApi(l10n, d),
    ];
  }

  final _tuKhoaController = TextEditingController();

  String _tuKhoa = '';
  BoLocDon _boLoc = _macDinh;

  @override
  void dispose() {
    _tuKhoaController.dispose();
    super.dispose();
  }

  List<SitterBooking> get _ketQua {
    final khoa = boDau(_tuKhoa.trim().toLowerCase());
    if (khoa.isEmpty) return const [];
    return _tatCa
        .where(_boLoc.nhan)
        .where((d) => boDau(d.chuoiTimKiem.toLowerCase()).contains(khoa))
        .toList()
      ..sort((a, b) => b.batDau.compareTo(a.batDau));
  }

  // Gom kết quả theo tháng, giữ nguyên thứ tự mới nhất trước
  List<_NhomThang> _nhomTheoThang(List<SitterBooking> dons) {
    final nhom = <_NhomThang>[];
    for (final d in dons) {
      final moc = DateTime(d.batDau.year, d.batDau.month);
      if (nhom.isNotEmpty && nhom.last.moc == moc) {
        nhom.last.dons.add(d);
      } else {
        nhom.add((moc: moc, dons: [d]));
      }
    }
    return nhom;
  }

  Future<void> _moSheetLoc() async {
    final moi = await moSheetLocDon(
      context,
      boLoc: _boLoc,
      macDinh: _macDinh,
      soDonMoiDichVu: {
        for (final dv in LoaiDichVu.values)
          dv: _tatCa
              .where((d) => d.dichVu == dv && _boLoc.ky.chua(d.batDau))
              .length,
      },
    );
    if (moi != null && mounted) setState(() => _boLoc = moi);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ketQua = _ketQua;
    final daGo = _tuKhoa.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.screenPadding,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.labelGap),
          child: AppSearchField(
            controller: _tuKhoaController,
            onChanged: (s) => setState(() => _tuKhoa = s),
            hintText: l10n.timDonHint,
            autofocus: true,
            height: 42,
            filterActive: _boLoc.lechVoi(_macDinh),
            onToggleFilter: _moSheetLoc,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: AppDongKe(),
        ),
      ),
      // Chắn phía đáy để thẻ cuối không chui xuống thanh điều hướng Android
      body: SafeArea(
        top: false,
        child: !daGo
            ? Center(
                child: AppEmptyState(
                  icon: Icons.manage_search_rounded,
                  title: l10n.traCuuDon,
                  message: l10n.nhapTuKhoaTimDon,
                  circleColor: AppColors.cardMint,
                ),
              )
            : ketQua.isEmpty
            ? Center(
                child: AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: l10n.khongTimThayDon,
                  message: l10n.thuTuKhoaKhac,
                  circleColor: AppColors.cardMint,
                ),
              )
            : _DanhSachKetQua(
                tuKhoa: _tuKhoa.trim(),
                soKetQua: ketQua.length,
                nhom: _nhomTheoThang(ketQua),
              ),
      ),
    );
  }
}

class _DanhSachKetQua extends StatelessWidget {
  const _DanhSachKetQua({
    required this.tuKhoa,
    required this.soKetQua,
    required this.nhom,
  });

  final String tuKhoa;
  final int soKetQua;
  final List<_NhomThang> nhom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.itemGap,
              AppSpacing.screenPadding,
              AppSpacing.labelGap,
            ),
            child: Text(
              l10n.soDonKhopTuKhoa('$soKetQua', tuKhoa),
              style: AppTextStyles.captionSm,
            ),
          ),
        ),
        for (final n in nhom) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.itemGap,
                AppSpacing.screenPadding,
                AppSpacing.labelGap,
              ),
              child: Text(
                l10n
                    .thangGachNam('${n.moc.month}', '${n.moc.year}')
                    .toUpperCase(),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            sliver: SliverList.separated(
              itemCount: n.dons.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.itemGap),
              itemBuilder: (context, i) => SitterBookingCard(
                booking: n.dons[i],
                onTap: () => moChiTietDonNcc(context, n.dons[i]),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.screenEdgeGap),
        ),
      ],
    );
  }
}
