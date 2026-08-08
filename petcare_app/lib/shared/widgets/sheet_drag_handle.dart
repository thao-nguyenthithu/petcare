import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  static const double _rong = 40;
  static const double _cao = 4;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: _rong,
        height: _cao,
        decoration: BoxDecoration(
          color: AppColors.neutral,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
