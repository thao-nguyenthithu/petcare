import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/features/sitter/widgets/profile/photo_add_tile.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';

// Mục Ảnh trong màn sửa hồ sơ tối đa 2 hàng
class SitterPhotosSection extends StatelessWidget {
  const SitterPhotosSection({
    super.key,
    required this.anh,
    required this.onThem,
  });

  final List<SitterPhotoItem> anh;
  final VoidCallback onThem;

  // Số ảnh hiện trong màn sửa trước khi phải bấm Xem thêm
  static const int _soHien = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hienThi = anh.take(_soHien).toList();
    final conCho = anh.length < _soHien;
    // Ảnh cho trình xem, kèm ngày đăng để hiện dưới tiêu đề
    final anhXem = [
      for (final a in anh) PhotoItem.mang(a.url, ngayThem: a.ngayThem),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.anh, style: AppTextStyles.label),
            const Spacer(),
            if (anh.isNotEmpty)
              GestureDetector(
                onTap: () => context.push(AppRoutes.sitterAllPhotos),
                child: Text(
                  '${l10n.xemThem} (${anh.length})',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        LayoutBuilder(
          builder: (context, c) {
            final canh = (c.maxWidth - 2 * AppSpacing.itemGap) / 3;
            return Wrap(
              spacing: AppSpacing.itemGap,
              runSpacing: AppSpacing.itemGap,
              children: [
                for (final (i, item) in hienThi.indexed)
                  GestureDetector(
                    onTap: () =>
                        showPhotoViewer(context, anh: anhXem, viTri: i),
                    child: SizedBox(
                      width: canh,
                      height: canh,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.radius14),
                        child: CachedNetworkImage(
                          imageUrl: item.url,
                          fit: BoxFit.cover,
                          memCacheWidth: beRongCache(context, canh),
                          placeholder: (_, _) =>
                              const ColoredBox(color: AppColors.cardMint),
                          errorWidget: (_, _, _) =>
                              const ColoredBox(color: AppColors.cardMint),
                        ),
                      ),
                    ),
                  ),
                if (conCho) PhotoAddTile(canh: canh, onTap: onThem),
              ],
            );
          },
        ),
      ],
    );
  }
}
