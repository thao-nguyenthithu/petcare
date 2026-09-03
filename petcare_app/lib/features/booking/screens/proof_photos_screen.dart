import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/don_hien_hanh.dart';
import 'package:petcare_app/shared/utils/tai_anh_ve_may.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

// Màn Ảnh minh chứng của phiên tắm và cắt tỉa, chia nhóm trước và sau khi làm
class ProofPhotosScreen extends ConsumerWidget {
  const ProofPhotosScreen({super.key, required this.banChup});

  final OwnerBookingDetail banChup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final don = donHienHanh(context, ref, banChup);
    final truoc = don.anhTruoc;
    final sau = don.anhSau;
    final nhatKy = don.anhNhatKy;
    final tatCa = [...truoc, ...sau, ...nhatKy];
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.anhMinhChung,
            subtitle: l10n.maDonSoBeSoAnh(
              don.maDon,
              '${don.pets.length}',
              '${tatCa.length}',
            ),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 18, bottom: 24),
        children: [
          if (tatCa.isEmpty)
            FlatSection(child: AppNoteBox(text: l10n.chuaCoAnhMinhChung)),
          if (truoc.isNotEmpty)
            FlatSection(
              child: _Nhom(
                tieuDe: l10n.anhTruocKhiLam('${truoc.length}'),
                anh: truoc,
                tatCa: tatCa,
              ),
            ),
          if (sau.isNotEmpty) ...[
            const SizedBox(height: 22),
            FlatSection(
              child: _Nhom(
                tieuDe: l10n.anhSauKhiLam('${sau.length}'),
                anh: sau,
                tatCa: tatCa,
              ),
            ),
          ],
          if (nhatKy.isNotEmpty) ...[
            if (truoc.isNotEmpty || sau.isNotEmpty) const SizedBox(height: 22),
            FlatSection(
              child: _Nhom(
                tieuDe: l10n.nhatKyCoNAnh('${nhatKy.length}'),
                anh: nhatKy,
                tatCa: tatCa,
              ),
            ),
          ],
          const SizedBox(height: 20),
          FlatSection(child: AppNoteBox(text: l10n.ghiChuAnhMinhChung)),
        ],
      ),
      bottomBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutralLight)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
            child: AppButton(
              text: l10n.taiAnhVeMay,
              outlined: true,
              height: 50,
              mauChu: AppColors.primaryColor,
              onTap: () => taiAnhVeMay(context, [...truoc, ...sau]),
            ),
          ),
        ),
      ),
    );
  }
}

// Ba ô một hàng: ảnh bằng chứng cần nhìn được cả tập, không cần từng tấm thật to
const int _soCot = 3;
const double _khe = 10;

// Một nhóm ảnh
class _Nhom extends StatelessWidget {
  const _Nhom({required this.tieuDe, required this.anh, required this.tatCa});

  final String tieuDe;
  final List<String> anh;

  // Cả tập ảnh của đơn, để mở trình xem là vuốt được sang nhóm khác
  final List<String> tatCa;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe, style: AppTextStyles.h3),
        const SizedBox(height: 12),
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
          onTap: url.isEmpty ? null : onTap,
          child: url.isEmpty
              ? const Center(
                  child: Icon(
                    Icons.pets,
                    color: AppColors.primaryColor,
                    size: 30,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: beRongCache(context, canh),
                  placeholder: (_, _) =>
                      const ColoredBox(color: AppColors.cardMint),
                  errorWidget: (_, _, _) =>
                      const ColoredBox(color: AppColors.cardMint),
                ),
        ),
      ),
    );
  }
}
