import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/features/account/widgets/sitter_switch_sheet.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_home.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/widgets/earnings/earnings_card.dart';
import 'package:petcare_app/features/sitter/widgets/home/monthly_performance_card.dart';
import 'package:petcare_app/features/sitter/widgets/home/my_services_section.dart';
import 'package:petcare_app/features/sitter/widgets/home/onboarding_checklist.dart';
import 'package:petcare_app/features/sitter/widgets/home/pending_orders_section.dart';
import 'package:petcare_app/features/sitter/widgets/home/sitter_home_app_bar.dart';
import 'package:petcare_app/features/sitter/widgets/home/sitter_tip_card.dart';
import 'package:petcare_app/features/sitter/widgets/home/today_schedule_section.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';

// Tab Công việc
class SitterWorkTab extends ConsumerStatefulWidget {
  const SitterWorkTab({super.key, this.bottomInset = 24});

  final double bottomInset;

  @override
  ConsumerState<SitterWorkTab> createState() => _SitterWorkTabState();
}

class _SitterWorkTabState extends ConsumerState<SitterWorkTab> {
  static const _data = MockSitterData.dashboard;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final dangNhanDon =
        ref.watch(sitterServicesProvider).value?.anyEnabled ?? false;
    final chuaXongOnboarding =
        !(ref.watch(sitterOnboardingProvider).value ?? false);
    final svcNotifier = ref.read(sitterServicesProvider.notifier);
    return AnnotatedRegion(
      value: AppSystemUi.onDarkBackground,
      child: Stack(
        children: [
          AppRefreshIndicator(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SitterHomeAppBar(
                    location: _data.location,
                    isReceiving: dangNhanDon,
                    hasUnreadNotifications: _data.hasUnreadNotifications,
                    khoa: chuaXongOnboarding,
                    onReceivingChanged: (v) =>
                        v ? svcNotifier.moLai() : svcNotifier.tamNghi(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      widget.bottomInset,
                    ),
                    child: _body(),
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

  Future<void> _veChuNuoi() async {
    final doi = await showOwnerSwitchSheet(context);
    if (doi == true && mounted) context.go(AppRoutes.home);
  }

  Widget _body() {
    final areaAsync = ref.watch(sitterServiceAreaProvider);
    final svcAsync = ref.watch(sitterServicesProvider);
    final onbAsync = ref.watch(sitterOnboardingProvider);
    // Đang tải lần đầu → chưa biết trạng thái, hiện loader thay vì onboarding
    if ((areaAsync.isLoading && !areaAsync.hasValue) ||
        (svcAsync.isLoading && !svcAsync.hasValue) ||
        (onbAsync.isLoading && !onbAsync.hasValue)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    // Onboarding hiện tới khi NCC bấm "Bắt đầu nhận đơn" (onboardedAt trên backend)
    if (!(onbAsync.value ?? false)) {
      return OnboardingChecklist(
        coKhuVuc: areaAsync.value?.daDat ?? false,
        coDichVu: svcAsync.value?.hasAny ?? false,
        onThietLap: () => context.push(AppRoutes.sitterServices),
        onHoanTat: () => ref.read(sitterOnboardingProvider.notifier).hoanTat(),
        onVeChuNuoi: _veChuNuoi,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const EarningsCard(data: _data),
        const SizedBox(height: 20),
        PendingOrdersSection(orders: _data.pendingOrders),
        const SizedBox(height: 20),
        TodayScheduleSection(items: _data.schedule),
        const SizedBox(height: 20),
        const MyServicesSection(),
        const SizedBox(height: 20),
        const MonthlyPerformanceCard(data: _data),
        const SizedBox(height: 20),
        const SitterTipCard(),
      ],
    );
  }
}
