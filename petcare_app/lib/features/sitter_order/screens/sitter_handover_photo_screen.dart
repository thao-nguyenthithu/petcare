import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/widgets/camera_parts.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Camera bàn giao, chip gọi theo nhóm chứ không theo bé
class SitterHandoverPhotoScreen extends StatefulWidget {
  const SitterHandoverPhotoScreen({
    super.key,
    required this.phien,
    required this.loai,
  });

  final BoardingSession phien;
  final LoaiBanGiao loai;

  @override
  State<SitterHandoverPhotoScreen> createState() =>
      _SitterHandoverPhotoScreenState();
}

class _SitterHandoverPhotoScreenState extends State<SitterHandoverPhotoScreen>
    with WidgetsBindingObserver {
  CameraController? _camera;

  // Hết mở mà camera vẫn null nghĩa là mở không được
  bool _dangMo = true;

  final List<Uint8List> _anhBe = [];
  final List<Uint8List> _anhDoDung = [];

  // 0 là nhóm các bé, 1 là nhóm đồ dùng
  int _nhomDangChon = 0;
  bool _dangChup = false;

  bool _nhay = false;
  Timer? _timerNhay;

  bool get _laNhanBe => widget.loai == LoaiBanGiao.nhanBe;
  int get _soBe => widget.phien.don.pets.length;
  int get _tranAnhBe => widget.phien.tranAnhBe;

  List<Uint8List> get _nhomHienTai => _nhomDangChon == 0 ? _anhBe : _anhDoDung;
  int get _tranNhomHienTai =>
      _nhomDangChon == 0 ? _tranAnhBe : soAnhDoDungToiDa;

  bool get _duAnh => _laNhanBe ? _anhBe.length >= _soBe : _anhBe.isNotEmpty;

  bool get _conChoNhomNay => _nhomHienTai.length < _tranNhomHienTai;

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
      setState(() => _nhomHienTai.add(bytes));
    } on CameraException {
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _dangChup = false);
    }
  }

  void _gui() {
    final args = (
      phien: widget.phien,
      loai: widget.loai,
      anhBe: _anhBe,
      anhDoDung: _anhDoDung,
    );
    context.pushReplacement(
      _laNhanBe ? AppRoutes.sitterHandover : AppRoutes.sitterFinishBoarding,
      extra: args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: SafeArea(
        child: Column(
          children: [
            CameraTopBar(
              tieuDe: _laNhanBe ? l10n.anhLucNhanBe : l10n.anhLucTraBe,
              nhanPhai: l10n.soBe('$_soBe'),
            ),
            CameraChipRow(
              nhan: [_laNhanBe ? l10n.cacBeNhan : l10n.traBe, l10n.doDungNhan],
              dangChon: _nhomDangChon,
              daChup: [_anhBe.isNotEmpty, _anhDoDung.isNotEmpty],
              onChon: (i) => setState(() => _nhomDangChon = i),
            ),
            Expanded(
              child: CameraViewfinder(
                camera: _camera,
                dangMo: _dangMo,
                nhay: _nhay,
                huongDan: _laNhanBe
                    ? l10n.huongDanChupLucNhanBe
                    : l10n.huongDanChupLucTraBe,
              ),
            ),
            CameraThumbStrip(
              anh: [..._nhomHienTai, null],
              dangChon: -1,
              oCuoiLaKhungTrong: true,
            ),
            CameraControls(
              nhanDem: _nhomDangChon == 0
                  ? (_laNhanBe
                        ? l10n.soAnhBe('${_anhBe.length}', '$_tranAnhBe')
                        : l10n.soAnhTraBe('${_anhBe.length}', '$_tranAnhBe'))
                  : l10n.soAnhDoDung(
                      '${_anhDoDung.length}',
                      '$soAnhDoDungToiDa',
                    ),
              nhanGui: l10n.guiAnh,
              chupDuoc: _camera != null && !_dangChup && _conChoNhomNay,
              dangChup: _dangChup,
              duAnh: _duAnh,
              onChup: _chup,
              onGui: _gui,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(leMucPhang, 0, leMucPhang, 8),
              child: Text(
                _laNhanBe
                    ? l10n.nhacAnhLucNhanBe('$soAnhBeMoiDauToiDa')
                    : l10n.nhacAnhLucTraBe,
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
