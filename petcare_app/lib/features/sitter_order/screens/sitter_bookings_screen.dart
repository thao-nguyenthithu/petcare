import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_card_map.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_orders_api_service.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_booking_filter.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';
import 'package:petcare_app/features/sitter_order/widgets/bookings/sitter_booking_filter_sheet.dart';
import 'package:petcare_app/features/sitter_order/widgets/bookings/sitter_booking_period_sheet.dart';
import 'package:petcare_app/features/sitter_order/widgets/bookings/sitter_booking_status_chips.dart';
import 'package:petcare_app/features/sitter_order/widgets/bookings/sitter_bookings_header.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn Tất cả đơn của người chăm
class SitterBookingsScreen extends ConsumerStatefulWidget {
  const SitterBookingsScreen({super.key, this.chipBanDau});

  final SitterBookingStatus? chipBanDau;

  @override
  ConsumerState<SitterBookingsScreen> createState() =>
      _SitterBookingsScreenState();
}

const _macDinh = BoLocDon();

class _SitterBookingsScreenState extends ConsumerState<SitterBookingsScreen> {
  List<SitterBooking> get _tatCa {
    final l10n = context.l10n;
    final trang = ref.watch(sitterBookingsProvider(ChipDonNcc.tatCa, null));
    return [
      for (final d in trang.value?.items ?? const []) cardDonNccTuApi(l10n, d),
    ];
  }

  BoLocDon _boLoc = _macDinh;
  late SitterBookingStatus? _trangThai = widget.chipBanDau;

  List<SitterBooking> get _trongKy =>
      _tatCa.where((d) => _boLoc.ky.chua(d.batDau)).toList();

  List<SitterBooking> get _quaBoLoc =>
      _tatCa.where(_boLoc.nhan).toList()..sort(_uuTien);

  int _uuTien(SitterBooking a, SitterBooking b) {
    final lech = a.trangThai.index.compareTo(b.trangThai.index);
    if (lech != 0) return lech;
    if (a.trangThai == SitterBookingStatus.choXacNhan) {
      final conA = a.phutConLai ?? 1 << 30;
      final conB = b.phutConLai ?? 1 << 30;
      if (conA != conB) return conA.compareTo(conB);
    }
    return b.batDau.compareTo(a.batDau);
  }

  Future<void> _moSheetLoc() async {
    final trongKy = _trongKy;
    final moi = await moSheetLocDon(
      context,
      boLoc: _boLoc,
      macDinh: _macDinh,
      soDonMoiDichVu: {
        for (final dv in LoaiDichVu.values)
          dv: trongKy.where((d) => d.dichVu == dv).length,
      },
    );
    if (moi != null && mounted) setState(() => _boLoc = moi);
  }

  Future<void> _moSheetChonKy() async {
    final namNay = homNayVn().year;
    final nam = _tatCa.map((d) => d.batDau.year).toList()..sort();
    final moi = await moSheetChonKy(
      context,
      ky: _boLoc.ky,
      ngayCoDon: {for (final d in _tatCa) chiNgay(d.batDau)},
      namDau: nam.isEmpty ? namNay : nam.first,
      namCuoi: nam.isEmpty || nam.last < namNay ? namNay : nam.last,
    );
    if (moi != null && mounted) {
      setState(() => _boLoc = _boLoc.copyWith(ky: moi));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quaBoLoc = _quaBoLoc;
    final hienThi = _trangThai == null
        ? quaBoLoc
        : quaBoLoc.where((d) => d.trangThai == _trangThai).toList();

    return AppScreen(
      headerTuLoDinh: true,
      header: Column(
        children: [
          SitterBookingsHeader(
            nhanKy: _boLoc.ky.nhanTomTat(l10n),
            soDon: quaBoLoc.length,
            tongThucNhan: quaBoLoc
                .where((d) => d.thucNhan)
                .fold(0, (tong, d) => tong + d.soTien),
            dangLoc: _boLoc.lechVoi(_macDinh),
            onBack: () => context.pop(),
            onTimKiem: () => context.push(AppRoutes.sitterBookingSearch),
            onMoLoc: _moSheetLoc,
            onChonKy: _moSheetChonKy,
          ),
          SitterBookingStatusChips(
            dangChon: _trangThai,
            dem: {
              for (final tt in SitterBookingStatus.values)
                tt: quaBoLoc.where((d) => d.trangThai == tt).length,
            },
            onChon: (tt) => setState(() => _trangThai = tt),
          ),
        ],
      ),
      body: hienThi.isEmpty
          ? Center(
              child: AppEmptyState(
                icon: Icons.inbox_outlined,
                title: l10n.chuaCoDonNao,
                message: l10n.chuaCoDonLoc,
                circleColor: AppColors.cardMint,
              ),
            )
          : AppRefreshIndicator(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  0,
                  AppSpacing.screenPadding,
                  AppSpacing.screenEdgeGap,
                ),
                itemCount: hienThi.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.itemGap),
                itemBuilder: (context, i) => SitterBookingCard(
                  booking: hienThi[i],
                  onTap: () => moChiTietDonNcc(context, hienThi[i]),
                ),
              ),
            ),
    );
  }
}
