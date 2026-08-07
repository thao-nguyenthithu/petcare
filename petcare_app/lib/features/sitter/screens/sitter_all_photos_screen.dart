import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/features/auth/providers/profile_refresh.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/features/sitter/widgets/profile/photo_add_tile.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn Tất cả ảnh của NCC
class SitterAllPhotosScreen extends ConsumerStatefulWidget {
  const SitterAllPhotosScreen({super.key});

  @override
  ConsumerState<SitterAllPhotosScreen> createState() =>
      _SitterAllPhotosScreenState();
}

class _SitterAllPhotosScreenState extends ConsumerState<SitterAllPhotosScreen> {
  bool _chonMode = false;
  final Set<int> _daChon = {};

  void _thongBao(String noiDung) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(noiDung)));
  }

  Future<void> _themAnh() async {
    final l10n = context.l10n;
    final kq = await showAppLoading(
      context,
      ref.read(sitterMeProvider.notifier).chonVaThemAnh,
    );
    // `dayAnh` là chưa tải tấm nào, các nhánh còn lại đều có thể đã tải
    switch (kq) {
      case KetQuaThemAnh.dayAnh:
        _thongBao(l10n.daDatToiDaAnh('$maxSitterPhotos'));
      case KetQuaThemAnh.motPhan:
        _lamMoiTrangCongKhai();
        _thongBao(l10n.daDatToiDaAnh('$maxSitterPhotos'));
      case KetQuaThemAnh.quaNang:
        _lamMoiTrangCongKhai();
        _thongBao(l10n.loiAnhQuaNang('$mbAnhToiDa'));
      case KetQuaThemAnh.loi:
        _thongBao(l10n.luuThatBai);
      case KetQuaThemAnh.thanhCong:
        _lamMoiTrangCongKhai();
      case KetQuaThemAnh.huy:
        break;
    }
  }

  void _lamMoiTrangCongKhai() =>
      ref.refreshProfileData(boQua: [sitterMeProvider]);

  void _thoatChon() => setState(() {
    _chonMode = false;
    _daChon.clear();
  });

  void _toggle(int i) => setState(() {
    if (!_daChon.remove(i)) _daChon.add(i);
  });

  Future<void> _xoa(List<SitterPhotoItem> anh) async {
    final l10n = context.l10n;
    final ids = [
      for (final i in _daChon)
        if (i < anh.length) anh[i].id,
    ];
    if (ids.isEmpty) return;
    try {
      await ref.read(sitterMeProvider.notifier).xoaAnh(ids);
      _lamMoiTrangCongKhai();
      _thoatChon();
    } catch (_) {
      _thongBao(l10n.luuThatBai);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(sitterMeProvider);
    final anh = async.value?.photos ?? const <SitterPhotoItem>[];
    // Ảnh cho trình xem, kèm ngày đăng để hiện dưới tiêu đề
    final anhXem = [
      for (final a in anh) PhotoItem.mang(a.url, ngayThem: a.ngayThem),
    ];
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.tatCaAnh,
            onBack: _chonMode ? _thoatChon : null,
            action: anh.isEmpty
                ? null
                : TextButton(
                    onPressed: () => _chonMode
                        ? _thoatChon()
                        : setState(() => _chonMode = true),
                    child: Text(_chonMode ? l10n.xong : l10n.chon),
                  ),
          ),
          const AppDongKe(),
        ],
      ),
      body: async.when(
        loading: () => const AppSkeletonList(soThe: 3, caoThe: 120),
        error: (_, _) => Center(child: Text(l10n.khongTaiDuocDuLieu)),
        data: (_) => GridView.builder(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding + MediaQuery.of(context).padding.bottom,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.itemGap,
            crossAxisSpacing: AppSpacing.itemGap,
          ),
          itemCount: anh.length + (_chonMode ? 0 : 1),
          itemBuilder: (_, i) {
            if (i >= anh.length) {
              return PhotoAddTile(onTap: _themAnh);
            }
            return _Tile(
              url: anh[i].url,
              chonMode: _chonMode,
              daChon: _daChon.contains(i),
              onTap: () => _chonMode
                  ? _toggle(i)
                  : showPhotoViewer(context, anh: anhXem, viTri: i),
              onLongPress: () {
                if (!_chonMode) {
                  setState(() {
                    _chonMode = true;
                    _daChon.add(i);
                  });
                }
              },
            );
          },
        ),
      ),
      bottomBar: _chonMode && _daChon.isNotEmpty
          ? BottomActionBar(
              child: AppButton(
                text: l10n.xoaNAnh('${_daChon.length}'),
                icon: Icons.delete_outline,
                color: AppColors.error,
                height: 52,
                onTapAsync: () => _xoa(anh),
              ),
            )
          : null,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.url,
    required this.chonMode,
    required this.daChon,
    required this.onTap,
    required this.onLongPress,
  });

  final String url;
  final bool chonMode;
  final bool daChon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheWidth: beRongCache(
                context,
                (MediaQuery.sizeOf(context).width -
                        2 * AppSpacing.screenPadding -
                        2 * AppSpacing.itemGap) /
                    3,
              ),
              placeholder: (_, _) =>
                  const ColoredBox(color: AppColors.cardMint),
              errorWidget: (_, _, _) =>
                  const ColoredBox(color: AppColors.cardMint),
            ),
          ),
          if (daChon)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
            ),
          if (chonMode)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: daChon
                      ? AppColors.primaryColor
                      : AppColors.textWhite.withValues(alpha: 0.54),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textWhite, width: 1.5),
                ),
                child: daChon
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.textWhite,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
