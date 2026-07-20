import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

// Header xanh logo, chuông, lời chào, địa chỉ
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, required this.user});

  final MockHomeUser user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      surfaceTintColor: AppColors.primaryColor,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarHeight: 0,
      expandedHeight: 128,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/paw_white.svg', width: 30),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.tenUngDung,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                    Material(
                      color: const Color(0xFF23705A),
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () => baoDangPhatTrien(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Badge(
                          isLabelVisible: user.hasUnreadNotifications,
                          smallSize: 8,
                          backgroundColor: AppColors.accent,
                          child: const Icon(Icons.notifications, size: 20),
                        ),
                        color: AppColors.textWhite,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    text: '${l10n.xinChao}, ',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textWhite,
                    ),
                    children: [
                      TextSpan(
                        text: user.name,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _AddressRow(address: user.address),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Thanh tìm kiếm
class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SearchBarHeaderDelegate();

  static const double _height = 76;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: overlapsContent ? AppColors.primaryColor : AppColors.background,
        boxShadow: overlapsContent
            ? const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: _SearchBar(),
      ),
    );
  }

  @override
  bool shouldRebuild(SearchBarHeaderDelegate oldDelegate) => false;
}

// Có địa chỉ thì hiện, chưa có thì mời chọn
class _AddressRow extends StatelessWidget {
  const _AddressRow({required this.address});

  final String? address;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => baoDangPhatTrien(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/icons/icon_location.svg', height: 18),
          const SizedBox(width: 10),
          Text(
            address ?? context.l10n.chonDiaChi,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.neutral),
          ),
          if (address == null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral),
          ],
        ],
      ),
    );
  }
}

// Thanh tìm kiếm nút bộ lọc
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: AppColors.surface,
            elevation: 2,
            shadowColor: AppColors.shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.radius14),
            ),
            child: InkWell(
              onTap: () => baoDangPhatTrien(context),
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: 18),
                    SvgPicture.asset('assets/icons/icon_search.svg', width: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.timDichVuNguoiCham,
                        style: AppTextStyles.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 48,
          height: 52,
          child: IconButton.filled(
            onPressed: () => baoDangPhatTrien(context),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
            ),
            icon: const Icon(Icons.tune, color: AppColors.textWhite),
          ),
        ),
      ],
    );
  }
}
