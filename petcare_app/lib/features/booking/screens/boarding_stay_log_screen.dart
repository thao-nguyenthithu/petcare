import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/don_hien_hanh.dart';
import 'package:petcare_app/shared/utils/tai_anh_ve_may.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const double _coAnh = 88;

// Màn Nhật ký cả kỳ trông giữ
class BoardingStayLogScreen extends ConsumerWidget {
  const BoardingStayLogScreen({super.key, required this.banChup});

  final OwnerBookingDetail banChup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final don = donHienHanh(context, ref, banChup);
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.nhatKyKyGiu,
            subtitle:
                '${don.maDon} · ${l10n.soBe('${don.pets.length}')} · '
                '${l10n.nAnh('${don.tongAnh}')}',
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          for (final (i, ngay) in don.nhatKyKyGiu.indexed) ...[
            if (i != 0) const SizedBox(height: 20),
            FlatSection(child: _NhomNgay(ngay: ngay)),
          ],
        ],
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          text: l10n.taiTatCaAnhVeMay,
          outlined: true,
          mauChu: AppColors.primaryColor,
          onTap: () => taiAnhVeMay(context, [
            for (final ngay in don.nhatKyKyGiu)
              for (final muc in ngay.muc) ...muc.anh,
          ]),
        ),
      ),
    );
  }
}

class _NhomNgay extends StatelessWidget {
  const _NhomNgay({required this.ngay});

  final NgayNhatKyGiu ngay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ngay.nhan,
          style: AppTextStyles.label.copyWith(color: AppColors.primaryColor),
        ),
        for (final m in ngay.muc) ...[
          const SizedBox(height: 12),
          Text(
            l10n.soAnhLuc(m.gio, '${m.anh.length}'),
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (i, url) in m.anh.indexed) ...[
                  if (i != 0) const SizedBox(width: 10),
                  _Anh(url: url),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '"${m.ghiChu}"',
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class _Anh extends StatelessWidget {
  const _Anh({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        width: _coAnh,
        height: _coAnh,
        color: AppColors.cardMint,
        alignment: Alignment.center,
        child: url.isEmpty
            ? const Icon(Icons.pets, color: AppColors.primaryColor, size: 26)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: beRongCache(context, _coAnh),
                placeholder: (_, _) =>
                    const ColoredBox(color: AppColors.cardMint),
                errorWidget: (_, _, _) =>
                    const ColoredBox(color: AppColors.cardMint),
              ),
      ),
    );
  }
}
