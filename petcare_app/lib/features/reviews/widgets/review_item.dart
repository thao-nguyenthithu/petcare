import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/shared/widgets/review_stars.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const int _soAnhBayRa = 4;
const double _duongKinhAvatarBe = 32;

class ReviewItem extends StatelessWidget {
  const ReviewItem({
    super.key,
    required this.review,
    required this.nhanPhanHoi,
    this.tienTo,
    this.duoi,
    this.onMoDon,
  });

  final SitterReview review;
  final String nhanPhanHoi;
  final String? tienTo;
  final Widget? duoi;

  // Lối về đúng đơn của bài, chỉ có ở trang đánh giá của chủ nuôi
  final VoidCallback? onMoDon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = review;
    final phu = [
      r.service,
      if (r.pets.length > 1) l10n.soBe('${r.pets.length}'),
      r.time,
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tienTo case final t?)
                    Text.rich(
                      TextSpan(
                        text: '$t ',
                        style: AppTextStyles.captionSm,
                        children: [
                          TextSpan(text: r.name, style: AppTextStyles.label),
                        ],
                      ),
                    )
                  else
                    Text(r.name, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.textGap),
                  ReviewStars(so: r.stars),
                  const SizedBox(height: AppSpacing.textGap),
                  if (onMoDon case final mo?)
                    InkWell(
                      onTap: mo,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              phu,
                              style: AppTextStyles.captionSm.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: AppColors.primaryColor,
                          ),
                        ],
                      ),
                    )
                  else
                    Text(phu, style: AppTextStyles.captionSm),
                ],
              ),
            ),
            if (r.pets.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.labelGap),
              PetAvatarStack(pets: r.pets, size: _duongKinhAvatarBe),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        Text(
          r.text,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        if (r.coAnh) ...[
          const SizedBox(height: AppSpacing.itemGap),
          _DaiAnh(anh: r.anh),
        ],
        if (r.phanHoi case final ph?) ...[
          const SizedBox(height: AppSpacing.itemGap),
          _KhoiPhanHoi(nhan: nhanPhanHoi, phanHoi: ph),
        ],
        if (duoi case final d?) ...[
          const SizedBox(height: AppSpacing.itemGap),
          d,
        ],
      ],
    );
  }
}

class _DaiAnh extends StatelessWidget {
  const _DaiAnh({required this.anh});

  final List<String> anh;

  void _xem(BuildContext context, int viTri) {
    showPhotoViewer(
      context,
      anh: [for (final u in anh) PhotoItem.mang(u)],
      viTri: viTri,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hien = anh.take(_soAnhBayRa).toList();
    final con = anh.length - hien.length;

    return LayoutBuilder(
      builder: (context, rang) {
        const khe = AppSpacing.labelGap;
        final canh = (rang.maxWidth - khe * (_soAnhBayRa - 1)) / _soAnhBayRa;
        return Row(
          children: [
            for (final (i, url) in hien.indexed)
              _O(
                url: url,
                canh: canh,
                le: i == hien.length - 1 ? 0 : khe,
                con: i == _soAnhBayRa - 1 ? con : 0,
                onTap: () => _xem(context, i),
              ),
          ],
        );
      },
    );
  }
}

class _O extends StatelessWidget {
  const _O({
    required this.url,
    required this.canh,
    required this.le,
    required this.con,
    required this.onTap,
  });

  final String url;
  final double canh;
  final double le;
  final int con;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: le),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: SizedBox(
            width: canh,
            height: canh,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (url.isEmpty)
                  ColoredBox(
                    color: AppColors.neutralLight,
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textSecondary,
                      size: canh / 3,
                    ),
                  )
                else
                  PhotoThumb(anh: PhotoItem.mang(url), canh: canh),
                if (con > 0)
                  ColoredBox(
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                    child: Center(
                      child: Text(
                        '+$con',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
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

class _KhoiPhanHoi extends StatelessWidget {
  const _KhoiPhanHoi({required this.nhan, required this.phanHoi});
  final String nhan;
  final PhanHoiDanhGia phanHoi;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      nen: AppColors.background,
      vien: false,
      padding: const EdgeInsets.all(AppSpacing.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$nhan · ${phanHoi.thoiDiem}', style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.textGap),
          Text(phanHoi.noiDung, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}
