import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';

class OrderSummaryHead extends StatelessWidget {
  const OrderSummaryHead({
    super.key,
    required this.pets,
    required this.moTaThoiGian,
    required this.tenDoiTac,
    this.tenDichVu,
    this.keDuoi = false,
  });

  static const double _coAvatar = 40;
  final List<Pet> pets;
  final String moTaThoiGian;
  final String tenDoiTac;
  final String? tenDichVu;
  final bool keDuoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Row(
          children: [
            PetAvatarStack(
              pets: tomTatCacBe(l10n, pets),
              size: _coAvatar,
              toiDa: 3,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tenDichVu case final ten?) ...[
                    Text(
                      '$ten · ${l10n.soBe('${pets.length}')}',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                  ],
                  Text(
                    '$moTaThoiGian · $tenDoiTac',
                    style: AppTextStyles.captionSm,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (keDuoi) ...[
          const SizedBox(height: AppSpacing.itemGap),
          const AppDongKe(),
        ],
      ],
    );
  }
}
