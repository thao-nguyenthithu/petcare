import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/owner_home.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';
import 'package:petcare_app/shared/utils/diem_so.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Danh sách Đặt lại lần nữa
class RecentBookingList extends StatelessWidget {
  const RecentBookingList({super.key, required this.bookings});

  final List<NguoiChamDaDat> bookings;

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

  final NguoiChamDaDat booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: () => baoDangPhatTrien(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            UserAvatar(name: booking.name, imageUrl: booking.avatar, size: 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(booking.name, style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  // Chật thì cắt bớt chứ không xuống dòng
                  Text(
                    '${booking.serviceType.ten(l10n)} · '
                    '${l10n.daDatSoLan('${booking.timesBooked}')}',
                    style: AppTextStyles.captionSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(soDiem(booking.rating), style: AppTextStyles.label),
          ],
        ),
      ),
    );
  }
}
