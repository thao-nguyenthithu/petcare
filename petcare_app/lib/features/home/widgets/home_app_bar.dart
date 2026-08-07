import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/notification/providers/notifications_provider.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';

// Header xanh logo, chuông, lời chào, địa chỉ
class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final userName =
        ref.watch(currentUserProvider).asData?.value.fullName ?? '';
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryColor,
      surfaceTintColor: AppColors.primaryColor,
      elevation: 0,
      systemOverlayStyle: AppSystemUi.onDarkBackground,
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
                        onPressed: () => context.push(AppRoutes.notifications),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        style: const ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Badge(
                          isLabelVisible:
                              ref.watch(soThongBaoChuaDocProvider(null)) > 0,
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
                        text: userName,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const _AddressRow(),
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

class _AddressRow extends ConsumerWidget {
  const _AddressRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final danhSach =
        ref.watch(savedAddressesProvider).asData?.value ??
        const <SavedAddress>[];
    SavedAddress? macDinh;
    for (final dc in danhSach) {
      if (dc.isDefault) {
        macDinh = dc;
        break;
      }
    }
    macDinh ??= danhSach.isNotEmpty ? danhSach.first : null;
    final coDiaChi = macDinh != null;
    return InkWell(
      onTap: () =>
          context.push(coDiaChi ? AppRoutes.addresses : AppRoutes.addAddress),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/icon_location.svg', height: 18),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              macDinh?.diaChiDayDu ?? context.l10n.chonDiaChi,
              style: AppTextStyles.captionSm.copyWith(color: AppColors.neutral),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.neutral),
        ],
      ),
    );
  }
}

// Thanh tìm kiếm, bấm vào mở màn Tìm kiếm
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.search),
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
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
