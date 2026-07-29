import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Section thú cưng
class PetsSection extends StatelessWidget {
  const PetsSection({super.key, required this.pets});

  final List<MockPet> pets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (pets.isEmpty) return const _AddPetCta();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          for (final pet in pets) ...[
            _PetAvatar(
              label: pet.name,
              labelColor: AppColors.textPrimary,
              child: ClipOval(
                child: Image.asset(
                  pet.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
          _PetAvatar(
            label: l10n.them,
            labelColor: AppColors.primaryColor,
            child: const Icon(
              Icons.add,
              size: 24,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({
    required this.label,
    required this.labelColor,
    required this.child,
  });

  final String label;
  final Color labelColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TapCircle(
          size: 60,
          onTap: () => baoDangPhatTrien(context),
          child: child,
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.captionSm.copyWith(color: labelColor)),
      ],
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
                onTap: () => baoDangPhatTrien(context),
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
