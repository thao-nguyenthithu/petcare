import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/features/address/services/tra_cuu_dia_chi_service.dart';
import 'package:petcare_app/features/address/widgets/location_permission_sheet.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn chọn vị trí pin cố định giữa màn, kéo bản đồ để đặt điểm, có ô tìm kiếm.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initialCenter});

  final LatLng? initialCenter;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  static const LatLng _macDinh = LatLng(21.028511, 105.804817);
  static const double _zoom = 16;
  late LatLng _center = widget.initialCenter ?? _macDinh;
  bool _dangDinhVi = false;

  PhanTichDiaChi? _diaChi;
  bool _dangTimDiaChi = false;
  Timer? _debounceDiaChi;

  final TextEditingController _timController = TextEditingController();
  List<GoiYDiaDiem> _goiY = const [];
  bool _dangTimKiem = false;
  Timer? _debounceTim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialCenter != null) {
        _traDiaChi();
      } else {
        _veViTriHienTai();
      }
    });
  }

  @override
  void dispose() {
    _debounceDiaChi?.cancel();
    _debounceTim?.cancel();
    _timController.dispose();
    super.dispose();
  }

  Future<void> _veViTriHienTai({bool xinQuyen = false}) async {
    setState(() => _dangDinhVi = true);
    try {
      if (xinQuyen) {
        final kq = await xinQuyenViTri();
        if (!mounted || kq != KetQuaQuyenViTri.daCap) return;
      } else {
        final quyen = await Geolocator.checkPermission();
        if (quyen != LocationPermission.always &&
            quyen != LocationPermission.whileInUse) {
          return;
        }
      }
      final viTri = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      _mapController.move(LatLng(viTri.latitude, viTri.longitude), _zoom);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _dangDinhVi = false);
    }
  }

  // Kéo bản đồ đổi tâm chờ dừng rồi mới tra địa chỉ
  void _khiDoiTam(LatLng tam) {
    setState(() => _center = tam);
    _debounceDiaChi?.cancel();
    _debounceDiaChi = Timer(const Duration(milliseconds: 700), _traDiaChi);
  }

  Future<void> _traDiaChi() async {
    setState(() => _dangTimDiaChi = true);
    final kq = await TraCuuDiaChiService.traDiaChi(
      _center.latitude,
      _center.longitude,
    );
    if (!mounted) return;
    setState(() {
      _diaChi = kq;
      _dangTimDiaChi = false;
    });
  }

  void _lenLichTimKiem(String tuKhoa) {
    _debounceTim?.cancel();
    if (tuKhoa.trim().isEmpty) {
      setState(() => _goiY = const []);
      return;
    }
    _debounceTim = Timer(
      const Duration(milliseconds: 500),
      () => _timKiem(tuKhoa),
    );
  }

  Future<void> _timKiem(String tuKhoa) async {
    setState(() => _dangTimKiem = true);
    final kq = await TraCuuDiaChiService.timDiaDiem(tuKhoa);
    if (!mounted) return;
    setState(() {
      _goiY = kq;
      _dangTimKiem = false;
    });
  }

  void _chonGoiY(GoiYDiaDiem goiY) {
    FocusScope.of(context).unfocus();
    _timController.clear();
    setState(() => _goiY = const []);
    _mapController.move(goiY.viTri, _zoom);
  }

  void _xacNhan() {
    context.pop(
      KetQuaViTri(
        viTri: _center,
        moTa: _diaChi?.moTa,
        soNhaDuong: _diaChi?.soNhaDuong,
        phuong: _diaChi?.phuong,
        tinh: _diaChi?.tinh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScreen(
      header: AppScreenHeader(title: l10n.chonViTri),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              onPositionChanged: (camera, _) => _khiDoiTam(camera.center),
            ),
            children: [
              voyagerTileLayer(),
              const RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution('© OpenStreetMap, © CARTO'),
                ],
              ),
            ],
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_on,
                size: 44,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Positioned(
            top: AppSpacing.itemGap,
            left: AppSpacing.screenPadding,
            right: AppSpacing.screenPadding,
            child: _OTimKiem(
              controller: _timController,
              hint: l10n.timDiaDiem,
              dangTim: _dangTimKiem,
              goiY: _goiY,
              onDoi: _lenLichTimKiem,
              onChon: _chonGoiY,
            ),
          ),
          Positioned(
            right: AppSpacing.screenPadding,
            bottom: AppSpacing.screenPadding,
            child: FloatingActionButton.small(
              heroTag: 'viTriHienTai',
              onPressed: _dangDinhVi
                  ? null
                  : () => _veViTriHienTai(xinQuyen: true),
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.primaryColor,
              child: _dangDinhVi
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
      bottomBar: _ThanhXacNhan(
        diaChi: _diaChi?.moTa,
        dangTim: _dangTimDiaChi,
        onXacNhan: _xacNhan,
      ),
    );
  }
}

// Ô tìm kiếm + danh sách gợi ý
class _OTimKiem extends StatelessWidget {
  const _OTimKiem({
    required this.controller,
    required this.hint,
    required this.dangTim,
    required this.goiY,
    required this.onDoi,
    required this.onChon,
  });

  final TextEditingController controller;
  final String hint;
  final bool dangTim;
  final List<GoiYDiaDiem> goiY;
  final ValueChanged<String> onDoi;
  final ValueChanged<GoiYDiaDiem> onChon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.surface,
          elevation: 3,
          shadowColor: AppColors.shadow,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: TextField(
            controller: controller,
            onChanged: onDoi,
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: dangTim
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              controller.clear();
                              onDoi('');
                            },
                          )
                        : null),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (goiY.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.labelGap),
          Material(
            color: AppColors.surface,
            elevation: 3,
            shadowColor: AppColors.shadow,
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: goiY.length,
                separatorBuilder: (_, _) => const AppDongKe(),
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  title: Text(
                    goiY[i].ten,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  onTap: () => onChon(goiY[i]),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Thanh dưới hiện tên địa chỉ đang chọn, nút xác nhận
class _ThanhXacNhan extends StatelessWidget {
  const _ThanhXacNhan({
    required this.diaChi,
    required this.dangTim,
    required this.onXacNhan,
  });

  final String? diaChi;
  final bool dangTim;
  final VoidCallback onXacNhan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final noiDung = dangTim
        ? l10n.dangTimDiaChi
        : (diaChi ?? l10n.khongXacDinhDiaChi);
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      // Màn có thanh đáy thì thanh đáy tự chừa (rule-flutter mục 6)
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: AppSpacing.labelGap),
                Expanded(
                  child: Text(
                    noiDung,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.itemGap),
            AppButton(text: l10n.xacNhanViTri, onTap: onXacNhan),
          ],
        ),
      ),
    );
  }
}
