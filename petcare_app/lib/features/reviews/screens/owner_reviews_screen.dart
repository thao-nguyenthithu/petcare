import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/reviews/data/pending_review.dart';
import 'package:petcare_app/features/reviews/providers/reviews_provider.dart';
import 'package:petcare_app/features/reviews/widgets/review_item.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_tab_bar.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';

const int _sapHetHan = 2;
const double _duongKinhAvatarBe = 32;

// Màn Đánh giá của tôi, vào từ tab Tài khoản của chủ nuôi
class OwnerReviewsScreen extends ConsumerWidget {
  const OwnerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final choDanhGia =
        ref.watch(donChoDanhGiaCuaToiProvider).value ?? const <DonChoDanhGia>[];
    final daViet = ref.watch(danhGiaCuaToiProvider).value;

    return DefaultTabController(
      length: 2,
      child: AppScreen(
        backgroundColor: AppColors.surface,
        header: Column(
          children: [
            AppScreenHeader(title: l10n.danhGiaCuaToi),
            AppTabBar(
              cuon: false,
              labels: [
                l10n.nhanChuaDanhGiaSo('${choDanhGia.length}'),
                l10n.nhanDaDanhGiaSo('${daViet?.tong ?? 0}'),
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _TabChoDanhGia(don: choDanhGia),
            _TabDaDanhGia(reviews: daViet?.items ?? const []),
          ],
        ),
      ),
    );
  }
}

class _TabChoDanhGia extends StatelessWidget {
  const _TabChoDanhGia({required this.don});

  final List<DonChoDanhGia> don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (don.isEmpty) {
      return _Rong(
        title: l10n.khongConDonChoDanhGia,
        message: l10n.moTaKhongConDonChoDanhGia,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.stackGap,
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
      ),
      itemCount: don.length + 1,
      separatorBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackGap),
        child: i == 0 ? const SizedBox.shrink() : const AppDongKe(),
      ),
      itemBuilder: (_, i) => i == 0
          ? Text(l10n.nhacHanDanhGia, style: AppTextStyles.captionSm)
          : _DongChoDanhGia(don: don[i - 1]),
    );
  }
}

class _DongChoDanhGia extends StatelessWidget {
  const _DongChoDanhGia({required this.don});

  final DonChoDanhGia don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gap = don.soNgayCon <= _sapHetHan;
    final phu = [
      serviceTypeNameDai(context, don.loai),
      don.tenCacBe,
      l10n.xongLucNgayGio(don.xongNgay, don.xongGio),
    ].where((s) => s.isNotEmpty).join(' · ');

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
                  Text(don.tenNcc, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(phu, style: AppTextStyles.captionSm),
                ],
              ),
            ),
            if (don.pets.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.labelGap),
              PetAvatarStack(pets: don.pets, size: _duongKinhAvatarBe),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        Row(
          children: [
            Expanded(
              child: Text(
                '${l10n.vietDanhGia} · '
                '${l10n.conKhoang(l10n.nNgayNhan('${don.soNgayCon}'))}',
                style: AppTextStyles.captionSm.copyWith(
                  color: gap ? AppColors.accent : null,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.labelGap),
            InkWell(
              onTap: () => context.push(
                AppRoutes.bookingReview,
                extra: (
                  don: (
                    bookingId: don.bookingId,
                    maDon: don.maDon,
                    loai: don.loai,
                    soBe: don.pets.length,
                    tenNcc: don.tenNcc,
                    avatarNcc: don.anhNcc,
                  ),
                  sao: 0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.vietDanhGia,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.textGap),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabDaDanhGia extends StatelessWidget {
  const _TabDaDanhGia({required this.reviews});

  final List<SitterReview> reviews;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (reviews.isEmpty) {
      return _Rong(
        title: l10n.chuaVietDanhGiaNao,
        message: l10n.moTaChuaVietDanhGiaNao,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.stackGap,
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
      ),
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.stackGap),
        child: AppDongKe(),
      ),
      itemBuilder: (_, i) => ReviewItem(
        review: reviews[i],
        tienTo: l10n.banDanhGia,
        nhanPhanHoi: l10n.nguoiChamPhanHoi(reviews[i].name),
      ),
    );
  }
}

class _Rong extends StatelessWidget {
  const _Rong({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppEmptyState(
        icon: Icons.star_outline_rounded,
        title: title,
        message: message,
        circleColor: AppColors.cardMint,
        iconColor: AppColors.accent,
      ),
    );
  }
}
