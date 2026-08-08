import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/dksitter/providers/dksitter_provider.dart';
import 'package:petcare_app/features/dksitter/widgets/id_card_frame.dart';
import 'package:petcare_app/shared/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Bước 2/3 đăng ký NCC chụp hai mặt CCCD
class IdPhotosScreen extends ConsumerStatefulWidget {
  const IdPhotosScreen({super.key});

  @override
  ConsumerState<IdPhotosScreen> createState() => _IdPhotosScreenState();
}

class _IdPhotosScreenState extends ConsumerState<IdPhotosScreen> {
  Uint8List? _anhMatTruoc;
  Uint8List? _anhMatSau;

  Future<void> _chonAnh(bool laMatTruoc) async {
    final l10n = context.l10n;
    final bytes = await context.push<Uint8List>(
      AppRoutes.sitterIdCapture,
      extra: laMatTruoc ? l10n.chupMatTruoc : l10n.chupMatSau,
    );
    if (bytes == null || !mounted) return;
    setState(() {
      if (laMatTruoc) {
        _anhMatTruoc = bytes;
      } else {
        _anhMatSau = bytes;
      }
    });
  }

  void _tiepTuc() {
    if (_anhMatTruoc == null || _anhMatSau == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.vuiLongTaiDuAnh)));
      return;
    }
    ref
        .read(dkSitterProvider.notifier)
        .luuAnhCccd(matTruoc: _anhMatTruoc, matSau: _anhMatSau);
    context.push(AppRoutes.sitterCommitment);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                const SizedBox(height: 20),
                const StepProgressBar(
                  buoc: 2,
                  tong: 3,
                  dayVach: 6,
                  khe: 8,
                  mauChuaQua: AppColors.neutral,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.cardMint,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/icon_shield.svg',
                        width: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.buocTrenTong('2', '3'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.taiLenCccd,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.anhRoNet,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 24),
                _OAnh(
                  label: l10n.chupMatTruoc,
                  anh: _anhMatTruoc,
                  onTap: () => _chonAnh(true),
                ),
                const SizedBox(height: 16),
                _OAnh(
                  label: l10n.chupMatSau,
                  anh: _anhMatSau,
                  onTap: () => _chonAnh(false),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.thongTinKhopBuocTruoc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSm,
                ),
                const SizedBox(height: 28),
                AppButton(text: l10n.tiepTuc, height: 56, onTap: _tiepTuc),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OAnh extends StatelessWidget {
  final String label;
  final Uint8List? anh;
  final VoidCallback onTap;

  const _OAnh({required this.label, required this.anh, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: tiLeTheCccd,
          child: anh == null ? _khungTrong(context) : _anhDaChup(context),
        ),
      ),
    );
  }

  Widget _khungTrong(BuildContext context) {
    final l10n = context.l10n;
    return IdCardFrame(
      color: AppColors.primaryColor,
      child: AppCard(
        vien: false,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.cardMint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_camera_rounded,
                color: AppColors.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(l10n.datTheVaoKhung, style: AppTextStyles.captionSm),
          ],
        ),
      ),
    );
  }

  Widget _anhDaChup(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: Image.memory(anh!, fit: BoxFit.cover),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.43),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.photo_camera_rounded,
                  size: 15,
                  color: AppColors.textWhite,
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.chupLai,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
