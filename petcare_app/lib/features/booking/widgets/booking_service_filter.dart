import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';

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
          return AppFilterChip(
            label: label,
            selected: selected == type,
            onTap: () => onSelected(type),
          );
        },
      ),
    );
  }
}
