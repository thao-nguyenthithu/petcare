import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/widgets/dashed_border.dart';

const double _canhO = 84;

// Dải ảnh của bé ở form
class PetPhotoStrip extends StatelessWidget {
  const PetPhotoStrip({
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
    final conCho = anh.length < maxPetPhotos;
    return SizedBox(
      height: _canhO + AppSpacing.blockGap,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (conCho) ...[
            _NutThemAnh(onTap: onThem),
            const SizedBox(width: AppSpacing.labelGap),
          ],
          for (final (i, item) in anh.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.labelGap),
            Column(
              children: [
                Material(
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onXemAnh(i),
                    onLongPress: () => onXemAnh(i),
                    child: Image.memory(
                      item.bytes,
                      width: _canhO,
                      height: _canhO,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (i == 0) ...[
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    l10n.anhDaiDien,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NutThemAnh extends StatelessWidget {
  const _NutThemAnh({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: CustomPaint(
          painter: const DashedBorderPainter(
            boGoc: AppRadius.radius14,
            doDay: 1.4,
          ),
          child: SizedBox(
            width: _canhO,
            height: _canhO,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.photo_camera_outlined,
                  size: 22,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: AppSpacing.textGap),
                Text(
                  l10n.themAnh,
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
