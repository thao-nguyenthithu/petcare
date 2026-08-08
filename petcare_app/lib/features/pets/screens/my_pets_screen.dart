import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/pets/screens/pet_detail_screen.dart';
import 'package:petcare_app/features/pets/widgets/dashed_add_button.dart';
import 'package:petcare_app/features/pets/widgets/pet_prevention_tag.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const double _caoThe = 80;

// Màn Thú cưng của tôi trong tab Tài khoản của chủ nuôi
class MyPetsScreen extends ConsumerWidget {
  const MyPetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final danhSach = ref.watch(myPetsProvider);
    final so = danhSach.value?.length ?? 0;
    return AppScreen(
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.thuCungCuaToi,
            subtitle: so == 0
                ? l10n.chuaCoThuCungNao
                : l10n.soBeDangCoHoSo('$so'),
          ),
          const AppDongKe(),
        ],
      ),
      body: danhSach.when(
        loading: () => const AppSkeletonList(caoThe: _caoThe),
        error: (_, _) => AppNetworkError(
          onRetry: () => ref.read(myPetsProvider.notifier).taiLai(),
        ),
        data: (ds) => AppRefreshIndicator(
          onRefresh: () => ref.read(myPetsProvider.notifier).taiLai(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              for (final pet in ds) ...[
                _PetCard(
                  pet: pet,
                  onTap: () => context.push(
                    AppRoutes.petDetail,
                    extra: PetDetailArgs(petId: pet.id),
                  ),
                ),
                const SizedBox(height: AppSpacing.itemGap),
              ],
              DashedAddButton(
                text: l10n.themThuCung,
                onTap: () => context.push(AppRoutes.addPet),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              AppNoteBox(text: l10n.ghiChuHoSoThuCung),
            ],
          ),
        ),
      ),
    );
  }
}

// Thẻ một bé
class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

  final Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutralLight),
            borderRadius: BorderRadius.circular(AppRadius.radius14),
          ),
          child: Row(
            children: [
              PetAvatar(imageUrl: pet.avatar, name: pet.name, size: 48),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: AppTextStyles.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.labelGap),
                        PetPreventionTag(pet: pet),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      petSummary(context, pet),
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
