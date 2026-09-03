import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/don_hien_hanh.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/services/gps_api_service.dart';
import 'package:petcare_app/shared/services/gps_socket_service.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Màn theo dõi trực tiếp vị trí người chăm khi đơn đang diễn ra
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key, required this.banChup});

  final OwnerBookingDetail banChup;

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  bool _dangKetNoi = false;

  @override
  Widget build(BuildContext context) {
    final don = donHienHanh(context, ref, widget.banChup);
    final phien = don.phien;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _BanDoLoTrinh(
            bookingId: widget.banChup.id,
            tenNcc: don.tenNcc,
            avatarNcc: don.avatarNcc,
            viTriDuPhong: don.viTri,
            onKetNoi: (noi) {
              if (mounted) setState(() => _dangKetNoi = noi);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      if (phien != null) _ChipTrangThai(phien: phien),
                    ],
                  ),
                  if (!_dangKetNoi) ...[
                    const SizedBox(height: 8),
                    const _ChipKetNoiLai(),
                  ],
                ],
              ),
            ),
          ),
          if (phien != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: _BangDuoi(don: don, phien: phien),
            ),
        ],
      ),
    );
  }
}

// Bản đồ và lộ trình, nghe socket ở đây nên mỗi điểm không dựng lại cả màn
class _BanDoLoTrinh extends StatefulWidget {
  const _BanDoLoTrinh({
    required this.bookingId,
    required this.tenNcc,
    required this.avatarNcc,
    required this.viTriDuPhong,
    required this.onKetNoi,
  });

  final String bookingId;
  final String tenNcc;
  final String? avatarNcc;
  final LatLng? viTriDuPhong;

  final ValueChanged<bool> onKetNoi;

  @override
  State<_BanDoLoTrinh> createState() => _BanDoLoTrinhState();
}

class _BanDoLoTrinhState extends State<_BanDoLoTrinh> {
  final _mapController = MapController();
  GpsSocketService? _socket;
  StreamSubscription<GpsDiem>? _subViTri;
  StreamSubscription<bool>? _subKetNoi;
  final List<LatLng> _duongDi = [];
  LatLng? _viTriNcc;

  @override
  void initState() {
    super.initState();
    unawaited(_khoiDong());
  }

  @override
  void dispose() {
    _subViTri?.cancel();
    _subKetNoi?.cancel();
    _socket?.dong();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _khoiDong() async {
    try {
      final lichSu = await GpsApiService().lichSuLoTrinh(widget.bookingId);
      if (mounted && lichSu.isNotEmpty) {
        setState(() {
          _duongDi.addAll(lichSu);
          _viTriNcc = lichSu.last;
        });
        _doiKhungNhin(lichSu.last);
      }
    } catch (_) {}
    final token = await TokenStorageService().getAccessToken();
    if (token == null || token.isEmpty || !mounted) return;
    final socket = GpsSocketService(serverGoc: serverGoc, token: token);
    _socket = socket;
    _subViTri = socket.viTriMoi.listen(_nhanDiem);
    _subKetNoi = socket.dangKetNoi.listen((noi) {
      if (mounted) widget.onKetNoi(noi);
    });
    socket.ketNoi(bookingId: widget.bookingId);
  }

  void _nhanDiem(GpsDiem diem) {
    if (!mounted) return;
    setState(() {
      _viTriNcc = diem.viTri;
      if (_duongDi.isEmpty || _duongDi.last != diem.viTri) {
        _duongDi.add(diem.viTri);
      }
    });
    _doiKhungNhin(diem.viTri);
  }

  void _doiKhungNhin(LatLng viTri) {
    try {
      _mapController.move(viTri, _mapController.camera.zoom);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final viTri =
        _viTriNcc ?? widget.viTriDuPhong ?? const LatLng(21.0187, 105.8130);
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: viTri, initialZoom: 15),
      children: [
        osmTileLayer(),
        if (_duongDi.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _duongDi,
                strokeWidth: 4,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: viTri,
              width: 48,
              height: 48,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                ),
                padding: const EdgeInsets.all(2),
                child: UserAvatar(
                  name: widget.tenNcc,
                  imageUrl: widget.avatarNcc,
                  size: 44,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChipTrangThai extends StatelessWidget {
  const _ChipTrangThai({required this.phien});

  final PhienDangChay phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            '${l10n.dangDienRaNhan} · ${l10n.conNPhut('${phien.phutConLai}')}',
            style: AppTextStyles.label,
          ),
        ],
      ),
    );
  }
}

class _ChipKetNoiLai extends StatelessWidget {
  const _ChipKetNoiLai();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(context.l10n.dangKetNoiLai, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}

class _BangDuoi extends StatelessWidget {
  const _BangDuoi({required this.don, required this.phien});

  final OwnerBookingDetail don;
  final PhienDangChay phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  UserAvatar(
                    name: don.tenNcc,
                    imageUrl: don.avatarNcc,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.nccDangLamViecVoiNBe(
                            don.tenNcc,
                            _viecDangLam(context, don.loai),
                            '${don.pets.length}',
                          ),
                          style: AppTextStyles.label,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.viTriCapNhatMoiNGiay('${phien.giayCapNhat}'),
                          style: AppTextStyles.captionSm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _Cot(so: l10n.soKm(soLeKm(phien.kmDaDi)), nhan: l10n.daDi),
                    const _Vach(),
                    _Cot(
                      so: l10n.nPhutNhan('${phien.phutConLai}'),
                      nhan: l10n.conLaiNhan,
                    ),
                    const _Vach(),
                    _Cot(so: phien.gioBatDau, nhan: l10n.batDau),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                text: l10n.nhanChoNguoiCham,
                onTap: () => moChatCuaDon(context, don.id, laChuNuoi: true),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.ghiChuBanDoChiKhiDangDienRa,
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

String _viecDangLam(BuildContext context, ServiceType loai) {
  final l10n = context.l10n;
  return switch (loai) {
    ServiceType.walking => l10n.datDiDao.toLowerCase(),
    ServiceType.boarding => l10n.trongGiu.toLowerCase(),
    ServiceType.grooming => l10n.tamVaCatTia.toLowerCase(),
  };
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
