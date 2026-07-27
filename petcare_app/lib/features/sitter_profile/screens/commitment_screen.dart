import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_profile/providers/sitter_profile_provider.dart';
import 'package:petcare_app/features/sitter_profile/services/sitter_profile_error_mapper.dart';
import 'package:petcare_app/features/sitter_profile/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Bước 3/3 đăng ký NCC cam kết trách nhiệm
class CommitmentScreen extends ConsumerStatefulWidget {
  const CommitmentScreen({super.key});

  @override
  ConsumerState<CommitmentScreen> createState() => _CommitmentScreenState();
}

class _CommitmentScreenState extends ConsumerState<CommitmentScreen> {
  bool _daDongY = false;

  Future<void> _guiHoSo() async {
    try {
      await ref.read(sitterProfileProvider.notifier).guiHoSo();
      if (!mounted) return;
      context.go(AppRoutes.sitterSubmitted);
    } catch (loi) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mapSitterProfileError(context.l10n, loi))),
      );
    }
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
                        'assets/icons/paw.svg',
                        width: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.buocTrenTong('3', '3'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.camKetDieuKhoan,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.xacNhanTrachNhiem,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.radius14),
                    border: Border.all(color: AppColors.neutral),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/icon_shield.svg',
                            width: 17,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.camKetTrachNhiemNcc,
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DongCamKet(text: l10n.camKet1),
                      const SizedBox(height: 8),
                      _DongCamKet(text: l10n.camKet2),
                      const SizedBox(height: 8),
                      _DongCamKet(text: l10n.camKet3),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(l10n.nenTangTrungGian, style: AppTextStyles.captionSm),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _daDongY,
                        onChanged: (value) =>
                            setState(() => _daDongY = value ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        side: const BorderSide(color: AppColors.neutral),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _daDongY = !_daDongY),
                        child: Text.rich(
                          TextSpan(
                            text: '${l10n.dongYDieuKhoan} ',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.batBuoc,
                                style: AppTextStyles.captionSm.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                AppButton(
                  text: l10n.hoanTatGuiHoSo,
                  height: 56,
                  enabled: _daDongY,
                  onTapAsync: _guiHoSo,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.hoSoDuyet24h,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSm,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DongCamKet extends StatelessWidget {
  final String text;

  const _DongCamKet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_rounded,
          size: 12,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
