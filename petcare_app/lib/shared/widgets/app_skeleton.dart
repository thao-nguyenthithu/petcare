import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';

// Khung xám nhấp nháy thay cho vòng xoay khi đang chờ dữ liệu
class AppSkeleton extends StatefulWidget {
  const AppSkeleton({
    super.key,
    this.width,
    required this.height,
    this.radius = AppRadius.radius14,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dieuKhien = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _dieuKhien.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_dieuKhien),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.neutralLight,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({
    super.key,
    this.soThe = 3,
    this.caoThe = 76,
    this.padding = const EdgeInsets.all(AppSpacing.screenPadding),
  });

  final int soThe;
  final double caoThe;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: soThe,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.itemGap),
      itemBuilder: (_, _) => AppSkeleton(height: caoThe),
    );
  }
}

class AppSkeletonRow extends StatelessWidget {
  const AppSkeletonRow({
    super.key,
    required this.caoThe,
    required this.rongThe,
    this.soThe = 2,
  });

  final double caoThe;
  final double rongThe;
  final int soThe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: caoThe,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: soThe,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.itemGap),
        itemBuilder: (_, _) => AppSkeleton(width: rongThe, height: caoThe),
      ),
    );
  }
}
