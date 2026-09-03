import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_controller.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_task.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_action_grid.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_finish_button.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/walk_return_distance.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/walk_route_scope.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn tác nghiệp lúc đang dắt, cũng là nơi bật service GPS
class SitterWalkingSessionScreen extends StatefulWidget {
  const SitterWalkingSessionScreen({super.key, required this.phien});

  final WalkingSession phien;

  @override
  State<SitterWalkingSessionScreen> createState() =>
      _SitterWalkingSessionScreenState();
}

class _SitterWalkingSessionScreenState extends State<SitterWalkingSessionScreen>
    with WidgetsBindingObserver {
  bool _dangBatTheoDoi = false;

  String? get _bookingId => widget.phien.bookingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_bookingId != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_damBaoTheoDoi()),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _bookingId == null) return;
    unawaited(_batLaiSauKhiVeApp());
  }

  // Vào phiên là bật thẳng, chỉ hộp thoại quyền của hệ thống chứ không thêm sheet nào
  Future<void> _damBaoTheoDoi() async {
    final bookingId = _bookingId;
    if (bookingId == null || _dangBatTheoDoi) return;
    _dangBatTheoDoi = true;
    try {
      if (await WalkTrackingController.dangChay()) return;
      if (!await WalkTrackingController.coQuyenThongBao()) {
        await WalkTrackingController.xinQuyenThongBao();
      }
      var quyen = await WalkTrackingController.quyenViTri();
      if (quyen == LocationPermission.denied) {
        quyen = await WalkTrackingController.xinQuyenViTri();
      }
      if (quyen == LocationPermission.denied ||
          quyen == LocationPermission.deniedForever) {
        if (mounted) _baoLoi(context.l10n.chuNuoiKhongThayViTri);
        return;
      }
      await _batService(bookingId);
    } finally {
      _dangBatTheoDoi = false;
    }
  }

  Future<void> _batLaiSauKhiVeApp() async {
    final bookingId = _bookingId;
    if (bookingId == null || await WalkTrackingController.dangChay()) return;
    await _batService(bookingId);
  }

  Future<void> _batService(String bookingId) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final loi = await WalkTrackingController.batDau(
      bookingId: bookingId,
      tieuDeThongBao: l10n.thongBaoDangChiaSe,
      noiDungThongBao: l10n.thongBaoChiaSeDon(widget.phien.don.maDon),
      tenKenhThongBao: l10n.kenhThongBaoChiaSeViTri,
    );
    // Nêu luôn lý do máy chủ Android từ chối, nếu không thì lần nào cũng chỉ biết là hỏng
    if (loi != null && mounted) _baoLoi('${l10n.khongTheBatChiaSe} · $loi');
  }

  Future<void> _truocKhiKetThuc() => WalkTrackingController.dungPhien();

  void _baoLoi(String thongBao) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(thongBao)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phien = widget.phien;
    final don = phien.don;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: _ThanhTieuDe(phien: phien),
      body: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [
          _KhoiBamGps(phien: phien),
          const SizedBox(height: 12),
          FlatSection(child: SessionActionGrid(bookingId: don.bookingId)),
          const SizedBox(height: 12),
          FlatSection(
            child: AppButton(
              text: l10n.chiDuongVeDiemTraBe,
              icon: Icons.route_outlined,
              outlined: true,
              height: 51,
              onTap: () =>
                  context.push(AppRoutes.sitterWalkReturnPath(don.bookingId)),
            ),
          ),
          const SizedBox(height: 12),
          FlatSection(
            child: _HangChiTietDon(
              onTap: () =>
                  context.push(AppRoutes.sitterOrderDetailPath(don.bookingId)),
            ),
          ),
        ],
      ),
      bottomBar: _ThanhDuoi(
        phien: phien,
        truocKhiKetThuc: _bookingId == null ? null : _truocKhiKetThuc,
      ),
    );
  }
}

class _ThanhTieuDe extends StatelessWidget {
  const _ThanhTieuDe({required this.phien});

  final WalkingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = phien.don;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
          child: Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.dangDat, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      l10n.maDonSoBe(don.maDon, '${don.pets.length}'),
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.dangDienRa,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const AppDongKe(),
      ],
    );
  }
}

class _KhoiBamGps extends StatefulWidget {
  const _KhoiBamGps({required this.phien});

  final WalkingSession phien;

  @override
  State<_KhoiBamGps> createState() => _KhoiBamGpsState();
}

class _KhoiBamGpsState extends State<_KhoiBamGps> {
  LatLng? _viTriGps;

  @override
  void initState() {
    super.initState();
    WalkTrackingController.ngheDuLieu(_nhanDuLieu);
  }

  @override
  void dispose() {
    WalkTrackingController.thoiNghe(_nhanDuLieu);
    super.dispose();
  }

  void _nhanDuLieu(Object data) {
    if (data is! Map) return;
    switch (data['loai']) {
      case gpsGoiViTri:
        final lat = data['lat'];
        final lng = data['lng'];
        if (lat is! num || lng is! num) return;
        setState(() => _viTriGps = LatLng(lat.toDouble(), lng.toDouble()));
      case gpsGoiLoi:
        final thongBao = switch (data['code']) {
          'GPS_BI_TAT' => context.l10n.dinhViDangTat,
          'MAT_QUYEN_GHI_LO_TRINH' => context.l10n.matQuyenChiaSeViTri,
          _ => null,
        };
        if (thongBao != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(thongBao)));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return WalkRouteScope(
      phien: widget.phien,
      builder: (context, phien, duongDi) => Column(
        children: [
          FlatSection(
            child: MapPreview(
              viTri:
                  _viTriGps ??
                  duongDi.lastOrNull ??
                  phien.don.viTri ??
                  const LatLng(21.0187, 105.8130),
              icon: Icons.route_outlined,
              duongDi: duongDi,
              nhan: l10n.banDoRealtimeLoTrinh(
                l10n.soKm(soLeKm(phien.kmLoTrinh)),
              ),
              onDoi: () => context.push(
                AppRoutes.sitterWalkReturnPath(phien.don.bookingId),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FlatSection(child: _LuoiSoLieu(phien: phien)),
        ],
      ),
    );
  }
}

// Ba thẻ số liệu của phiên
class _LuoiSoLieu extends StatelessWidget {
  const _LuoiSoLieu({required this.phien});

  final WalkingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _The(
            icon: Icons.route_outlined,
            so: l10n.soKm(soLeKm(phien.kmDaDi)),
            nhan: l10n.quangDuong,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _The(
            icon: Icons.schedule_outlined,
            so: phien.conLai,
            nhan: l10n.conLaiNhan,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _The(
            icon: Icons.photo_camera_outlined,
            so: '${phien.soAnhDaGui}',
            nhan: l10n.anhGui,
          ),
        ),
      ],
    );
  }
}

class _The extends StatelessWidget {
  const _The({required this.icon, required this.so, required this.nhan});

  final IconData icon;
  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryColor),
          const SizedBox(height: 6),
          Text(so, style: AppTextStyles.h3),
          const SizedBox(height: 2),
          Text(nhan, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}

// Lối quay lại màn chi tiết đơn
class _HangChiTietDon extends StatelessWidget {
  const _HangChiTietDon({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(l10n.xemChiTietDon, style: AppTextStyles.h3)),
            const SizedBox(width: 10),
            Text(l10n.beGhiChuTien, style: AppTextStyles.captionSm),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Thanh đáy chỉ một việc: kết thúc khi đã đủ điều kiện
class _ThanhDuoi extends StatelessWidget {
  const _ThanhDuoi({required this.phien, this.truocKhiKetThuc});

  final WalkingSession phien;
  final Future<void> Function()? truocKhiKetThuc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
          child: WalkReturnDistance(
            phien: phien,
            builder: (context, phien) =>
                SessionFinishButton(phien: phien, truocKhiMo: truocKhiKetThuc),
          ),
        ),
      ),
    );
  }
}
