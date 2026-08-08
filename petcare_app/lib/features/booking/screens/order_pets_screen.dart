import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/screens/pet_detail_screen.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const double _avatar = 48;

typedef OrderPetsArgs = ({String maDon, String tenDichVu, List<Pet> pets});

// Danh sách thú cưng của một đơn
class OrderPetsScreen extends StatelessWidget {
  const OrderPetsScreen({super.key, required this.args});

  final OrderPetsArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.thuCungTrongDon,
            subtitle: l10n.donMaDichVu(args.maDon, args.tenDichVu),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: args.pets.length,
        separatorBuilder: (_, _) => const AppDongKe(),
        itemBuilder: (_, i) => _DongBe(be: args.pets[i], maDon: args.maDon),
      ),
    );
  }
}

class _DongBe extends StatelessWidget {
  const _DongBe({required this.be, required this.maDon});

  final Pet be;
  final String maDon;

  @override
  Widget build(BuildContext context) {
    final kieu = petPreventionStyle(petPreventionStatus(be));
    return InkWell(
      onTap: () => context.push(
        AppRoutes.petDetail,
        extra: PetDetailArgs(petId: be.id, maDon: maDon, pet: be),
      ),
      child: FlatSection(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              PetAvatar(imageUrl: be.avatar, name: be.name, size: _avatar),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(be.name, style: AppTextStyles.h3),
                    const SizedBox(height: 3),
                    Text(
                      petSummary(context, be),
                      style: AppTextStyles.captionSm,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (kieu.icon case final icon?) ...[
                          Icon(icon, size: 14, color: kieu.mau),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            petPreventionLabel(context, be),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.captionSm.copyWith(
                              color: kieu.mau,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.neutral,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
