import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/features/home/providers/home_sitters_provider.dart';
import 'package:petcare_app/features/home/providers/owner_home_provider.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/home/widgets/home_app_bar.dart';
import 'package:petcare_app/features/home/widgets/home_banners.dart';
import 'package:petcare_app/features/home/widgets/pets_section.dart';
import 'package:petcare_app/features/home/widgets/provider_card.dart';
import 'package:petcare_app/features/home/widgets/provider_list.dart';
import 'package:petcare_app/features/home/widgets/recent_booking_list.dart';
import 'package:petcare_app/features/home/widgets/section_header.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/service_category_row.dart';

class OwnerHomeTab extends ConsumerWidget {
  const OwnerHomeTab({super.key, this.bottomInset = 24});

  // Chừa chỗ cuối trang cho thanh đơn đang diễn
  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AppRefreshIndicator(
      onRefresh: () async {
        await ref.read(savedAddressesProvider.future);
        await ref.read(trangChuCuaToiProvider.notifier).taiLai();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const HomeAppBar(),
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  child: ServiceCategoryRow(
                    onChon: (loai) =>
                        context.push(AppRoutes.searchPath(dichVu: loai.maApi)),
                  ),
                ),
                const SizedBox(height: 28),
                const _CumGanBan(),
                const SizedBox(height: 28),
                const _CumDatLai(),
                SectionHeader(title: l10n.thuCungCuaBan),
                const SizedBox(height: 8),
                const _CumThuCung(),
                const SizedBox(height: 8),
                const _CumDanhGiaCao(),
                const BecomeProviderBanner(),
                SizedBox(height: bottomInset),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CumDatLai extends ConsumerWidget {
  const _CumDatLai();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datLai =
        ref.watch(trangChuCuaToiProvider).value?.nguoiChamDaDat ?? const [];
    if (datLai.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.datLaiLanNua,
          onTapMore: () => context.push(AppRoutes.search),
        ),
        RecentBookingList(bookings: datLai),
        const SizedBox(height: 28),
      ],
    );
  }
}

// Dải thú cưng tự nghe danh sách bé, tiêu đề luôn giữ nên nằm ngoài
class _CumThuCung extends ConsumerWidget {
  const _CumThuCung();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      PetsSection(pets: ref.watch(myPetsProvider).value ?? const []);
}

class _CumGanBan extends ConsumerWidget {
  const _CumGanBan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coDiaChi =
        ref.watch(savedAddressesProvider).asData?.value.isNotEmpty ?? false;
    if (!coDiaChi) return const AddAddressBanner();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.nguoiCungCapGanBan,
          onTapMore: () =>
              context.push(AppRoutes.searchPath(sapXep: 'nearest')),
        ),
        const SizedBox(height: 8),
        const _HangNguoiCham(ganBan: true),
      ],
    );
  }
}

// Không ai qua cửa đánh giá thì giấu cả tiêu đề (bộ luật mục 9)
class _CumDanhGiaCao extends ConsumerWidget {
  const _CumDanhGiaCao();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nguoiChamDanhGiaCaoProvider);
    if (async.asData?.value.isEmpty ?? false) {
      return const SizedBox(height: 20);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.duocDanhGiaCao,
          onTapMore: () => context.push(AppRoutes.searchPath(sapXep: 'rating')),
        ),
        const SizedBox(height: 8),
        const _HangNguoiCham(ganBan: false),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _HangNguoiCham extends ConsumerWidget {
  const _HangNguoiCham({required this.ganBan});
  final bool ganBan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final danhSach = ganBan
        ? ref.watch(nguoiChamGanBanProvider)
        : ref.watch(nguoiChamDanhGiaCaoProvider);
    final ds = danhSach.asData?.value;
    if (danhSach.isLoading) {
      return const AppSkeletonRow(
        caoThe: ProviderList.cao,
        rongThe: ProviderCard.rong,
      );
    }
    if (ds == null || ds.isEmpty) return const SizedBox.shrink();
    return ProviderList(
      providers: ds,
      onSeeMore: () => context.push(
        AppRoutes.searchPath(sapXep: ganBan ? 'nearest' : 'rating'),
      ),
    );
  }
}
