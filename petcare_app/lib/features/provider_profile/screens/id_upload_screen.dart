import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_profile/widgets/dashed_border.dart';
import 'package:petcare_app/features/provider_profile/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

class IdUploadScreen extends StatefulWidget {
  const IdUploadScreen({super.key});

  @override
  State<IdUploadScreen> createState() => _IdUploadScreenState();
}

class _IdUploadScreenState extends State<IdUploadScreen> {
  final _picker = ImagePicker();
  Uint8List? _anhMatTruoc;
  Uint8List? _anhMatSau;

  Future<void> _chonAnh(bool laMatTruoc) async {
    final anh = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
    );
    if (anh == null) return;
    final bytes = await anh.readAsBytes();
    if (!mounted) return;
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
    context.push(AppRoutes.providerCommitment);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
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
              const StepProgressBar(currentStep: 3),
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
                l10n.buocTrenTong('3', '4'),
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
              Text(
                l10n.anhCccd,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _OAnh(
                      label: l10n.matTruoc,
                      anh: _anhMatTruoc,
                      onTap: () => _chonAnh(true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _OAnh(
                      label: l10n.matSau,
                      anh: _anhMatSau,
                      onTap: () => _chonAnh(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.thongTinKhopBuocTruoc,
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSm,
              ),
              const Spacer(),
              AppButton(text: l10n.tiepTuc, height: 56, onTap: _tiepTuc),
              const SizedBox(height: 24),
            ],
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
    return GestureDetector(
      onTap: onTap,
      child: anh == null
          ? DashedBorder(
              color: AppColors.neutral,
              radius: AppRadius.radius14,
              child: Container(
                height: 104,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/icon_camera.svg', width: 20),
                    const SizedBox(height: 10),
                    Text(
                      label,
                      style: AppTextStyles.captionSm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              child: SizedBox(
                height: 104,
                child: Image.memory(
                  anh!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
    );
  }
}
