import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/features/provider_profile/widgets/dashed_border.dart';
import 'package:petcare_app/features/provider_profile/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final List<ServiceDraft> _services = [];

  Future<void> _themDichVu() async {
    final moi = await context.push<ServiceDraft>(AppRoutes.providerAddService);
    if (moi == null || !mounted) return;
    setState(() => _services.add(moi));
  }

  void _tiepTuc() {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.themItNhatMotDichVu)));
      return;
    }
    context.push(AppRoutes.providerPersonalInfo);
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
              const StepProgressBar(currentStep: 1),
              const SizedBox(height: 20),
              Text(
                l10n.buocTrenTong('1', '4'),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.dichVuCuaBan, style: AppTextStyles.h1),
              const SizedBox(height: 12),
              Text(l10n.themItNhatMotDichVu, style: AppTextStyles.caption),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final dichVu in _services)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ServiceCard(service: dichVu),
                      ),
                    GestureDetector(
                      onTap: _themDichVu,
                      child: DashedBorder(
                        color: AppColors.primaryColor,
                        radius: AppRadius.radius14,
                        child: SizedBox(
                          height: 56,
                          child: Center(
                            child: Text(
                              '+  ${l10n.themDichVu}',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppButton(text: l10n.tiepTuc, height: 56, onTap: _tiepTuc),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceDraft service;

  const _ServiceCard({required this.service});

  String get _iconAsset => switch (service.type) {
    ServiceType.walking => 'assets/icons/icon_leash.svg',
    ServiceType.boarding => 'assets/icons/paw.svg',
    ServiceType.grooming => 'assets/icons/icon_grooming.svg',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardMint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: SvgPicture.asset(_iconAsset, width: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(service.subtitle, style: AppTextStyles.captionSm),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
