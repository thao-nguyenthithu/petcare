import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/mock_booking_data.dart';
import 'package:petcare_app/features/booking/widgets/booking_card.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Danh sách đơn của một tab
class BookingTabView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bookings = MockBookingData.loc(
      status: status,
      serviceType: serviceType,
      query: query,
    );
    if (bookings.isEmpty) {
      return MockBookingData.coDonTheoTrangThai(status)
          ? const _NoMatch()
          : const _EmptyBookings();
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingWide,
      ),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const AppDongKe(thut: 56),
      itemBuilder: (context, i) => BookingCard(booking: bookings[i]),
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

// Trạng thái chưa có đơn
class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
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
