import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/owner_home.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/shared/widgets/page_dots.dart';

// Thanh đơn đang diễn ra nổi ở đáy Home
class ActiveOrderBar extends StatelessWidget {
  const ActiveOrderBar({super.key, required this.orders});

  final List<DonDangChay> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) return const SizedBox.shrink();
    if (orders.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _OrderCard(order: orders.first),
      );
    }
    return _SwipeableBars(orders: orders);
  }
}

// PageView vuốt ngang
class _SwipeableBars extends StatefulWidget {
  const _SwipeableBars({required this.orders});

  final List<DonDangChay> orders;

  @override
  State<_SwipeableBars> createState() => _SwipeableBarsState();
}

class _SwipeableBarsState extends State<_SwipeableBars> {
  final _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: PageView.builder(
              controller: _controller,
              padEnds: false,
              clipBehavior: Clip.none,
              itemCount: widget.orders.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _OrderCard(order: widget.orders[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        PageDots(
          count: widget.orders.length,
          current: _index,
          dotSize: 4,
          activeWidth: 15,
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final DonDangChay order;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.bookingDetail, extra: order.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(image: order.sitterAvatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nhanTrangThai(context, order),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${order.sitterName} · '
                      '${context.l10n.conKhoang(dongHoConLai(context.l10n, order.remainingMinutes))}',
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.textWhite.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: order.progress,
                        minHeight: 4,
                        backgroundColor: AppColors.textWhite.withValues(
                          alpha: 0.3,
                        ),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.textWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.textWhite.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textWhite,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Avatar tròn, chấm live
class _Avatar extends StatelessWidget {
  const _Avatar({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          ClipOval(
            child: Image.asset(image, width: 44, height: 44, fit: BoxFit.cover),
          ),
          const Positioned(right: 1, top: 1, child: _LiveDot()),
        ],
      ),
    );
  }
}

// Chấm live thở
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  )..repeat(reverse: true);

  late final CurvedAnimation _duongCong = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  late final Animation<double> _thu = Tween(
    begin: 1.0,
    end: 0.9,
  ).animate(_duongCong);

  @override
  void dispose() {
    _duongCong.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _thu,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textWhite, width: 1.5),
        ),
      ),
    );
  }
}

String _nhanTrangThai(BuildContext context, DonDangChay don) {
  final l10n = context.l10n;
  final be = don.petNames.isEmpty ? '' : don.petNames.first;
  final ten = don.serviceType.ten(l10n);
  return be.isEmpty ? ten : l10n.dangLamChoBe(ten, be);
}
