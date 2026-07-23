import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/features/provider_home/data/mock_provider_home.dart';
import 'package:petcare_app/features/provider_home/widgets/earnings_card.dart';
import 'package:petcare_app/features/provider_home/widgets/monthly_performance_card.dart';
import 'package:petcare_app/features/provider_home/widgets/my_services_section.dart';
import 'package:petcare_app/features/provider_home/widgets/no_service_state.dart';
import 'package:petcare_app/features/provider_home/widgets/pending_orders_section.dart';
import 'package:petcare_app/features/provider_home/widgets/provider_home_app_bar.dart';
import 'package:petcare_app/features/provider_home/widgets/provider_tip_card.dart';
import 'package:petcare_app/features/provider_home/widgets/today_schedule_section.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';

// Tab Công việc
class ProviderWorkTab extends ConsumerWidget {
  const ProviderWorkTab({super.key, this.bottomInset = 24});

  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const data = MockProviderData.dashboard;
    final topInset = MediaQuery.of(context).padding.top;
    return AnnotatedRegion(
      value: AppSystemUi.onDarkBackground,
      child: Stack(
        children: [
          AppRefreshIndicator(
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ProviderHomeAppBar(
                    location: data.location,
                    isReceiving: data.isReceiving,
                    hasUnreadNotifications: data.hasUnreadNotifications,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset),
                    // Chưa có dịch vụ nào, onboarding thay cả cụm section
                    child: data.hasServices
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const EarningsCard(data: data),
                              const SizedBox(height: 20),
                              PendingOrdersSection(orders: data.pendingOrders),
                              const SizedBox(height: 20),
                              TodayScheduleSection(items: data.schedule),
                              const SizedBox(height: 20),
                              MyServicesSection(services: data.services),
                              const SizedBox(height: 20),
                              const MonthlyPerformanceCard(data: data),
                              const SizedBox(height: 20),
                              const ProviderTipCard(),
                            ],
                          )
                        : const NoServiceState(),
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
