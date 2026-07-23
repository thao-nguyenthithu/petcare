import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Thanh tab trạng thái đơn
class BookingStatusTabBar extends StatelessWidget {
  const BookingStatusTabBar({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.only(left: AppSpacing.screenPaddingWide),
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.label,
      unselectedLabelStyle: AppTextStyles.label,
      indicatorSize: TabBarIndicatorSize.label,
      indicatorColor: AppColors.primaryColor,
      dividerColor: AppColors.neutralLight,
      indicator: const UnderlineTabIndicator(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        borderSide: BorderSide(width: 3, color: AppColors.primaryColor),
      ),
      tabs: [for (final label in labels) Tab(text: label)],
    );
  }
}
