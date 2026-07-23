import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/mock_booking_data.dart';

// Hàng chip lọc nhanh theo loại dịch vụ
class BookingServiceFilter extends StatelessWidget {
  const BookingServiceFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PetServiceType? selected;
  final ValueChanged<PetServiceType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = <(String, PetServiceType?)>[
      (l10n.tatCa, null),
      (l10n.datDiDao, PetServiceType.datDiDao),
      (l10n.trongGiu, PetServiceType.trongGiu),
      (l10n.tamVaTia, PetServiceType.tamTia),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingWide,
        ),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (context, i) {
          final (label, type) = items[i];
          final isSelected = selected == type;
          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(type),
            showCheckmark: false,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            labelStyle: AppTextStyles.captionSm.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textSecondary,
            ),
            backgroundColor: AppColors.background,
            selectedColor: AppColors.cardMint,
            side: BorderSide(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.neutralLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}
