import 'dart:async';

import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/features/booking/widgets/booking_service_filter.dart';
import 'package:petcare_app/features/booking/widgets/booking_status_tab_bar.dart';
import 'package:petcare_app/features/booking/widgets/booking_tab_view.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';

// Tab Đơn của tôi của chủ nuôi: ô tìm + chip lọc dịch vụ + 5 tab trạng thái.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  static const _choGoXong = Duration(milliseconds: 400);

  final _searchController = TextEditingController();
  Timer? _henTim;
  String _query = '';
  PetServiceType? _serviceType;
  bool _showFilter = false;

  @override
  void dispose() {
    _henTim?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _doiTuKhoa(String value) {
    final tuKhoa = value.trim();
    if (tuKhoa == _query) return;
    _henTim?.cancel();
    _henTim = Timer(_choGoXong, () {
      if (mounted) setState(() => _query = tuKhoa);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = <(String, BookingStatus)>[
      (l10n.trangThaiChoXacNhan, BookingStatus.choXacNhan),
      (l10n.sapToi, BookingStatus.sapToi),
      (l10n.dangDienRa, BookingStatus.dangDienRa),
      (l10n.hoanThanh, BookingStatus.hoanThanh),
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
                onChanged: _doiTuKhoa,
                hintText: l10n.timDonChuNuoiHint,
                filterOpen: _showFilter,
                onToggleFilter: () =>
                    setState(() => _showFilter = !_showFilter),
              ),
            ),
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
