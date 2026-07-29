import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';

// Nhãn tình trạng tiêm chủng đứng cạnh tên bé trên thẻ danh sách
class PetPreventionTag extends StatelessWidget {
  const PetPreventionTag({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final kieu = petPreventionStyle(petPreventionStatus(pet));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kieu.icon != null) ...[
          Icon(kieu.icon, size: 15, color: kieu.mau),
          const SizedBox(width: AppSpacing.textGap),
        ],
        Text(
          petPreventionLabel(context, pet),
          style: AppTextStyles.captionSm.copyWith(
            color: kieu.mau,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
