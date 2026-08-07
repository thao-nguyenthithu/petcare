import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

// Hỏi trước khi xoá hồ sơ một bé
Future<bool> showDeletePetSheet(BuildContext context, Pet pet) async {
  final ketQua = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius20),
      ),
    ),
    builder: (_) => _NoiDung(pet: pet),
  );
  return ketQua ?? false;
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.pet});

  final Pet pet;

  int get _soAnh =>
      pet.anh.length + [for (final muc in pet.phongBenh) ...muc.anh].length;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.groupGap + mq.viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.xoaHoSoCuaBeHoi(pet.name), style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.itemGap),
          PetSummaryRow(pet: pet),
          const SizedBox(height: AppSpacing.itemGap),
          _KhoiMatDuLieu(soAnh: _soAnh),
          const SizedBox(height: AppSpacing.itemGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Expanded(
                child: Text(
                  l10n.ghiChuDonDaHoanThanh(pet.name),
                  style: AppTextStyles.captionSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          AppButton(
            text: l10n.xoaHoSoCuaBe(pet.name),
            icon: Icons.delete_outline,
            color: AppColors.accent,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.textGap),
          AppButton(
            text: l10n.giuLai,
            flat: true,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

// Khối cam liệt kê những thứ mất đi khi xoá
class _KhoiMatDuLieu extends StatelessWidget {
  const _KhoiMatDuLieu({required this.soAnh});

  final int soAnh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: nenCanhBao,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.xoaXongBanMat,
            style: AppTextStyles.label.copyWith(color: AppColors.accent),
          ),
          for (final dong in [
            l10n.soAnhCuaBe('$soAnh'),
            l10n.soPhongBenhVaAnhPhieu,
            l10n.luuYChamSocDaNhap,
          ]) ...[
            const SizedBox(height: AppSpacing.labelGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.labelGap),
                Expanded(
                  child: Text(
                    dong,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Hàng nhận diện bé dùng ở cả hai sheet xoá
class PetSummaryRow extends StatelessWidget {
  const PetSummaryRow({super.key, required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PetAvatar(imageUrl: pet.avatar, name: pet.name, size: 44),
        const SizedBox(width: AppSpacing.itemGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pet.name, style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(petSummary(context, pet), style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }
}
