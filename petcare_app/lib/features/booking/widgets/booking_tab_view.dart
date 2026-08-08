import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/features/booking/providers/owner_bookings_provider.dart';
import 'package:petcare_app/features/booking/widgets/booking_card.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';

// Danh sách đơn của một tab
class BookingTabView extends ConsumerWidget {
  const BookingTabView({
    super.key,
    required this.status,
    required this.serviceType,
    required this.query,
  });

  final BookingStatus status;
  final PetServiceType? serviceType;
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dangLoc = serviceType != null || query.trim().isNotEmpty;

    final provider = ownerBookingsProvider(status, serviceType, query);
    return switch (ref.watch(provider)) {
      AsyncData(:final value) => AppRefreshIndicator(
        onRefresh: () => ref.read(provider.future),
        child: _KhungDanhSach(
          rong: value.items.isEmpty,
          dangLoc: dangLoc,
          child: _DanhSachDon(
            trang: value,
            onTaiThem: ref.read(provider.notifier).taiThem,
          ),
        ),
      ),
      AsyncError() => AppNetworkError(onRetry: () => ref.invalidate(provider)),
      _ => const AppSkeletonList(soThe: 4, caoThe: 128),
    };
  }
}

class _KhungDanhSach extends StatelessWidget {
  const _KhungDanhSach({
    required this.rong,
    required this.dangLoc,
    required this.child,
  });

  final bool rong;
  final bool dangLoc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!rong) return child;
    return dangLoc ? const _NoMatch() : const _EmptyBookings();
  }
}

class _DanhSachDon extends StatelessWidget {
  const _DanhSachDon({required this.trang, required this.onTaiThem});

  final TrangDonCuaToi trang;
  final Future<void> Function() onTaiThem;

  @override
  Widget build(BuildContext context) {
    final items = trang.items;
    return NotificationListener<ScrollNotification>(
      onNotification: (tin) {
        if (trang.conTrangSau &&
            !trang.dangTaiThem &&
            tin.metrics.extentAfter < 300) {
          onTaiThem();
        }
        return false;
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingWide,
          AppSpacing.labelGap,
          AppSpacing.screenPaddingWide,
          AppSpacing.screenEdgeGap,
        ),
        itemCount: items.length + (trang.dangTaiThem ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.itemGap),
        itemBuilder: (context, i) => i < items.length
            ? OwnerBookingCard(booking: items[i])
            : const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
      ),
    );
  }
}

class _NoMatch extends StatelessWidget {
  const _NoMatch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.khongCoDonPhuHop,
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: AppEmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.chuaCoDonNao,
              message: l10n.datDichVuDauTien,
              circleColor: AppColors.cardMint,
              iconColor: AppColors.accent,
              action: SizedBox(
                width: 246,
                child: AppButton(
                  text: l10n.timNguoiCham,
                  color: AppColors.accent,
                  height: 48,
                  onTap: () => context.push(AppRoutes.services),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
