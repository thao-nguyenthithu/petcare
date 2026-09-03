import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Ba ô một hàng, đủ nhìn mà không chiếm hết màn
const int _soCot = 3;
const double _khe = 10;

// Màn Minh chứng, phải có ảnh Sau mới kết thúc được
class SitterEvidenceScreen extends ConsumerStatefulWidget {
  const SitterEvidenceScreen({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  ConsumerState<SitterEvidenceScreen> createState() =>
      _SitterEvidenceScreenState();
}

class _SitterEvidenceScreenState extends ConsumerState<SitterEvidenceScreen> {
  bool _dangGui = false;

  List<String> get _tatCa => [
    ...widget.don.anhTruoc,
    ...widget.don.anhNhatKy,
    ...widget.don.anhSau,
  ];

  Future<void> _them(Future<KetQuaMotAnh> Function() lay) async {
    final chon = await lay();
    if (!mounted) return;
    if (chon.quaNang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
      return;
    }
    final bytes = chon.anh;
    if (bytes == null) return;
    await _gui(bytes);
  }

  Future<void> _gui(Uint8List bytes) async {
    final l10n = context.l10n;
    final id = widget.don.bookingId;
    setState(() => _dangGui = true);
    await chayHanhDongDon(
      context,
      ref,
      id,
      (s) => s.guiAnhPhien(id, anh: anhMultipart([bytes], 'evidence')),
      nhanBaoXong: l10n.daGuiAnh,
    );
    if (mounted) setState(() => _dangGui = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = widget.don;
    final tatCa = _tatCa;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.minhChungDichVu),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          if (tatCa.isEmpty)
            _NoteBanner(text: l10n.chuaCoAnhMinhChung)
          else ...[
            _Nhom(
              tieuDe: l10n.anhTruocKhiLam('${don.anhTruoc.length}'),
              anh: don.anhTruoc,
              tatCa: tatCa,
            ),
            _Nhom(
              tieuDe: l10n.anhTrongPhien('${don.anhNhatKy.length}'),
              anh: don.anhNhatKy,
              tatCa: tatCa,
            ),
            _Nhom(
              tieuDe: l10n.anhSauKhiLam('${don.anhSau.length}'),
              anh: don.anhSau,
              tatCa: tatCa,
            ),
          ],
          const SizedBox(height: AppSpacing.blockGap),
          AppButton(
            text: l10n.chupAnh,
            icon: Icons.photo_camera_outlined,
            dangTai: _dangGui,
            onTap: () => _them(chupMotAnh),
          ),
          const SizedBox(height: 8),
          AppButton(
            text: l10n.chonTuThuVien,
            icon: Icons.photo_library_outlined,
            outlined: true,
            color: AppColors.primaryColor,
            enabled: !_dangGui,
            onTap: () => _them(chonMotAnh),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _NoteBanner(text: l10n.minhChungGhiChu),
        ],
      ),
    );
  }
}

// Một nhóm ảnh, nhóm rỗng thì không chiếm chỗ
class _Nhom extends StatelessWidget {
  const _Nhom({required this.tieuDe, required this.anh, required this.tatCa});

  final String tieuDe;
  final List<String> anh;
  final List<String> tatCa;

  @override
  Widget build(BuildContext context) {
    if (anh.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tieuDe, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.itemGap),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: anh.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _soCot,
              crossAxisSpacing: _khe,
              mainAxisSpacing: _khe,
            ),
            itemBuilder: (_, i) => _O(
              url: anh[i],
              onTap: () => showPhotoViewer(
                context,
                anh: [for (final u in tatCa) PhotoItem.mang(u)],
                viTri: tatCa.indexOf(anh[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _O extends StatelessWidget {
  const _O({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canh =
        (MediaQuery.sizeOf(context).width -
            2 * AppSpacing.screenPadding -
            (_soCot - 1) * _khe) /
        _soCot;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Material(
        color: AppColors.cardMint,
        child: InkWell(
          onTap: onTap,
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            memCacheWidth: beRongCache(context, canh),
            placeholder: (_, _) => const ColoredBox(color: AppColors.cardMint),
            errorWidget: (_, _, _) =>
                const Icon(Icons.image_outlined, color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }
}

class _NoteBanner extends StatelessWidget {
  const _NoteBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.captionSm)),
        ],
      ),
    );
  }
}
