import 'package:flutter/material.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

const double leMucPhang = 18;

class FlatSection extends StatelessWidget {
  const FlatSection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: leMucPhang),
    child: child,
  );
}

class FlatDivider extends StatelessWidget {
  const FlatDivider({super.key, this.dem = 16});

  final double dem;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: dem),
    child: const AppDongKe(),
  );
}
