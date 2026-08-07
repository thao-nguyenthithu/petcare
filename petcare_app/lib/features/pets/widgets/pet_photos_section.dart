import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/widgets/pet_photo_strip.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

// Khối Ảnh của bé ở bước 1
class PetPhotosSection extends StatelessWidget {
  const PetPhotosSection({
    super.key,
    required this.anh,
    required this.onThem,
    required this.onXemAnh,
  });

  final List<PetPhoto> anh;
  final VoidCallback onThem;
  final ValueChanged<int> onXemAnh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.anhCuaBe, style: AppTextStyles.h3)),
            Text(
              l10n.soAnhTrenToiDa('${anh.length}', '$maxPetPhotos'),
              style: AppTextStyles.label,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.moTaAnhCuaBe, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.labelGap),
        PetPhotoStrip(anh: anh, onThem: onThem, onXemAnh: onXemAnh),
        const SizedBox(height: AppSpacing.labelGap),
        AppNoteBox(text: l10n.ghiChuAnhDaiDien),
      ],
    );
  }
}
