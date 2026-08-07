import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/widgets/pet_prevention_tag.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

// Đầu màn hồ sơ bé
class PetDetailHero extends StatelessWidget {
  const PetDetailHero({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.cardPadding,
      ),
      child: Row(
        children: [
          PetAvatar(imageUrl: pet.avatar, name: pet.name, size: 64),
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
                        style: AppTextStyles.h2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.labelGap),
                    PetPreventionTag(pet: pet),
                  ],
                ),
                const SizedBox(height: AppSpacing.textGap),
                Text(petSummary(context, pet), style: AppTextStyles.captionSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
