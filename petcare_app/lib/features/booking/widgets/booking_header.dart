import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

const double _avatar = 38;

// Header dùng chung cho các trang trong luồng đặt lịch
class BookingHeader extends StatelessWidget {
  const BookingHeader({
    super.key,
    required this.tieuDe,
    required this.tenNcc,
    required this.tenDichVu,
    this.avatarUrl,
  });

  final String tieuDe;
  final String tenNcc;
  final String tenDichVu;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(tieuDe, style: AppTextStyles.h3, maxLines: 1),
                const SizedBox(height: 2),
                Text(
                  '$tenNcc · $tenDichVu',
                  style: AppTextStyles.captionSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          UserAvatar(name: tenNcc, imageUrl: avatarUrl, size: _avatar),
        ],
      ),
    );
  }
}
