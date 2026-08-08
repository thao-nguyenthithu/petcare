import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/diem_so.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Trượt tới thẻ nào thì ghim của người đó sáng lên nên phải báo chỉ số ra
class MapSitterStrip extends StatefulWidget {
  const MapSitterStrip({
    super.key,
    required this.danhSach,
    required this.moTaDem,
    required this.chiSoDangXem,
    required this.onDoiChiSo,
    required this.onChonThe,
    required this.kmCuaNguoiCham,
  });

  static const double tiLeThe = 0.82;

  final List<SitterResult> danhSach;
  final String moTaDem;
  final int chiSoDangXem;
  final ValueChanged<int> onDoiChiSo;
  final ValueChanged<int> onChonThe;
  final double Function(SitterResult) kmCuaNguoiCham;

  @override
  State<MapSitterStrip> createState() => _MapSitterStripState();
}

class _MapSitterStripState extends State<MapSitterStrip> {
  late final PageController _controller = PageController(
    initialPage: widget.chiSoDangXem,
    viewportFraction: MapSitterStrip.tiLeThe,
  );

  @override
  void didUpdateWidget(MapSitterStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chiSoDangXem != oldWidget.chiSoDangXem &&
        _controller.hasClients) {
      _controller.animateToPage(
        widget.chiSoDangXem,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Material(
            color: AppColors.surface,
            elevation: 2,
            shadowColor: AppColors.shadow,
            shape: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.itemGap,
                vertical: AppSpacing.labelGap,
              ),
              child: Text(widget.moTaDem, style: AppTextStyles.captionSm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.labelGap),
        SizedBox(
          height: 96,
          child: PageView.builder(
            controller: _controller,
            padEnds: false,
            onPageChanged: widget.onDoiChiSo,
            itemCount: widget.danhSach.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? AppSpacing.screenPadding : 0,
                right: AppSpacing.itemGap,
              ),
              child: _TheNgan(
                nguoiCham: widget.danhSach[index],
                km: widget.kmCuaNguoiCham(widget.danhSach[index]),
                dangXem: index == widget.chiSoDangXem,
                onTap: () => widget.onChonThe(index),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TheNgan extends StatelessWidget {
  const _TheNgan({
    required this.nguoiCham,
    required this.km,
    required this.dangXem,
    required this.onTap,
  });

  final SitterResult nguoiCham;
  final double km;
  final bool dangXem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        side: BorderSide(
          color: dangXem ? AppColors.primaryColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.itemGap),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    imageUrl: nguoiCham.avatarUrl,
                    name: nguoiCham.name,
                    size: 44,
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nguoiCham.name,
                          style: AppTextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.textGap),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.honey,
                            ),
                            const SizedBox(width: AppSpacing.textGap),
                            Flexible(
                              child: Text(
                                '${soDiem(nguoiCham.rating)}'
                                ' (${nguoiCham.soDanhGia}) · '
                                '${soLeKm(km)} km',
                                style: AppTextStyles.captionSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        nguoiCham.gia == null
                            ? '--'
                            : '${l10n.tu} '
                                  '${l10n.giaTien(dinhDangTien(nguoiCham.gia!))}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      Text(
                        nguoiCham.loai.donVi(l10n),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.labelGap),
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: AppSpacing.textGap),
                  Expanded(
                    child: Text(
                      l10n.nhanDonNgayBanChon(
                        nguoiCham.soNgayNhan,
                        nguoiCham.soNgayNhan,
                      ),
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(
                      AppRoutes.sitterDetail.replaceFirst(':id', nguoiCham.id),
                    ),
                    child: Text(
                      l10n.xemHoSo,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
