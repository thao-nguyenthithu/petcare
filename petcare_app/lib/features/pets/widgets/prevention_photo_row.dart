import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/widgets/dashed_border.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

const int maxPreventionPhotos = 5;

const double _canhO = 72;

// Hàng ảnh phiếu tiêm ở form mũi tiêm
class PreventionPhotoRow extends StatelessWidget {
  const PreventionPhotoRow({
    super.key,
    required this.anh,
    required this.onThem,
    required this.onXem,
  });

  final List<PhotoItem> anh;
  final VoidCallback onThem;
  final ValueChanged<int> onXem;

  @override
  Widget build(BuildContext context) {
    final conCho = anh.length < maxPreventionPhotos;
    return SizedBox(
      height: _canhO,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (conCho) ...[
            _OThem(onTap: onThem),
            const SizedBox(width: AppSpacing.labelGap),
          ],
          for (final (i, item) in anh.indexed) ...[
            if (i > 0) const SizedBox(width: AppSpacing.labelGap),
            Material(
              color: AppColors.cardMint,
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onXem(i),
                child: SizedBox(
                  width: _canhO,
                  height: _canhO,
                  child: PhotoThumb(anh: item, canh: _canhO),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OThem extends StatelessWidget {
  const _OThem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: CustomPaint(
          painter: const DashedBorderPainter(
            boGoc: AppRadius.radius14,
            doDay: 1.2,
          ),
          child: const SizedBox(
            width: _canhO,
            height: _canhO,
            child: Icon(
              Icons.photo_camera_outlined,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
