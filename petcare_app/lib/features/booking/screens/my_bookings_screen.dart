import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/mock_booking_data.dart';
import 'package:petcare_app/features/booking/widgets/booking_service_filter.dart';
import 'package:petcare_app/features/booking/widgets/booking_status_tab_bar.dart';
import 'package:petcare_app/features/booking/widgets/booking_tab_view.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';

// Tab "Đơn của tôi" của chủ nuôi: ô tìm + chip lọc dịch vụ + 4 tab trạng thái.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  PetServiceType? _serviceType; // null = tất cả dịch vụ
  bool _showFilter = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Thứ tự tab: Sắp tới, Đang diễn ra, Đã xong, Đã huỷ
    final tabs = <(String, BookingStatus)>[
      (l10n.sapToi, BookingStatus.sapToi),
      (l10n.dangDienRa, BookingStatus.dangDienRa),
      (l10n.daXong, BookingStatus.hoanThanh),
      (l10n.daHuy, BookingStatus.daHuy),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPaddingWide,
                AppSpacing.labelGap,
                AppSpacing.screenPaddingWide,
                AppSpacing.itemGap,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.donCuaToi, style: AppTextStyles.h3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPaddingWide,
              ),
              child: AppSearchField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                hintText: l10n.timDonHint,
                filterOpen: _showFilter,
                onToggleFilter: () =>
                    setState(() => _showFilter = !_showFilter),
              ),
            ),
            // Hàng chip lọc dịch vụ ẩn/hiện theo nút lọc
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _showFilter
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.itemGap),
                      child: BookingServiceFilter(
                        selected: _serviceType,
                        onSelected: (t) => setState(() => _serviceType = t),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: AppSpacing.labelGap),
            BookingStatusTabBar(labels: [for (final t in tabs) t.$1]),
            Expanded(
              child: TabBarView(
                children: [
                  for (final t in tabs)
                    BookingTabView(
                      status: t.$2,
                      serviceType: _serviceType,
                      query: _query,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
