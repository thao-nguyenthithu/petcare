import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

enum HuongXuLyLoai { timNguoiCham, themHoSoBe }

Future<HuongXuLyLoai?> showBlockSpeciesSheet(
  BuildContext context, {
  required String tenNcc,
  required SitterServices services,
  required List<Pet> pets,
}) {
  return showModalBottomSheet<HuongXuLyLoai>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        _BlockSpeciesSheet(tenNcc: tenNcc, services: services, pets: pets),
  );
}

class _BlockSpeciesSheet extends StatelessWidget {
  const _BlockSpeciesSheet({
    required this.tenNcc,
    required this.services,
    required this.pets,
  });

  final String tenNcc;
  final SitterServices services;
  final List<Pet> pets;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    // Loài các bé đang có, ở đây luôn chỉ có một loài vì mọi bé đều bị chặn
    final loaiBe = pets.first.species == PetSpecies.cat ? l10n.meo : l10n.cho;
    // Các loài NCC nhận, gộp từ mọi dịch vụ đang bật
    final nhan = <PetKind>{
      for (final t in loaiDangNhan(services)) loaiNhanCua(services, t),
    };
    final moTaNhan = nhan.contains(PetKind.both)
        ? l10n.choVaMeoDai
        : nhan.map((k) => l10n.chiLoai(petKindLabel(context, k))).join(', ');
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.blockGap + mq.viewPadding.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.nccKhongNhanLoai(tenNcc, loaiBe.toLowerCase()),
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              l10n.moTaChanLoai('${pets.length}', loaiBe.toLowerCase()),
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            _HangDoiChieu(nhan: l10n.nccNhan(tenNcc), giaTri: moTaNhan),
            const SizedBox(height: AppSpacing.labelGap),
            _HangDoiChieu(
              nhan: l10n.beCuaBan,
              giaTri:
                  '${pets.map((p) => p.name).join(', ')} · '
                  '${loaiBe.toLowerCase()}',
            ),
            const SizedBox(height: AppSpacing.stackGap),
            Text(l10n.banCoThe, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.labelGap),
            AppNoteBox(text: l10n.huongTimNccNhanLoai(loaiBe.toLowerCase())),
            const SizedBox(height: AppSpacing.labelGap),
            AppNoteBox(text: l10n.huongThemHoSoBeKhac),
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: l10n.timNguoiCham,
              onTap: () => Navigator.pop(context, HuongXuLyLoai.timNguoiCham),
            ),
            const SizedBox(height: AppSpacing.itemGap),
            AppButton(
              text: l10n.themHoSoThuCung,
              outlined: true,
              onTap: () => Navigator.pop(context, HuongXuLyLoai.themHoSoBe),
            ),
            const SizedBox(height: AppSpacing.labelGap),
            AppButton(
              text: l10n.dong,
              flat: true,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Một hàng đối chiếu nhãn bên trái, giá trị bên phải trên nền xám nhạt
class _HangDoiChieu extends StatelessWidget {
  const _HangDoiChieu({required this.nhan, required this.giaTri});

  final String nhan;
  final String giaTri;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      nen: AppColors.background,
      vien: false,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
          const SizedBox(width: AppSpacing.itemGap),
          Text(giaTri, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
