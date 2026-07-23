import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/mock_booking_data.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';

// Một card trong listbook
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final MockBooking booking;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // TODO: điều hướng màn chi tiết đơn khi có màn đích
      onTap: () => baoDangPhatTrien(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.asset(
                booking.petAvatar,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.serviceName,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    booking.petInfo,
                    style: AppTextStyles.captionSm.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${booking.providerName} · ${booking.whenLabel}',
                    style: AppTextStyles.captionSm.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(status: booking.status),
                const SizedBox(height: AppSpacing.labelGap),
                Text(
                  '${dinhDangTien(booking.price)}đ',
                  style: AppTextStyles.label.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Badge trạng thái đơn
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (String label, Color bg, Color fg) = switch (status) {
      BookingStatus.dangDienRa => (
        l10n.dangDienRa,
        AppColors.primaryColor.withValues(alpha: 0.12),
        AppColors.primaryColor,
      ),
      BookingStatus.sapToi => (
        l10n.sapToi,
        AppColors.accent.withValues(alpha: 0.12),
        AppColors.accent,
      ),
      BookingStatus.hoanThanh => (
        l10n.hoanThanh,
        AppColors.neutralLight,
        AppColors.textSecondary,
      ),
      BookingStatus.daHuy => (
        l10n.daHuy,
        AppColors.neutralLight,
        AppColors.textSecondary,
      ),
    };
    return AppStatusBadge(label: label, background: bg, textColor: fg);
  }
}
