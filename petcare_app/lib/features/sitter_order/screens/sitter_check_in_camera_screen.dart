import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';
import 'package:petcare_app/features/sitter_order/services/checkin_scan_api_service.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_error_mapper.dart';
import 'package:petcare_app/features/sitter_order/widgets/camera_parts.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Camera check-in, chụp đủ rồi mới gửi cả lô cho AI kiểm
class SitterCheckInCameraScreen extends StatefulWidget {
  const SitterCheckInCameraScreen({
    super.key,
    required this.args,
    this.chupLaiO,
    this.conLai,
  });

  final CheckInArgs args;
  final int? chupLaiO;
  final int? conLai;

  @override
  State<SitterCheckInCameraScreen> createState() =>
      _SitterCheckInCameraScreenState();
}

class _SitterCheckInCameraScreenState extends State<SitterCheckInCameraScreen>
    with WidgetsBindingObserver {
  final _api = CheckinScanApiService();

  CameraController? _camera;

  bool _dangMo = true;

  late final List<Uint8List?> _anh = List.filled(_soO, null);

  late final List<bool> _daGuiTruoc = [
    for (var i = 0; i < _soO; i++)
      widget.chupLaiO != null && i != widget.chupLaiO,
  ];

  late int _oDangChon = widget.chupLaiO ?? 0;
  bool _dangChup = false;
  bool _dangGui = false;
  String? _loiGui;
  bool _nhay = false;
  Timer? _timerNhay;

  int get _soBe => widget.args.don.pets.length;
  int get _soO => _soBe + 1;
  int get _daChup => _anh.where((a) => a != null).length;

  bool get _laChupLai => widget.chupLaiO != null;

  bool get _duAnh =>
      _laChupLai ? _anh[widget.chupLaiO!] != null : _daChup == _soO;

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
        _anh[_oDangChon] = bytes;
        if (_laChupLai) return;
        for (var i = 0; i < _soO; i++) {
          if (_anh[i] == null) {
            _oDangChon = i;
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
    final l10n = context.l10n;
    final bookingId = widget.args.don.bookingId;
    setState(() {
      _dangGui = true;
      _loiGui = null;
    });
    final Position viTri;
    try {
      viTri = await Geolocator.getCurrentPosition();
    } on Exception {
      if (!mounted) return;
      setState(() {
        _dangGui = false;
        _loiGui = l10n.loiKhongLayDuocViTri;
      });
      return;
    }
    try {
      final kq = await _api.guiLo(
        bookingId,
        anh: [
          for (final (i, bytes) in _anh.indexed)
            if (bytes != null) (slotIndex: i, bytes: bytes),
        ],
        lat: viTri.latitude,
        lng: viTri.longitude,
      );
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.sitterAiScanPath(bookingId),
        extra: (checkIn: widget.args, batchId: kq.batchId),
      );
    } on Exception catch (loi) {
      if (!mounted) return;
      setState(() {
        _dangGui = false;
        _loiGui = codeFromError(loi) == null
            ? l10n.khongGuiDuocAnh
            : moTaLoiDonNcc(context, loi);
      });
    }
  }

  String _nhanGui(AppLocalizations l10n) {
    if (_dangGui) return l10n.dangGuiAnhChamCham;
    if (_loiGui != null) return l10n.thuLai;
    return _laChupLai ? l10n.guiLai : l10n.guiAnh;
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
              nhanPhai: l10n.soBe('$_soBe'),
              // Nói rõ phải chụp lại bé nào, khỏi đọc lại kết quả
              tieuDe: _laChupLai
                  ? l10n.chupLaiBe(l10n.beThuMay('${widget.chupLaiO}'))
                  : l10n.roMomVaDayXich,
            ),
            CameraChipRow(
              nhan: [
                l10n.caDan,
                for (var i = 1; i <= _soBe; i++) l10n.beThuMay('$i'),
              ],
              dangChon: _oDangChon,
              daChup: [
                for (var i = 0; i < _soO; i++)
                  _anh[i] != null || _daGuiTruoc[i],
              ],
              khoa: _daGuiTruoc,
              onChon: _laChupLai ? null : (i) => setState(() => _oDangChon = i),
            ),
            Expanded(
              child: CameraViewfinder(
                camera: _camera,
                dangMo: _dangMo,
                nhay: _nhay,
                huongDan: _oDangChon == 0
                    ? l10n.huongDanChupCaDan
                    : l10n.huongDanChupMotBe(l10n.beThuMay('$_oDangChon')),
              ),
            ),
            CameraThumbStrip(
              anh: _anh,
              daGuiTruoc: _daGuiTruoc,
              dangChon: _oDangChon,
            ),
            CameraControls(
              nhanDem: switch (widget.conLai) {
                final n? when _laChupLai => l10n.conNLanChupLai('$n'),
                _ => l10n.soTamDaChup('$_daChup', '$_soO'),
              },
              nhanGui: _nhanGui(l10n),
              chupDuoc: _camera != null && !_dangChup && !_dangGui,
              dangChup: _dangChup,
              duAnh: _duAnh && !_dangGui,
              onChup: _chup,
              onGui: _gui,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(leMucPhang, 0, leMucPhang, 8),
              child: Text(
                _loiGui ?? l10n.nhacGuiCaLoAnh('$_soO'),
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSm.copyWith(
                  color: _loiGui == null ? AppColors.neutral : AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
