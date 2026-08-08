import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/features/account/widgets/sitter_switch_sheet.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/notification/providers/notifications_provider.dart';
import 'package:petcare_app/features/sitter/data/sitter_dashboard.dart';
import 'package:petcare_app/features/sitter/providers/sitter_home_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/widgets/earnings/earnings_card.dart';
import 'package:petcare_app/features/sitter/widgets/home/monthly_performance_card.dart';
import 'package:petcare_app/features/sitter/widgets/home/my_services_section.dart';
import 'package:petcare_app/features/sitter/widgets/home/onboarding_checklist.dart';
import 'package:petcare_app/features/sitter/widgets/home/pending_orders_section.dart';
import 'package:petcare_app/features/sitter/widgets/home/sitter_home_app_bar.dart';
import 'package:petcare_app/features/sitter/widgets/home/today_schedule_section.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

const _rong = SitterDashboard(
  location: '',
  weekEarnings: 0,
  ordersThisWeek: 0,
  workedThisWeek: 0,
  rating: 0,
  acceptRate: 100,
  completedThisMonth: 0,
  pendingOrders: [],
);

// Tab Công việc
class SitterWorkTab extends ConsumerWidget {
  const SitterWorkTab({super.key, this.bottomInset = 24});

  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).padding.top;
    return AnnotatedRegion(
      value: AppSystemUi.onDarkBackground,
      child: Stack(
        children: [
          AppRefreshIndicator(
            onRefresh: () =>
                ref.read(trangChuNguoiChamProvider.notifier).taiLai(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset),
                    child: const _Than(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset,
            child: const ColoredBox(color: AppColors.primaryColor),
          ),
        ],
      ),
    );
  }
}

Future<void> _veChuNuoi(BuildContext context) async {
  final doi = await showOwnerSwitchSheet(context);
  if (doi == true && context.mounted) context.go(AppRoutes.home);
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final svcNotifier = ref.read(sitterServicesProvider.notifier);
    return SitterHomeAppBar(
      location: ref.watch(trangChuNguoiChamProvider).value?.location ?? '',
      isReceiving: ref.watch(sitterServicesProvider).value?.anyEnabled ?? false,
      hasUnreadNotifications: ref.watch(soThongBaoChuaDocProvider(null)) > 0,
      khoa: !(ref.watch(sitterOnboardingProvider).value ?? false),
      onReceivingChanged: (v) =>
          v ? svcNotifier.moLai() : svcNotifier.tamNghi(),
    );
  }
}

// Thân màn: chờ đủ ba nguồn mới quyết hiện onboarding hay bảng công việc
class _Than extends ConsumerWidget {
  const _Than();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areaAsync = ref.watch(sitterServiceAreaProvider);
    final svcAsync = ref.watch(sitterServicesProvider);
    final onbAsync = ref.watch(sitterOnboardingProvider);
    if ((areaAsync.isLoading && !areaAsync.hasValue) ||
        (svcAsync.isLoading && !svcAsync.hasValue) ||
        (onbAsync.isLoading && !onbAsync.hasValue)) {
      return const AppSkeletonList(soThe: 4, caoThe: 104);
    }
    if (!(onbAsync.value ?? false)) {
      return OnboardingChecklist(
        coKhuVuc: areaAsync.value?.daDat ?? false,
        coDichVu: svcAsync.value?.hasAny ?? false,
        onThietLap: () => context.push(AppRoutes.sitterServices),
        onHoanTat: () => ref.read(sitterOnboardingProvider.notifier).hoanTat(),
        onVeChuNuoi: () => _veChuNuoi(context),
      );
    }
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ThuNhap(),
        SizedBox(height: AppSpacing.blockGap),
        _DonCho(),
        SizedBox(height: AppSpacing.blockGap),
        _LichHomNay(),
        SizedBox(height: AppSpacing.blockGap),
        MyServicesSection(),
        SizedBox(height: AppSpacing.blockGap),
        _HieuSuatThang(),
      ],
    );
  }
}

class _ThuNhap extends ConsumerWidget {
  const _ThuNhap();

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      EarningsCard(data: ref.watch(trangChuNguoiChamProvider).value ?? _rong);
}

class _DonCho extends ConsumerWidget {
  const _DonCho();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(trangChuNguoiChamProvider).value ?? _rong;
    return PendingOrdersSection(
      orders: data.pendingOrders,
      tongDonCho: data.pendingTotal,
    );
  }
}

// Lịch hôm nay đọc thẳng lịch thật của tab Lịch
class _LichHomNay extends ConsumerWidget {
  const _LichHomNay();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TodayScheduleSection(
    items:
        ref.watch(sitterScheduleProvider).value?.lichCuaNgay(homNayVn()) ??
        const [],
  );
}

class _HieuSuatThang extends ConsumerWidget {
  const _HieuSuatThang();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MonthlyPerformanceCard(
    data: ref.watch(trangChuNguoiChamProvider).value ?? _rong,
  );
}
