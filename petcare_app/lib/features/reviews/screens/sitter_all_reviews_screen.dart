import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/reviews/data/review_filter.dart';
import 'package:petcare_app/features/reviews/widgets/review_filter_bar.dart';
import 'package:petcare_app/features/reviews/widgets/review_item.dart';
import 'package:petcare_app/features/reviews/widgets/review_summary.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';

typedef SitterAllReviewsArgs = ({
  String tenNcc,
  ThongKeDanhGia thongKe,
  List<SitterReview> reviews,
});

// Màn Tất cả đánh giá về một người chăm
class SitterAllReviewsScreen extends StatefulWidget {
  const SitterAllReviewsScreen({super.key, required this.args});

  final SitterAllReviewsArgs args;

  @override
  State<SitterAllReviewsScreen> createState() => _SitterAllReviewsScreenState();
}

class _SitterAllReviewsScreenState extends State<SitterAllReviewsScreen> {
  BoLocDanhGia _boLoc = const BoLocDanhGia();
  PanelLoc _panel = PanelLoc.khong;

  void _dongPanel() {
    if (_panel != PanelLoc.khong) setState(() => _panel = PanelLoc.khong);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final args = widget.args;
    final hienThi = args.reviews.where(_boLoc.nhan).toList();

    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.tatCaDanhGiaVe(args.tenNcc)),
          const AppDongKe(),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.blockGap,
              AppSpacing.screenPadding,
              AppSpacing.blockGap,
            ),
            child: ReviewSummaryBlock(thongKe: args.thongKe),
          ),
          ReviewFilterBar(
            boLoc: _boLoc,
            panel: _panel,
            onDoiBoLoc: (moi) => setState(() => _boLoc = moi),
            onDoiPanel: (p) => setState(() => _panel = p),
          ),
          const SizedBox(height: AppSpacing.itemGap),
        ],
      ),
      body: Stack(
        children: [
          hienThi.isEmpty
              ? _KhongCoDanhGia(dangLoc: _boLoc.dangLoc)
              : _DanhSach(reviews: hienThi, tenNcc: args.tenNcc),
          if (_panel != PanelLoc.khong) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _dongPanel,
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: AppColors.surface.withValues(alpha: 0.72),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ReviewFilterPanel(
                panel: _panel,
                boLoc: _boLoc,
                thongKe: args.thongKe,
                onChon: (moi) => setState(() {
                  _boLoc = moi;
                  _panel = PanelLoc.khong;
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DanhSach extends StatelessWidget {
  const _DanhSach({required this.reviews, required this.tenNcc});

  final List<SitterReview> reviews;
  final String tenNcc;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
      ),
      itemCount: reviews.length,
      separatorBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.stackGap),
        child: AppDongKe(),
      ),
      itemBuilder: (context, i) => ReviewItem(
        review: reviews[i],
        nhanPhanHoi: context.l10n.nguoiChamPhanHoi(tenNcc),
      ),
    );
  }
}

class _KhongCoDanhGia extends StatelessWidget {
  const _KhongCoDanhGia({required this.dangLoc});

  final bool dangLoc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: AppEmptyState(
        icon: Icons.star_outline_rounded,
        title: dangLoc ? l10n.khongCoDanhGiaPhuHop : l10n.chuaCoDanhGia,
        message: dangLoc ? l10n.thuBoBotDieuKienLoc : null,
        circleColor: AppColors.cardMint,
        iconColor: AppColors.accent,
      ),
    );
  }
}
