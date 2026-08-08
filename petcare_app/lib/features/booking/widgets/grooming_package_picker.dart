import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_breeds.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _avatar = 40;

class GroomingPackagePicker extends StatelessWidget {
  const GroomingPackagePicker({
    super.key,
    required this.pets,
    required this.config,
    required this.goiTheoBe,
    required this.onChon,
  });

  final List<Pet> pets;
  final GroomingConfig config;
  final Map<String, GroomingPackage> goiTheoBe;
  final void Function(Pet be, GroomingPackage goi) onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.goiChoTungBe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final be in pets)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _KhoiBe(
              be: be,
              config: config,
              chon: goiTheoBe[be.id],
              onChon: (goi) => onChon(be, goi),
            ),
          ),
      ],
    );
  }
}

class _KhoiBe extends StatelessWidget {
  const _KhoiBe({
    required this.be,
    required this.config,
    required this.chon,
    required this.onChon,
  });

  final Pet be;
  final GroomingConfig config;
  final GroomingPackage? chon;
  final void Function(GroomingPackage goi) onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muc = mucCanCua(be.weightKg);
    final loai = tenLoai(l10n, be.species);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PetAvatar(imageUrl: be.avatar, name: be.name, size: _avatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${be.name} · $loai ${tenGiong(context, be.breed)} · '
                    '${l10n.soKgCanNang(canNangGon(be.weightKg))}',
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    muc == null
                        ? l10n.vuotMucCanNcc
                        : l10n.giaTheoMuc(weightTierLabel(context, muc)),
                    style: AppTextStyles.captionSm,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Hai gói chia đôi bề ngang cho cân, tên gói dài không phải xuống dòng
        Row(
          children: [
            for (final (i, goi) in GroomingPackage.values.indexed) ...[
              if (i != 0) const SizedBox(width: 12),
              Expanded(
                child: _ChipGoi(
                  ten: groomingPackageName(context, goi),
                  gia: muc == null ? null : config.priceByPackage[goi]?[muc],
                  chon: chon == goi,
                  onTap: () => onChon(goi),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// Một gói của bé: NCC không bán gói đó hoặc bé vượt mức cân thì để mờ
class _ChipGoi extends StatelessWidget {
  const _ChipGoi({
    required this.ten,
    required this.gia,
    required this.chon,
    required this.onTap,
  });

  final String ten;
  final int? gia;
  final bool chon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final co = gia != null;
    final mauChu = !co
        ? AppColors.neutral
        : chon
        ? AppColors.primaryColor
        : AppColors.textPrimary;
    return InkWell(
      onTap: co ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: chon ? AppColors.cardMint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(
            color: chon ? AppColors.primaryColor : AppColors.neutralLight,
          ),
        ),
        child: Column(
          children: [
            Text(
              ten,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(color: mauChu),
            ),
            const SizedBox(height: 1),
            Text(
              co ? '${dinhDangTien(gia!)}đ' : '—',
              style: AppTextStyles.captionSm.copyWith(
                color: co && chon ? AppColors.primaryColor : AppColors.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
