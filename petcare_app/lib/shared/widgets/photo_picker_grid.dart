import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/dashed_border.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

const double _khe = 10;

// Lưới chọn ảnh dùng chung cho mọi màn có khâu chụp ảnh
class PhotoPickerGrid extends StatelessWidget {
  const PhotoPickerGrid({
    super.key,
    required this.anh,
    required this.tran,
    required this.onDoi,
    this.tieuDe,
    this.soCot = 4,
    this.soOToiDa,
    this.batBuocChup = false,
    this.onThemTuyBien,
  });

  final List<Uint8List> anh;
  final int tran;

  // Trả về danh sách mới sau khi thêm hoặc xoá
  final ValueChanged<List<Uint8List>> onDoi;

  final String? tieuDe;
  final int soCot;

  // Quá số ô này thì ô cuối phủ lớp tối kèm chỉ số cộng thêm
  final int? soOToiDa;

  // Ảnh bằng chứng phải chụp tại chỗ, không cho lấy từ thư viện
  final bool batBuocChup;

  // Màn có camera riêng nhiều tấm thì tự lo khâu chụp, ô thêm chỉ mở màn đó
  final VoidCallback? onThemTuyBien;

  int get _oToiDa => soOToiDa ?? soCot;

  Future<void> _them(BuildContext context) async {
    if (onThemTuyBien case final mo?) return mo();
    final conChoDuoc = tran - anh.length;
    if (conChoDuoc <= 0) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final nguon = batBuocChup
        ? NguonAnh.mayAnh
        : await _hoiNguon(context, conChoDuoc);
    if (nguon == null) return;
    final them = <Uint8List>[];
    var quaNang = 0;
    if (nguon == NguonAnh.mayAnh) {
      final mot = await chupMotAnh();
      if (mot.anh != null) them.add(mot.anh!);
      if (mot.quaNang) quaNang++;
    } else {
      final nhieu = await chonNhieuAnh(conChoDuoc);
      them.addAll(nhieu.anh);
      quaNang += nhieu.quaNang;
    }
    if (quaNang > 0) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
    }
    if (them.isEmpty) return;
    onDoi([...anh, ...them].take(tran).toList());
  }

  Future<NguonAnh?> _hoiNguon(BuildContext context, int conChoDuoc) {
    final l10n = context.l10n;
    return showModalBottomSheet<NguonAnh>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.chupAnh, style: AppTextStyles.body),
              onTap: () => Navigator.pop(context, NguonAnh.mayAnh),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chonTuThuVien, style: AppTextStyles.body),
              subtitle: Text(
                l10n.conChonDuocNAnh('$conChoDuoc'),
                style: AppTextStyles.captionSm,
              ),
              onTap: () => Navigator.pop(context, NguonAnh.thuVien),
            ),
          ],
        ),
      ),
    );
  }

  void _xem(BuildContext context, int viTri) {
    showPhotoViewer(
      context,
      viTri: viTri,
      anh: [for (final b in anh) PhotoItem.bytes(b)],
      hanhDong: [
        PhotoViewerAction(
          icon: Icons.delete_outline,
          label: context.l10n.xoaAnh,
          nguyHiem: true,
          onTap: (i) async {
            final conLai = [...anh]..removeAt(i);
            onDoi(conLai);
            return conLai.isEmpty;
          },
        ),
      ],
    );
  }

  void _xoa(int viTri) => onDoi([...anh]..removeAt(viTri));

  @override
  Widget build(BuildContext context) {
    final hien = anh.take(_oToiDa).toList();
    final du = anh.length - hien.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tieuDe case final t?) ...[
          Text(t, style: AppTextStyles.h3),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, rang) {
            final canh = (rang.maxWidth - _khe * (soCot - 1)) / soCot;
            return Wrap(
              spacing: _khe,
              runSpacing: _khe,
              children: [
                if (anh.length < tran)
                  _ONutThem(
                    canh: canh,
                    daCo: anh.length,
                    tran: tran,
                    onTap: () => _them(context),
                  ),
                for (final (i, bytes) in hien.indexed)
                  _OAnh(
                    bytes: bytes,
                    canh: canh,
                    // Ô cuối gánh phần ảnh bị giấu, bấm vào là xem trọn bộ
                    du: i == hien.length - 1 ? du : 0,
                    onXem: () => _xem(context, i),
                    onXoa: () => _xoa(i),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

enum NguonAnh { mayAnh, thuVien }

class _OAnh extends StatelessWidget {
  const _OAnh({
    required this.bytes,
    required this.canh,
    required this.du,
    required this.onXem,
    required this.onXoa,
  });

  final Uint8List bytes;
  final double canh;
  final int du;
  final VoidCallback onXem;
  final VoidCallback onXoa;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: canh,
      height: canh,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              child: Material(
                color: AppColors.cardMint,
                child: InkWell(
                  onTap: onXem,
                  child: Ink.image(image: MemoryImage(bytes), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          if (du > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  child: ColoredBox(
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                    child: Center(
                      child: Text(
                        '+$du',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: onXoa,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 13,
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

class _ONutThem extends StatelessWidget {
  const _ONutThem({
    required this.canh,
    required this.daCo,
    required this.tran,
    required this.onTap,
  });

  final double canh;
  final int daCo;
  final int tran;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: CustomPaint(
        painter: const DashedBorderPainter(
          boGoc: AppRadius.radius14,
          mau: AppColors.primaryColor,
          doDay: 1.2,
          net: 5,
          ho: 5,
        ),
        child: SizedBox(
          width: canh,
          height: canh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 22, color: AppColors.primaryColor),
              const SizedBox(height: 4),
              Text(
                '$daCo/$tran',
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
