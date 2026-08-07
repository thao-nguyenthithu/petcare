import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Chọn bé xong hệ thống tự siết loài, số bé và mức cân
class FilterPetPicker extends StatelessWidget {
  const FilterPetPicker({
    super.key,
    required this.danhSach,
    required this.daChon,
    required this.onDoiChon,
    required this.onThemBe,
    this.chiNhanCho = false,
    this.soBeNhapTay = 0,
  });

  final List<Pet> danhSach;
  final Set<String> daChon;
  final ValueChanged<Pet> onDoiChon;
  final VoidCallback onThemBe;
  final bool chiNhanCho;
  final int soBeNhapTay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chon = danhSach.where((p) => daChon.contains(p.id)).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.datChoBeNao, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.textGap),
        Text(l10n.moTaDatChoBeNao, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.itemGap),
        if (chiNhanCho) ...[
          Text(
            l10n.datDiDaoChiNhanCho,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.itemGap),
        ],
        if (chon.isEmpty && soBeNhapTay > 0) ...[
          Text(
            l10n.dangLocTheoSoBe(soBeNhapTay),
            style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.itemGap),
        ],
        if (danhSach.isEmpty) _ChuaCoBe(onThemBe: onThemBe),
        for (final be in danhSach) ...[
          _TheBe(
            be: be,
            chon: daChon.contains(be.id),
            khoa: chiNhanCho && be.species == PetSpecies.cat,
            onTap: () => onDoiChon(be),
          ),
          const SizedBox(height: AppSpacing.itemGap),
        ],
        if (chon.isNotEmpty)
          Text(
            _tomTat(l10n, chon),
            style: AppTextStyles.label.copyWith(color: AppColors.primaryColor),
          ),
      ],
    );
  }

  String _tomTat(AppLocalizations l10n, List<Pet> chon) {
    final coCho = chon.any((p) => p.species == PetSpecies.dog);
    final coMeo = chon.any((p) => p.species == PetSpecies.cat);
    final nangNhat = chon
        .map((p) => p.weightKg)
        .reduce((a, b) => a > b ? a : b);
    return [
      l10n.dangChonSoBe(chon.length),
      if (coCho && coMeo)
        l10n.loaiChoVaMeo
      else if (coCho)
        l10n.loaiCho
      else
        l10n.loaiMeo,
      if (chon.length > 1) l10n.nhanTuSoBeCungLuc(chon.length),
      l10n.toiSoKg(canNangGon(nangNhat)),
    ].join(' · ');
  }
}

class _ChuaCoBe extends StatelessWidget {
  const _ChuaCoBe({required this.onThemBe});

  final VoidCallback onThemBe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      nen: AppColors.cardMint,
      vien: false,
      padding: const EdgeInsets.all(AppSpacing.itemGap),
      child: Row(
        children: [
          const Icon(
            Icons.pets_outlined,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Text(l10n.chuaCoThuCungNao, style: AppTextStyles.captionSm),
          ),
          TextButton(
            onPressed: onThemBe,
            child: Text(
              l10n.themBe,
              style: AppTextStyles.label.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _TheBe extends StatelessWidget {
  const _TheBe({
    required this.be,
    required this.chon,
    required this.onTap,
    this.khoa = false,
  });

  final Pet be;
  final bool chon;
  final VoidCallback onTap;
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    if (khoa) return Opacity(opacity: 0.4, child: _the(context));
    return _the(context);
  }

  Widget _the(BuildContext context) {
    return Material(
      color: chon ? AppColors.cardMint : AppColors.surface,
      elevation: chon ? 0 : 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        side: BorderSide(
          color: chon ? AppColors.primaryColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: khoa ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.itemGap),
          child: Row(
            children: [
              PetAvatar(imageUrl: be.avatar, name: be.name, size: 40),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(be.name, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      petSummary(context, be),
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Checkbox(
                value: chon,
                onChanged: khoa ? null : (_) => onTap(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
