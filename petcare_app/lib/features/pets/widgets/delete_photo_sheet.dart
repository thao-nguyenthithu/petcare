import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/shared/widgets/photo_item.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Hỏi trước khi xoá một ảnh của bé
Future<bool> showDeletePhotoSheet(
  BuildContext context, {
  required PetPhoto anh,
  required int viTri,
  required int tong,
  required bool laDaiDien,
}) async {
  final ketQua = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius20),
      ),
    ),
    builder: (sheetContext) =>
        _NoiDung(anh: anh, viTri: viTri, tong: tong, laDaiDien: laDaiDien),
  );
  return ketQua ?? false;
}

class _NoiDung extends StatelessWidget {
  const _NoiDung({
    required this.anh,
    required this.viTri,
    required this.tong,
    required this.laDaiDien,
  });

  final PetPhoto anh;
  final int viTri;
  final int tong;
  final bool laDaiDien;

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
          Text(l10n.xoaAnhNay, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.itemGap),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
                child: PhotoThumb(anh: anh.item, canh: 64),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.anhSoTrenToiDa('${viTri + 1}', '$tong'),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      l10n.themNgay(ngayThangNam(anh.addedAt)),
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (laDaiDien) ...[
            const SizedBox(height: AppSpacing.itemGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: AppSpacing.labelGap),
                Expanded(
                  child: Text(
                    l10n.canhBaoXoaAnhDaiDien,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.stackGap),
          AppButton(
            text: l10n.xoaAnh,
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
