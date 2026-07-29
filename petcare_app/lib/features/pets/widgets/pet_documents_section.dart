import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

// Số ảnh trên một dòng
const int _soCot = 3;

// Khối Giấy tờ của bé
class PetDocumentsSection extends StatelessWidget {
  const PetDocumentsSection({
    super.key,
    required this.giayTo,
    required this.onXemNhom,
    this.chiLuoiAnh = false,
  });

  final List<PetDocument> giayTo;

  // Mở trình xem ảnh
  final ValueChanged<PetDocumentGroup> onXemNhom;
  final bool chiLuoiAnh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nhom = gomGiayToTheoHangMuc(giayTo);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!chiLuoiAnh) ...[
          Text(l10n.giayToCuaBe, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.labelGap),
          Text(l10n.moTaGiayToCuaBe, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.itemGap),
        ],
        if (nhom.isEmpty)
          Text(l10n.chuaCapNhat, style: AppTextStyles.captionSm)
        else
          LayoutBuilder(
            builder: (_, rang) {
              final rongCot =
                  (rang.maxWidth - AppSpacing.itemGap * (_soCot - 1)) / _soCot;
              return Wrap(
                spacing: AppSpacing.itemGap,
                runSpacing: AppSpacing.stackGap,
                children: [
                  for (final muc in nhom)
                    _ChongAnh(
                      nhom: muc,
                      rongCot: rongCot,
                      onTap: () => onXemNhom(muc),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

// Chồng ảnh của một hạng mục
class _ChongAnh extends StatelessWidget {
  const _ChongAnh({
    required this.nhom,
    required this.rongCot,
    required this.onTap,
  });

  final PetDocumentGroup nhom;
  final double rongCot;
  final VoidCallback onTap;
  static const double _lech = 5;
  static const int _lopToiDa = 3;

  @override
  Widget build(BuildContext context) {
    final soLop = nhom.anh.length < _lopToiDa ? nhom.anh.length : _lopToiDa;
    final tongLech = (soLop - 1) * _lech;
    final canh = rongCot - tongLech;
    return SizedBox(
      width: rongCot,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rongCot,
            height: rongCot,
            child: Stack(
              children: [
                for (var i = soLop - 1; i >= 0; i--)
                  Positioned(
                    left: i * _lech,
                    top: i * _lech,
                    child: _Lop(
                      anh: nhom.anh[i].anh,
                      canh: canh,
                      mo: i > 0,
                      onTap: i == 0 ? onTap : null,
                    ),
                  ),
                if (nhom.anh.length > 1)
                  Positioned(
                    right: tongLech + AppSpacing.textGap,
                    top: AppSpacing.textGap,
                    child: _NhanSoAnh(so: nhom.anh.length),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.textGap),
          Text(
            preventionPhotoLabel(context, nhom.hangMuc),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Một lớp ảnh trong chồng
class _Lop extends StatelessWidget {
  const _Lop({
    required this.anh,
    required this.canh,
    required this.mo,
    required this.onTap,
  });

  final PhotoItem anh;
  final double canh;
  final bool mo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardMint,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.surface, width: 2),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: canh,
          height: canh,
          child: Opacity(
            opacity: mo ? .55 : 1,
            child: PhotoThumb(anh: anh, canh: canh),
          ),
        ),
      ),
    );
  }
}

// Nhãn đếm số ảnh trong chồng
class _NhanSoAnh extends StatelessWidget {
  const _NhanSoAnh({required this.so});

  final int so;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.labelGap,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: Text(
        '$so',
        style: AppTextStyles.captionSm.copyWith(
          color: AppColors.textWhite.withValues(alpha: .8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
