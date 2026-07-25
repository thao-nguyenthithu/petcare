import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_profile/data/mock_provider_data.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/features/provider_profile/data/service_summary.dart';
import 'package:petcare_app/features/provider_profile/widgets/dashed_border.dart';
import 'package:petcare_app/features/provider_profile/widgets/service_list_card.dart';
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
              Text(l10n.tatCaDichVuCuaToi, style: AppTextStyles.h1),
              const SizedBox(height: 12),
              Text(l10n.themDichVuBanCungCap, style: AppTextStyles.caption),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final (viTri, dichVu) in _services.indexed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceListCard(
                          iconAsset: dichVu.type.iconAsset,
                          title: dichVu.name,
                          subtitle: serviceSummary(context, dichVu),
                          onTap: () => _suaDichVu(viTri),
                          trailing: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
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
