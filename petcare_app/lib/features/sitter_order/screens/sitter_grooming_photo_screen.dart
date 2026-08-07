import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/widgets/camera_parts.dart';
import 'package:petcare_app/features/sitter_order/data/grooming_session.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Camera chụp ảnh trước khi làm, chip gọi theo tên bé
class SitterGroomingPhotoScreen extends ConsumerStatefulWidget {
  const SitterGroomingPhotoScreen({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  ConsumerState<SitterGroomingPhotoScreen> createState() =>
      _SitterGroomingPhotoScreenState();
}

class _SitterGroomingPhotoScreenState
    extends ConsumerState<SitterGroomingPhotoScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;

  bool _dangMo = true;

  late final List<List<Uint8List>> _anh = [
    for (var i = 0; i < _soBe; i++) <Uint8List>[],
  ];

  int _beDangChon = 0;
  bool _dangChup = false;
  bool _dangGui = false;

  bool _nhay = false;
  Timer? _timerNhay;

  List<Pet> get _pets => widget.don.pets;
  int get _soBe => _pets.length;
  int get _daChup => _anh.fold(0, (tong, cua) => tong + cua.length);
  int get _tranAnh => _soBe * soAnhMoiBeToiDa;

  bool get _duAnh => _anh.every((cua) => cua.length >= soAnhMoiBeToiThieu);

  bool get _conChoBeNay => _anh[_beDangChon].length < soAnhMoiBeToiDa;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _moCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerNhay?.cancel();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      cam.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _moCamera();
    }
  }

  Future<void> _moCamera() async {
    try {
      final dsCamera = await availableCameras();
      if (dsCamera.isEmpty) {
        if (mounted) setState(() => _dangMo = false);
        return;
      }
      final controller = CameraController(
        dsCamera.first,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _dangMo = false;
      });
    } on CameraException {
      if (mounted) setState(() => _dangMo = false);
    }
  }

  Future<void> _chup() async {
    final cam = _camera;
    if (cam == null || !cam.value.isInitialized || _dangChup) return;
    setState(() {
      _dangChup = true;
      _nhay = true;
    });
    _timerNhay?.cancel();
    _timerNhay = Timer(const Duration(milliseconds: 140), () {
      if (mounted) setState(() => _nhay = false);
    });
    try {
      final file = await cam.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _anh[_beDangChon].add(bytes);
        if (_anh[_beDangChon].length < soAnhMoiBeToiThieu) return;
        for (var i = 0; i < _soBe; i++) {
          if (_anh[i].length < soAnhMoiBeToiThieu) {
            _beDangChon = i;
            break;
          }
        }
      });
    } on CameraException {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _dangChup = false);
    }
  }

  Future<void> _gui() async {
    if (_dangGui) return;
    final id = widget.don.bookingId;
    setState(() => _dangGui = true);
    final xong = await chayHanhDongDon(
      context,
      ref,
      id,
      (s) => s.batDauPhien(
        id,
        anh: anhMultipart([for (final cua in _anh) ...cua], 'before'),
      ),
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (xong) context.pushReplacement(AppRoutes.sitterActiveGroomingPath(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daChup = [for (final cua in _anh) ...cua];
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Column(
          children: [
            CameraTopBar(
              tieuDe: l10n.anhTruocKhiLamNhan,
              nhanPhai: l10n.soBe('$_soBe'),
            ),
            CameraChipRow(
              nhan: [for (final p in _pets) p.name],
              dangChon: _beDangChon,
              daChup: [
                for (final cua in _anh) cua.length >= soAnhMoiBeToiThieu,
              ],
              onChon: (i) => setState(() => _beDangChon = i),
            ),
            Expanded(
              child: CameraViewfinder(
                camera: _camera,
                dangMo: _dangMo,
                nhay: _nhay,
                huongDan: l10n.huongDanChupTruocKhiLam,
              ),
            ),
            CameraThumbStrip(
              anh: [...daChup, null],
              dangChon: -1,
              oCuoiLaKhungTrong: true,
            ),
            CameraControls(
              nhanDem: l10n.soTamDaChup('$_daChup', '$_tranAnh'),
              nhanGui: _dangGui ? l10n.dangGuiAnhChamCham : l10n.guiAnh,
              chupDuoc:
                  _camera != null && !_dangChup && !_dangGui && _conChoBeNay,
              dangChup: _dangChup,
              duAnh: _duAnh && !_dangGui,
              onChup: _chup,
              onGui: _gui,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(leMucPhang, 0, leMucPhang, 8),
              child: Text(
                l10n.nhacAnhTruocKhiLam('$soAnhMoiBeToiThieu'),
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.neutral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
