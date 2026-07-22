import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/features/article/data/mock_article_data.dart';
import 'package:petcare_app/features/article/widgets/article_list.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/features/home/widgets/home_app_bar.dart';
import 'package:petcare_app/features/home/widgets/home_banners.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/features/home/widgets/pets_section.dart';
import 'package:petcare_app/features/home/widgets/provider_list.dart';
import 'package:petcare_app/features/home/widgets/recent_booking_list.dart';
import 'package:petcare_app/features/home/widgets/section_header.dart';
import 'package:petcare_app/features/home/widgets/service_categories.dart';

class OwnerHomeTab extends ConsumerWidget {
  const OwnerHomeTab({super.key, this.bottomInset = 24});

  // Chừa chỗ cuối trang cho thanh đơn đang diễn
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    const user = MockHomeData.user;
    final coDiaChi =
        ref.watch(savedAddressesProvider).asData?.value.isNotEmpty ?? false;
    return CustomScrollView(
      slivers: [
        const HomeAppBar(user: user),
        const SliverPersistentHeader(
          pinned: true,
          delegate: SearchBarHeaderDelegate(),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerifiedBanner(),
              const SizedBox(height: 20),
              SectionHeader(
                title: l10n.dichVuPhoBien,
                onTapMore: () => context.push(AppRoutes.services),
              ),
              const SizedBox(height: 8),
              const ServiceCategories(
                categories: MockHomeData.serviceCategories,
              ),
              const SizedBox(height: 28),
              if (coDiaChi) ...[
                SectionHeader(
                  title: l10n.nguoiCungCapGanBan,
                  onTapMore: () => baoDangPhatTrien(context),
                ),
                const SizedBox(height: 8),
                ProviderList(
                  providers: MockHomeData.nearbyProviders.take(15).toList(),
                  onSeeMore: () => baoDangPhatTrien(context),
                ),
              ] else
                const AddAddressBanner(),
              const SizedBox(height: 28),
              if (MockHomeData.recentBookings.isNotEmpty) ...[
                SectionHeader(
                  title: l10n.datLaiLanNua,
                  onTapMore: () => baoDangPhatTrien(context),
                ),
                RecentBookingList(
                  bookings: MockHomeData.recentBookings.take(5).toList(),
                ),
                const SizedBox(height: 28),
              ],
              SectionHeader(title: l10n.thuCungCuaBan),
              const SizedBox(height: 8),
              const PetsSection(pets: MockHomeData.pets),
              const SizedBox(height: 8),
              SectionHeader(
                title: l10n.duocDanhGiaCao,
                onTapMore: () => baoDangPhatTrien(context),
              ),
              const SizedBox(height: 8),
              ProviderList(
                providers: MockHomeData.topRatedProviders.take(15).toList(),
                onSeeMore: () => baoDangPhatTrien(context),
              ),
              const SizedBox(height: 28),
              const BecomeProviderBanner(),
              const SizedBox(height: 24),
              SectionHeader(
                title: l10n.meoChamSoc,
                onTapMore: () => context.push(AppRoutes.articles),
              ),
              const SizedBox(height: 8),
              ArticleList(
                articles: MockArticle.latest
                    .take(MockArticle.homePreviewCount)
                    .toList(),
              ),
              SizedBox(height: bottomInset),
            ],
          ),
        ),
      ],
    );
  }
}
