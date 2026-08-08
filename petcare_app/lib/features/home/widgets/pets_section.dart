import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/screens/pet_detail_screen.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

class PetsSection extends StatelessWidget {
  const PetsSection({super.key, required this.pets});
  static const double _cao = 84;
  static const double _rongMoiO = 88;
  final List<Pet> pets;

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) return const _AddPetCta();
    return SizedBox(
      height: _cao + 32,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: pets.length + 1,
        itemExtent: _rongMoiO,
        itemBuilder: (context, i) {
          if (i == pets.length) {
            return _PetAvatar(
              label: context.l10n.them,
              labelColor: AppColors.primaryColor,
              onTap: () => context.push(AppRoutes.addPet),
              child: const Icon(
                Icons.add,
                size: 24,
                color: AppColors.primaryColor,
              ),
            );
          }
          final pet = pets[i];
          return _PetAvatar(
            label: pet.name,
            labelColor: AppColors.textPrimary,
            onTap: () => context.push(
              AppRoutes.petDetail,
              extra: PetDetailArgs(petId: pet.id, pet: pet),
            ),
            child: PetAvatar(imageUrl: pet.avatar, name: pet.name, size: 50),
          );
        },
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({
    required this.label,
    required this.labelColor,
    required this.onTap,
    required this.child,
  });

  final String label;
  final Color labelColor;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          _TapCircle(size: 60, onTap: onTap, child: child),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm.copyWith(color: labelColor),
          ),
        ],
      ),
    );
  }
}

class _TapCircle extends StatelessWidget {
  const _TapCircle({
    required this.size,
    required this.onTap,
    required this.child,
  });

  final double size;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardMint,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryColor.withValues(alpha: 0.2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: child),
        ),
      ),
    );
  }
}

// Yêu cầu thêm hồ sơ thú cưng khi chưa có
class _AddPetCta extends StatelessWidget {
  const _AddPetCta();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              _TapCircle(
                size: 50,
                onTap: () => context.push(AppRoutes.addPet),
                child: const Icon(
                  Icons.add,
                  size: 24,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.themHoSoThuCung,
                  style: AppTextStyles.captionSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const AppDongKe(mau: AppColors.neutral),
        ],
      ),
    );
  }
}
