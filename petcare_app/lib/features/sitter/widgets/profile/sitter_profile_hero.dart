import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/widgets/page_dots.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/features/sitter/widgets/profile/circle_icon_button.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';

// Ảnh bìa trang cá nhân NCC
class SitterProfileHero extends StatefulWidget {
  const SitterProfileHero({super.key, required this.photos, this.onEdit});

  final List<SitterPhotoItem> photos;

  final VoidCallback? onEdit;

  @override
  State<SitterProfileHero> createState() => _SitterProfileHeroState();
}

class _SitterProfileHeroState extends State<SitterProfileHero> {
  final _pc = PageController();
  int _idx = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    // Ảnh cho trình xem, kèm ngày đăng để hiện dưới tiêu đề
    final anhXem = [
      for (final p in photos) PhotoItem.mang(p.url, ngayThem: p.ngayThem),
    ];
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          if (photos.isEmpty)
            const Positioned.fill(
              child: ColoredBox(
                color: AppColors.cardMint,
                child: Center(
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: PageView.builder(
                controller: _pc,
                itemCount: photos.length,
                onPageChanged: (i) => setState(() => _idx = i),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => showPhotoViewer(context, anh: anhXem, viTri: i),
                  child: CachedNetworkImage(
                    imageUrl: photos[i].url,
                    fit: BoxFit.cover,
                    memCacheWidth: beRongCache(
                      context,
                      MediaQuery.sizeOf(context).width,
                    ),
                    placeholder: (_, _) =>
                        const ColoredBox(color: AppColors.cardMint),
                    errorWidget: (_, _, _) =>
                        const ColoredBox(color: AppColors.cardMint),
                  ),
                ),
              ),
            ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 110,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x59000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                  ),
                  const Spacer(),
                  if (widget.onEdit != null)
                    CircleIconButton(
                      icon: Icons.edit_outlined,
                      onTap: widget.onEdit!,
                    ),
                ],
              ),
            ),
          ),
          if (photos.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: PageDots(
                count: photos.length,
                current: _idx,
                dotSize: 6,
                activeWidth: 6,
                gap: 7,
                mauHoatDong: AppColors.textWhite,
                mauTinh: AppColors.textWhite.withValues(alpha: 0.5),
              ),
            ),
          if (photos.length > 1)
            Positioned(
              right: 16,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_idx + 1} / ${photos.length}',
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
