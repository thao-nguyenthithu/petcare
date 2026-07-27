import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/dksitter/widgets/id_card_frame.dart';

// Màn chụp CCCD mở từ bước 2
class IdCaptureScreen extends StatefulWidget {
  final String title;

  const IdCaptureScreen({super.key, required this.title});

  @override
  State<IdCaptureScreen> createState() => _IdCaptureScreenState();
}

class _IdCaptureScreenState extends State<IdCaptureScreen> {
  CameraController? _controller;
  bool _loiCamera = false;
  bool _dangXuLy = false;

  @override
  void initState() {
    super.initState();
    _moCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _moCamera() async {
    if (_loiCamera) setState(() => _loiCamera = false);
    try {
      final dsCamera = await availableCameras();
      if (dsCamera.isEmpty) {
        if (mounted) setState(() => _loiCamera = true);
        return;
      }
      final cameraSau = dsCamera.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => dsCamera.first,
      );
      final controller = CameraController(
        cameraSau,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (loi) {
      debugPrint('Không mở được camera: $loi');
      if (!mounted) return;
      setState(() => _loiCamera = true);
    }
  }

  Future<void> _chup() async {
    final controller = _controller;
    if (controller == null || _dangXuLy) return;
    setState(() => _dangXuLy = true);
    try {
      final anh = await controller.takePicture();
      final bytes = await anh.readAsBytes();
      final daCat = await compute(_catTheoKhung, bytes);
      if (!mounted) return;
      context.pop(daCat);
    } catch (loi) {
      debugPrint('Không chụp được: $loi');
      if (!mounted) return;
      setState(() => _dangXuLy = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.khongMoDuocCamera)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
        ),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_loiCamera)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.khongMoDuocCamera,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _moCamera,
                      child: Text(
                        l10n.thuLai,
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (controller == null)
            const Center(
              child: CircularProgressIndicator(color: AppColors.textWhite),
            )
          else
            Center(
              child: AspectRatio(
                aspectRatio: 1 / controller.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(controller),
                    const IdCardViewfinder(color: AppColors.textWhite),
                  ],
                ),
              ),
            ),
          if (!_loiCamera && controller != null) _thanhDuoi(context),
          if (_dangXuLy)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.textWhite),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dangXuLyAnh,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thanhDuoi(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                ),
                child: Text(
                  context.l10n.huongDanChupThe,
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _chup,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textWhite, width: 3),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.textWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Cắt ảnh đúng vùng khung ngắm
Uint8List _catTheoKhung(Uint8List bytes) {
  final goc = img.decodeImage(bytes);
  if (goc == null) return bytes;
  final anh = img.bakeOrientation(goc);
  final rong = (anh.width * tiLeRongKhungNgam).round();
  final cao = (rong / tiLeTheCccd).round();
  if (cao > anh.height) return img.encodeJpg(anh, quality: 90);
  return img.encodeJpg(
    img.copyCrop(
      anh,
      x: (anh.width - rong) ~/ 2,
      y: (anh.height - cao) ~/ 2,
      width: rong,
      height: cao,
    ),
    quality: 90,
  );
}
