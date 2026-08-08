import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';

const double _avatar = 52;

class BookingDetailHero extends StatelessWidget {
  const BookingDetailHero({
    super.key,
    required this.pets,
    required this.loai,
    required this.tenDichVu,
    this.onXemBe,
  });

  final List<Pet> pets;
  final ServiceType loai;
  final String tenDichVu;
  final VoidCallback? onXemBe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tomTat = tomTatCacBe(l10n, pets);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onXemBe,
          child: Row(
            children: [
              PetAvatarStack(pets: tomTat, size: _avatar, toiDa: 3),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tenCacBe(context, pets),
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _soBeVaLoai(context, pets),
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onXemBe != null)
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            SvgPicture.asset(loai.iconAsset, width: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tenDichVu,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _soBeVaLoai(BuildContext context, List<Pet> pets) {
  final l10n = context.l10n;
  final soCho = pets.where((p) => p.species == PetSpecies.dog).length;
  final soMeo = pets.length - soCho;
  final loai = [
    if (soCho > 0) '$soCho ${l10n.cho.toLowerCase()}',
    if (soMeo > 0) '$soMeo ${l10n.meo.toLowerCase()}',
  ];
  return '${l10n.soBe('${pets.length}')} · ${loai.join(', ')}';
}

String _tenCacBe(BuildContext context, List<Pet> pets) {
  if (pets.isEmpty) return '';
  if (pets.length == 1) return pets.first.name;
  final dau = pets.take(pets.length - 1).map((p) => p.name).join(', ');
  return context.l10n.tenVaTen(dau, pets.last.name);
}
