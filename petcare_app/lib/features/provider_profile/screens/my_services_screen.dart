import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_profile/data/mock_provider_data.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/features/provider_profile/widgets/dashed_border.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';

// Màn quản lý dịch vụ của NCC sau khi hồ sơ được duyệt, thêm sửa xóa dịch vụ
class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  // Nối API: thay bằng GET /provider/services trong notifier
  final List<ServiceDraft> _services = MockProviderData.dichVuCuaToi();

  Future<void> _themDichVu() async {
    final ketQua = await context.push<ServiceEditResult>(
      AppRoutes.providerAddService,
    );
    final moi = ketQua?.draft;
    if (moi == null || !mounted) return;
    setState(() => _services.add(moi));
  }

  Future<void> _suaDichVu(int viTri) async {
    final ketQua = await context.push<ServiceEditResult>(
      AppRoutes.providerAddService,
      extra: _services[viTri],
    );
    if (ketQua == null || !mounted) return;
    setState(() {
      final moi = ketQua.draft;
      if (moi == null) {
        _services.removeAt(viTri);
      } else {
        _services[viTri] = moi;
      }
    });
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
              Text(l10n.dichVuCuaBan, style: AppTextStyles.h1),
              const SizedBox(height: 12),
              Text(l10n.themDichVuBanCungCap, style: AppTextStyles.caption),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final (viTri, dichVu) in _services.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ServiceCard(
                          service: dichVu,
                          onTap: () => _suaDichVu(viTri),
                        ),
                      ),
                    DashedBorder(
                      color: AppColors.primaryColor,
                      radius: AppRadius.radius14,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.radius14),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: _themDichVu,
                          borderRadius: BorderRadius.circular(
                            AppRadius.radius14,
                          ),
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
                    ),
                  ],
                ),
              ),
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
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  String get _iconAsset => switch (service.type) {
    ServiceType.walking => 'assets/icons/icon_leash.svg',
    ServiceType.boarding => 'assets/icons/paw.svg',
    ServiceType.grooming => 'assets/icons/icon_grooming.svg',
  };

  String _tomTat(BuildContext context) {
    final l10n = context.l10n;
    final loai = switch (service.petKind) {
      PetKind.dog => l10n.cho,
      PetKind.cat => l10n.meo,
      PetKind.both => l10n.caHai,
    };
    return switch (service.type) {
      ServiceType.walking => l10n.tomTatDatDv(
        loai,
        '${service.durationMinutes}',
        dinhDangTien(service.price ?? 0),
      ),
      ServiceType.boarding => l10n.tomTatTrongGiu(
        loai,
        dinhDangTien(service.price ?? 0),
        '${service.capacity}',
      ),
      ServiceType.grooming => l10n.tomTatCatTia(
        loai,
        _tenGoi(l10n),
        dinhDangTien(service.lowestWeightPrice ?? 0),
      ),
    };
  }

  String _tenGoi(AppLocalizations l10n) => switch (service.package) {
    GroomingPackage.bath => l10n.chiTam,
    _ => l10n.tamVaCatTia,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
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
                    Text(_tomTat(context), style: AppTextStyles.captionSm),
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
        ),
      ),
    );
  }
}
