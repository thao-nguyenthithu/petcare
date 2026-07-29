import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Danh sách Đặt lại lần nữa
class RecentBookingList extends StatelessWidget {
  const RecentBookingList({super.key, required this.bookings});

  final List<MockRecentBooking> bookings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var i = 0; i < bookings.length; i++) ...[
            if (i > 0) const AppDongKe(mau: AppColors.neutral, thut: 56),
            _RecentBookingRow(booking: bookings[i]),
          ],
        ],
      ),
    );
  }
}

class _RecentBookingRow extends StatelessWidget {
  const _RecentBookingRow({required this.booking});

  final MockRecentBooking booking;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => baoDangPhatTrien(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                booking.avatar,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.name, style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          booking.title,
                          style: AppTextStyles.captionSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(' · ', style: AppTextStyles.captionSm),
                      Text(booking.distance, style: AppTextStyles.captionSm),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(booking.rating.toStringAsFixed(1), style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
