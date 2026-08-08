import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/widgets/delete_pet_sheet.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Chủ nuôi bấm xoá nhưng bé còn đơn chưa kết thúc
Future<bool> showBlockDeletePetSheet(
  BuildContext context,
  Pet pet,
  PetActiveBooking don,
) async {
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
    builder: (_) => _NoiDung(pet: pet, don: don),
  );
  return ketQua ?? false;
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({required this.pet, required this.don});

  final Pet pet;
  final PetActiveBooking don;

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
          Text(l10n.chuaXoaDuocHoSo(pet.name), style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.labelGap),
          Text(l10n.beDangCoDonChuaKetThuc, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.itemGap),
          PetSummaryRow(pet: pet),
          const SizedBox(height: AppSpacing.itemGap),
          _TheDon(don: don),
          const SizedBox(height: AppSpacing.stackGap),
          AppButton(
            text: l10n.xemDonDangChay,
            outlined: true,
            color: AppColors.primaryColor,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: AppSpacing.textGap),
          AppButton(
            text: l10n.dong,
            flat: true,
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

// Thẻ đơn đang chạy: tên dịch vụ kèm người chăm, mã đơn và khung giờ
class _TheDon extends StatelessWidget {
  const _TheDon({required this.don});

  final PetActiveBooking don;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      nen: AppColors.background,
      vien: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${don.tenDichVu} · ${don.tenNcc}',
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${don.maDon} · ${don.moTaThoiGian}',
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          UserAvatar(imageUrl: don.avatarNcc, name: don.tenNcc, size: 44),
        ],
      ),
    );
  }
}
