import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/reviews/providers/reviews_provider.dart';
import 'package:petcare_app/features/reviews/widgets/reply_review_sheet.dart';
import 'package:petcare_app/features/reviews/widgets/review_item.dart';
import 'package:petcare_app/features/reviews/widgets/review_summary.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_tab_bar.dart';

const int _sapHetHan = 3;

class SitterReviewsScreen extends ConsumerStatefulWidget {
  const SitterReviewsScreen({super.key});

  @override
  ConsumerState<SitterReviewsScreen> createState() =>
      _SitterReviewsScreenState();
}

class _SitterReviewsScreenState extends ConsumerState<SitterReviewsScreen> {
  Future<void> _vietPhanHoi(SitterReview review) async {
    final noiDung = await moSheetVietPhanHoi(context, review: review);
    if (noiDung == null || !mounted) return;
    try {
      await ref.read(danhGiaVeToiProvider.notifier).phanHoi(review.id, noiDung);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loiKetNoiMayChu)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trang = ref.watch(danhGiaVeToiProvider).value;
    final reviews = trang?.items ?? const <SitterReview>[];
    final chuaPhanHoi = reviews.where((r) => r.phanHoi == null).toList();
    final thongKe =
        trang?.thongKe ??
        const ThongKeDanhGia(
          diemTrungBinh: 0,
          tongSo: 0,
          phanBoSao: {},
          phanBoDichVu: {},
          soCoAnh: 0,
        );

    return DefaultTabController(
      length: 2,
      child: AppScreen(
        backgroundColor: AppColors.surface,
        header: Column(
          children: [
            AppScreenHeader(title: l10n.danhGiaVeToi),
            const AppDongKe(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.blockGap,
                AppSpacing.screenPadding,
                AppSpacing.blockGap,
              ),
              child: ReviewSummaryBlock(thongKe: thongKe),
            ),
            AppTabBar(
              cuon: false,
              labels: [
                l10n.nhanChuaPhanHoiSo('${chuaPhanHoi.length}'),
                l10n.nhanTatCaSo('${thongKe.tongSo}'),
              ],
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _DanhSach(
              reviews: chuaPhanHoi,
              onPhanHoi: _vietPhanHoi,
              rong: _Rong(
                title: l10n.daPhanHoiHetDanhGia,
                message: l10n.moTaDaPhanHoiHet,
              ),
            ),
            _DanhSach(
              reviews: reviews,
              onPhanHoi: _vietPhanHoi,
              rong: _Rong(
                title: l10n.chuaCoDanhGia,
                message: l10n.moTaDaPhanHoiHet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DanhSach extends StatelessWidget {
  const _DanhSach({
    required this.reviews,
    required this.onPhanHoi,
    required this.rong,
  });

  final List<SitterReview> reviews;
  final void Function(SitterReview review) onPhanHoi;
  final Widget rong;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) return rong;
    final l10n = context.l10n;
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
      itemBuilder: (_, i) {
        final r = reviews[i];
        return ReviewItem(
          review: r,
          nhanPhanHoi: l10n.banDaPhanHoi,
          duoi: r.phanHoi == null
              ? _HangPhanHoi(review: r, onTap: () => onPhanHoi(r))
              : null,
        );
      },
    );
  }
}

class _HangPhanHoi extends StatelessWidget {
  const _HangPhanHoi({required this.review, required this.onTap});
  static const double _coNut = 36;
  final SitterReview review;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final con = review.soNgayConPhanHoi;
    final gap = con != null && con <= _sapHetHan;
    return Row(
      children: [
        Expanded(
          child: Text(
            con == null
                ? l10n.phanHoi
                : '${l10n.phanHoi} · ${l10n.conKhoang(l10n.nNgayNhan('$con'))}',
            style: AppTextStyles.captionSm.copyWith(
              color: gap ? AppColors.accent : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.labelGap),
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.primaryColor),
          ),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const SizedBox(
              width: _coNut,
              height: _coNut,
              child: Icon(
                Icons.reply_rounded,
                size: 18,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ],
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
