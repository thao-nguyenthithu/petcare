import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/features/address/services/tra_cuu_dia_chi_service.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/features/search/providers/search_results_provider.dart';
import 'package:petcare_app/features/search/data/noi_tim_quanh.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/features/search/widgets/date_range_sheet.dart';
import 'package:petcare_app/features/search/widgets/map_condition_panel.dart';
import 'package:petcare_app/features/search/widgets/map_notice_banners.dart';
import 'package:petcare_app/features/search/widgets/map_pins.dart';
import 'package:petcare_app/features/search/widgets/map_place_sheet.dart';
import 'package:petcare_app/features/search/widgets/map_sitter_strip.dart';
import 'package:petcare_app/features/search/widgets/map_top_bar.dart';
import 'package:petcare_app/shared/widgets/map_tiles.dart';

// Vào từ nút Bản đồ ở màn kết quả, mang theo bộ lọc đang áp
class SearchMapScreen extends ConsumerStatefulWidget {
  const SearchMapScreen({super.key, required this.boLoc});

  final BoLocTimKiem boLoc;

  @override
  ConsumerState<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends ConsumerState<SearchMapScreen> {
  static const double _zoom = 13;

  final MapController _mapController = MapController();

  late BoLocTimKiem _boLoc = widget.boLoc;
  NoiTimQuanh? _noiTim;
  bool _moPanel = true;
  bool _daKeoBanDo = false;
  bool _tuChoiQuyenViTri = false;
  int _chiSoDangXem = 0;

  LatLng? _ghimTam;
  bool _dangTraDiaChi = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _dungDiaChiMacDinh());
  }

  void _dungDiaChiMacDinh() {
    final ds = ref.read(savedAddressesProvider).asData?.value ?? const [];
    if (ds.isEmpty) return;
    final macDinh = ds.firstWhere((e) => e.isDefault, orElse: () => ds.first);
    if (macDinh.lat == null || macDinh.lng == null) return;
    setState(() {
      _noiTim = NoiTimQuanh(
        nguon: NguonNoiTim.diaChiLuu,
        viTri: LatLng(macDinh.lat!, macDinh.lng!),
        moTa: [
          macDinh.soNha,
          macDinh.phuongXa,
        ].where((e) => e.isNotEmpty).join(', '),
        moTaPhu: context.l10n.diaChiMacDinhCuaBan,
        idDiaChi: macDinh.id,
      );
    });
    _mapController.move(_noiTim!.viTri, _zoom);
  }

  double _khoangCachKm(SitterResult p) {
    if (p.khoangCachKm != null) return p.khoangCachKm!;
    final tam = _noiTim?.viTri;
    final cho = p.viTri;
    if (tam == null || cho == null) return 0;
    return const Distance().as(LengthUnit.Kilometer, tam, cho);
  }

  YeuCauTim get _yeuCau => YeuCauTim(
    boLoc: _boLoc,
    lat: _noiTim?.viTri.latitude,
    lng: _noiTim?.viTri.longitude,
  );

  Future<void> _chonNoiTim() async {
    FocusScope.of(context).unfocus();
    final diaChi = ref.read(savedAddressesProvider).asData?.value ?? const [];
    final chon = await showMapPlaceSheet(
      context: context,
      diaChiDaLuu: diaChi,
      idDangChon: _noiTim?.idDiaChi,
    );
    if (chon == null || !mounted) return;
    if (chon.noiTim != null) {
      _datNoiTim(chon.noiTim!);
      return;
    }
    switch (chon.hanhDong!) {
      case ChonNoiTim.viTriHienTai:
        await _dungViTriHienTai();
      case ChonNoiTim.ghimTrenBanDo:
        await _ghimTrenBanDo();
      case ChonNoiTim.themDiaChiMoi:
        await context.push(AppRoutes.addAddress);
    }
  }

  void _datNoiTim(NoiTimQuanh noi) {
    setState(() {
      _noiTim = noi;
      _daKeoBanDo = false;
    });
    _mapController.move(noi.viTri, _zoom);
  }

  Future<void> _dungViTriHienTai() async {
    final quyen = await Geolocator.checkPermission();
    var duocPhep =
        quyen == LocationPermission.always ||
        quyen == LocationPermission.whileInUse;
    if (!duocPhep) {
      final xin = await Geolocator.requestPermission();
      duocPhep =
          xin == LocationPermission.always ||
          xin == LocationPermission.whileInUse;
    }
    if (!mounted) return;
    if (!duocPhep) {
      setState(() => _tuChoiQuyenViTri = true);
      return;
    }
    final vt = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() => _tuChoiQuyenViTri = false);
    _datNoiTim(
      NoiTimQuanh(
        nguon: NguonNoiTim.viTriHienTai,
        viTri: LatLng(vt.latitude, vt.longitude),
        moTa: context.l10n.viTriHienTai,
        moTaPhu: context.l10n.khongPhaiDiaChiDaLuu,
      ),
    );
  }

  Future<void> _ghimTrenBanDo() async {
    final ketQua = await context.push<KetQuaViTri>(
      AppRoutes.locationPicker,
      extra: _noiTim?.viTri,
    );
    if (ketQua == null || !mounted) return;
    _datNoiTim(
      NoiTimQuanh(
        nguon: NguonNoiTim.ghimTrenBanDo,
        viTri: ketQua.viTri,
        moTa: ketQua.soNhaDuong ?? ketQua.moTa ?? context.l10n.chonTrenBanDo,
        moTaPhu: [
          ketQua.phuong,
          ketQua.tinh,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', '),
      ),
    );
  }

  Future<void> _chonNgay() async {
    final ketQua = await showDateRangeSheet(
      context: context,
      banDau: KhoangNgay(tu: _boLoc.tuNgay, den: _boLoc.denNgay),
    );
    if (ketQua == null || !mounted) return;
    setState(
      () => _boLoc = _boLoc.copyWith(tuNgay: ketQua.tu, denNgay: ketQua.den),
    );
  }

  // Kéo bản đồ đi chỗ khác thì kết quả cũ không còn đúng vùng đang nhìn
  void _khiKeoBanDo(MapCamera camera, bool hetKeo) {
    if (!hetKeo || _daKeoBanDo) return;
    if (_noiTim == null || camera.center != _noiTim!.viTri) {
      setState(() => _daKeoBanDo = true);
    }
  }

  void _xemNguoiCham(int chiSo, List<SitterResult> ketQua) {
    if (chiSo < 0 || chiSo >= ketQua.length) return;
    setState(() => _chiSoDangXem = chiSo);
    final cho = ketQua[chiSo].viTri;
    if (cho != null) _mapController.move(cho, _mapController.camera.zoom);
  }

  void _chamBanDo(LatLng diem) {
    setState(() {
      _ghimTam = diem;
      _daKeoBanDo = true;
    });
  }

  Future<void> _timTrongVungNay() async {
    final diem = _ghimTam ?? _mapController.camera.center;
    if (_ghimTam == null) {
      setState(() {
        _noiTim = NoiTimQuanh(nguon: NguonNoiTim.vungDangXem, viTri: diem);
        _daKeoBanDo = false;
      });
      return;
    }
    setState(() => _dangTraDiaChi = true);
    final diaChi = await TraCuuDiaChiService.traDiaChi(
      diem.latitude,
      diem.longitude,
    );
    if (!mounted) return;
    setState(() {
      _dangTraDiaChi = false;
      _ghimTam = null;
      _daKeoBanDo = false;
      _noiTim = NoiTimQuanh(
        nguon: NguonNoiTim.ghimTrenBanDo,
        viTri: diem,
        moTa: diaChi?.soNhaDuong ?? diaChi?.moTa ?? context.l10n.chonTrenBanDo,
        moTaPhu: [
          diaChi?.phuong,
          diaChi?.tinh,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', '),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final danhSachBe = ref.watch(myPetsProvider).asData?.value ?? const <Pet>[];
    final ketQua =
        ref.watch(ketQuaTimProvider(_yeuCau)).asData?.value.items ??
        const <SitterResult>[];
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _noiTim?.viTri ?? NoiTimQuanh.macDinh,
              initialZoom: _zoom,
              onPositionChanged: _khiKeoBanDo,
              onTap: (_, diem) => _chamBanDo(diem),
            ),
            children: [
              osmTileLayer(),
              if (_noiTim != null &&
                  !_noiTim!.laVungDangXem &&
                  _boLoc.dichVu == MucLocDichVu.trongGiu)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _noiTim!.viTri,
                      radius: _boLoc.banKinhKm * 1000,
                      useRadiusInMeter: true,
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderColor: AppColors.primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
              if (_ghimTam != null ||
                  (_noiTim != null && !_noiTim!.laVungDangXem))
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _ghimTam ?? _noiTim!.viTri,
                      width: 44,
                      height: 52,
                      alignment: Alignment.topCenter,
                      child: MapCenterPin(
                        nguon: _ghimTam != null
                            ? NguonNoiTim.ghimTrenBanDo
                            : _noiTim!.nguon,
                        moNhat: _ghimTam != null,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  for (var i = 0; i < ketQua.length; i++)
                    if (ketQua[i].viTri != null)
                      Marker(
                        point: ketQua[i].viTri!,
                        width: 64,
                        height: 34,
                        child: MapPricePin(
                          gia: ketQua[i].gia ?? 0,
                          dangXem: i == _chiSoDangXem,
                          onTap: () => _xemNguoiCham(i, ketQua),
                        ),
                      ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                MapTopBar(
                  moTa: _moTaDieuKien(l10n),
                  moPanel: _moPanel,
                  onDoiPanel: () => setState(() => _moPanel = !_moPanel),
                ),
                if (_moPanel)
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPadding,
                        AppSpacing.labelGap,
                        AppSpacing.screenPadding,
                        0,
                      ),
                      child: MapConditionPanel(
                        noiTim: _noiTim,
                        boLoc: _boLoc,
                        danhSachBe: danhSachBe,
                        onDoiNoiTim: _chonNoiTim,
                        // Bảng đã tự khoá theo loài nên ở đây nhận gì đặt nấy
                        onDoiBoLoc: (moi) => setState(() => _boLoc = moi),
                        onChonNgay: _chonNgay,
                        onXemKetQua: () => setState(() => _moPanel = false),
                        onXoaHet: () => setState(() {
                          _boLoc = const BoLocTimKiem();
                          _noiTim = null;
                        }),
                      ),
                    ),
                  )
                else ...[
                  if (_noiTim == null && !_tuChoiQuyenViTri)
                    MapNoticeBanner(
                      tieuDe: l10n.banChuaLuuDiaChiNao,
                      moTa: l10n.moTaChuaLuuDiaChi,
                      nhanChinh: l10n.themDiaChi,
                      nhanPhu: l10n.dungViTriHienTai,
                      onChinh: () => context.push(AppRoutes.addAddress),
                      onPhu: _dungViTriHienTai,
                    ),
                  if (_tuChoiQuyenViTri)
                    MapNoticeBanner(
                      tieuDe: l10n.chuaBatQuyenViTri,
                      moTa: l10n.moTaChuaBatQuyenViTri,
                      nhanChinh: l10n.moCaiDat,
                      nhanPhu: l10n.nhapDiaChi,
                      onChinh: Geolocator.openAppSettings,
                      onPhu: _chonNoiTim,
                    ),
                  if (_noiTim?.nguon == NguonNoiTim.viTriHienTai)
                    MapCurrentLocationBanner(
                      onLuu: () => context.push(AppRoutes.addAddress),
                    ),
                  if (_daKeoBanDo)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.labelGap),
                      child: MapSearchAreaButton(
                        dangTai: _dangTraDiaChi,
                        onTap: _dangTraDiaChi ? null : _timTrongVungNay,
                      ),
                    ),
                ],
                if (!_moPanel) const Spacer(),
                if (!_moPanel) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: AppSpacing.screenPadding,
                        bottom: AppSpacing.itemGap,
                      ),
                      child: MapLocateButton(onTap: _dungViTriHienTai),
                    ),
                  ),
                  if (ketQua.isNotEmpty)
                    MapSitterStrip(
                      danhSach: ketQua,
                      moTaDem: _moTaDem(l10n, ketQua.length),
                      chiSoDangXem: _chiSoDangXem.clamp(0, ketQua.length - 1),
                      onDoiChiSo: (i) => _xemNguoiCham(i, ketQua),
                      onChonThe: (i) => _xemNguoiCham(i, ketQua),
                      kmCuaNguoiCham: _khoangCachKm,
                    ),
                  const SizedBox(height: AppSpacing.itemGap),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _moTaDieuKien(AppLocalizations l10n) {
    final noi = _noiTim == null || _noiTim!.laVungDangXem
        ? l10n.vungDangXem
        : (_noiTim!.nguon == NguonNoiTim.viTriHienTai
              ? l10n.viTriHienTai.toLowerCase()
              : _noiTim!.moTaPhu ?? _noiTim!.moTa!);
    final dichVu = _boLoc.dichVu?.ten(l10n) ?? l10n.dichVu;
    return '$dichVu · $noi';
  }

  String _moTaDem(AppLocalizations l10n, int so) {
    if (_noiTim == null || _noiTim!.laVungDangXem) {
      return l10n.soNguoiChamTrongVung(so);
    }
    if (_boLoc.dichVu == MucLocDichVu.trongGiu) {
      return l10n.soNguoiChamTrongBanKinh(so, '${_boLoc.banKinhKm.round()}');
    }
    return l10n.soNguoiChamNhanDonToiNha(so);
  }
}
