import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_controller.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_finish_button.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/walk_return_distance.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/walk_route_scope.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/mo_chi_duong.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

const LatLng diemTraBeMacDinh = LatLng(21.0187, 105.8130);

// Đường về điểm trả bé
class SitterWalkReturnScreen extends StatelessWidget {
  const SitterWalkReturnScreen({super.key, required this.phien});

  final WalkingSession phien;

  @override
  Widget build(BuildContext context) {
    final viTri = phien.don.viTri ?? diemTraBeMacDinh;
    return WalkRouteScope(
      phien: phien,
      builder: (context, phien, duongDi) => Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _BanDoLoTrinh(
              diemTra: viTri,
              tenChuNuoi: phien.don.tenChuNuoi,
              duongDi: duongDi,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _Chip(phien: phien),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: WalkReturnDistance(
                phien: phien,
                builder: (context, phien) => _BangDuoi(phien: phien),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.phien});

  final WalkingSession phien;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.quayVeTraBeConNPhut('${phien.don.phutConLai ?? 0}'),
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }
}

class _BangDuoi extends StatelessWidget {
  const _BangDuoi({required this.phien});

  final WalkingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = phien.don;
    final diemTraBe = don.viTri ?? diemTraBeMacDinh;
    final noiTra = don.diaChiDayDu?.split(',').first ?? don.khuVucDiemDon;
    final met = phien.metConToiDiemTra;
    final dongKhoangCach = switch ((don.viTri, met)) {
      (null, _) => l10n.khongDoDuocViTri,
      (_, null) => l10n.dangXacDinhViTri,
      (_, final m?) => l10n.conCachNMet('$m'),
    };
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: don.tenChuNuoi,
                    imageUrl: don.avatarChuNuoi,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.veDiaChiDeTraBe(noiTra),
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 4),
                        Text(dongKhoangCach, style: AppTextStyles.captionSm),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _Cot(
                      so: met == null ? l10n.chuaDoDuoc : l10n.soMet('$met'),
                      nhan: l10n.conCach,
                    ),
                    const _Vach(),
                    _Cot(
                      so: l10n.nPhutNhan('${don.phutConLai ?? 0}'),
                      nhan: l10n.conLaiNhan,
                    ),
                    const _Vach(),
                    _Cot(so: l10n.soKm(soLeKm(phien.kmDaDi)), nhan: l10n.daDi),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SessionFinishButton(
                phien: phien,
                truocKhiMo: phien.bookingId == null
                    ? null
                    : WalkTrackingController.dungPhien,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => moChiDuong(context, diemTraBe),
                icon: const Icon(Icons.navigation_outlined, size: 18),
                label: Text(l10n.chiDuongVeDiemTraBe),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.nutKetThucBatKhiVaoTrongNMet('$metGeofence'),
                      style: AppTextStyles.captionSm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cot extends StatelessWidget {
  const _Cot({required this.so, required this.nhan});

  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            so,
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 3),
          Text(nhan, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}

class _Vach extends StatelessWidget {
  const _Vach();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: AppColors.neutralLight);
}

// Bản đồ lộ trình, khung nhìn bám theo điểm mới vì lịch sử nạp sau khi dựng
class _BanDoLoTrinh extends StatefulWidget {
  const _BanDoLoTrinh({
    required this.diemTra,
    required this.tenChuNuoi,
    required this.duongDi,
  });

  final LatLng diemTra;
  final String tenChuNuoi;
  final List<LatLng> duongDi;

  @override
  State<_BanDoLoTrinh> createState() => _BanDoLoTrinhState();
}

class _BanDoLoTrinhState extends State<_BanDoLoTrinh> {
  final _dieuKhien = MapController();

  @override
  void dispose() {
    _dieuKhien.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_BanDoLoTrinh cu) {
    super.didUpdateWidget(cu);
    final diem = widget.duongDi.lastOrNull;
    if (diem == null || diem == cu.duongDi.lastOrNull) return;
    try {
      _dieuKhien.move(diem, _dieuKhien.camera.zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final duongDi = widget.duongDi;
    return FlutterMap(
      mapController: _dieuKhien,
      options: MapOptions(
        initialCenter: duongDi.lastOrNull ?? widget.diemTra,
        initialZoom: 16,
      ),
      children: [
        osmTileLayer(),
        if (duongDi.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: duongDi,
                strokeWidth: 4,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: widget.diemTra,
              width: 50,
              height: 50,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                padding: const EdgeInsets.all(3),
                child: UserAvatar(name: widget.tenChuNuoi, size: 44),
              ),
            ),
            if (duongDi.isNotEmpty)
              Marker(
                point: duongDi.last,
                width: 34,
                height: 34,
                child: const _ChamViTri(),
              ),
          ],
        ),
      ],
    );
  }
}

// Chấm vị trí hiện tại của người chăm trên lộ trình
class _ChamViTri extends StatelessWidget {
  const _ChamViTri();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 3),
      ),
    );
  }
}
