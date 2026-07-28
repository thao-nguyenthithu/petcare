import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/sitter_profile.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_area.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_bio.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_calendar.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_hero.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_identity.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_services.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_profile_stats.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';

// Trang XEM hồ sơ NCC
class SitterPublicViewScreen extends ConsumerWidget {
  const SitterPublicViewScreen({super.key, this.sitterId});

  final String? sitterId;

  bool get _cuaToi => sitterId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hồ sơ của mình
    final AsyncValue<SitterProfile> async = _cuaToi
        ? ref
              .watch(sitterMeProvider)
              .whenData(
                (p) => p.copyWith(
                  services: ref.watch(sitterServicesProvider).asData?.value,
                  serviceArea: ref
                      .watch(sitterServiceAreaProvider)
                      .asData
                      ?.value,
                ),
              )
        : ref.watch(sitterPublicProvider(sitterId!));
    final view = async.asData?.value;

    return AnnotatedRegion(
      value: AppSystemUi.onLightBackground,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Stack(
          children: [
            AppRefreshIndicator(
              onRefresh: () => _lamMoi(ref),
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SitterProfileHero(
                    photos: view?.photos ?? const [],
                    onEdit: _cuaToi
                        ? () => context.push(AppRoutes.sitterProfileEdit)
                        : null,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      24 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: async.when(
                      data: (v) => _NoiDung(view: v),
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 60),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => _Loi(onThu: () => _lamMoi(ref)),
                    ),
                  ),
                ],
              ),
            ),
            // Nền vùng status bar, cố định không cuộn theo nội dung
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).padding.top,
              child: const IgnorePointer(
                child: ColoredBox(color: AppColors.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _lamMoi(WidgetRef ref) {
    if (!_cuaToi) return ref.refresh(sitterPublicProvider(sitterId!).future);
    return Future.wait([
      ref.read(sitterMeProvider.future),
      ref.read(sitterServicesProvider.future),
      ref.read(sitterServiceAreaProvider.future),
    ]);
  }
}

// Toàn bộ nội dung khi có dữ liệu
class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.view});

  final SitterProfile view;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SitterProfileIdentity(view: view),
        const SizedBox(height: 16),
        SitterProfileStats(view: view),
        const _Ngan(),
        SitterProfileBio(bio: view.bio ?? ''),
        const _Ngan(),
        SitterProfileServices(services: view.services),
        const _Ngan(),
        SitterProfileArea(area: view.serviceArea),
        const _Ngan(),
        const SitterProfileCalendar(),
      ],
    );
  }
}

// Báo lỗi
class _Loi extends StatelessWidget {
  const _Loi({required this.onThu});

  final VoidCallback onThu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, size: 40, color: AppColors.neutral),
          const SizedBox(height: 12),
          Text(l10n.khongTaiDuocDuLieu, style: AppTextStyles.body),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onThu, child: Text(l10n.thuLai)),
        ],
      ),
    );
  }
}

// Đường kẻ mảnh ngăn mục
class _Ngan extends StatelessWidget {
  const _Ngan();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1, color: AppColors.neutralLight),
  );
}
