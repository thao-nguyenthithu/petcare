import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Nhiều tab thì cuộn ngang, hai ba tab thì chia đều bề ngang
class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, required this.labels, this.cuon = true});

  final List<String> labels;
  final bool cuon;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: cuon,
      tabAlignment: cuon ? TabAlignment.start : TabAlignment.fill,
      padding: cuon
          ? const EdgeInsets.only(left: AppSpacing.screenPaddingWide)
          : null,
      labelColor: AppColors.primaryColor,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.label,
      unselectedLabelStyle: AppTextStyles.label,
      indicatorSize: cuon ? TabBarIndicatorSize.label : TabBarIndicatorSize.tab,
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
