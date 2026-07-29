import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';

// Dải vạch tiến độ của luồng nhiều bước, vạch đã qua tô xanh
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.buoc,
    required this.tong,
    this.dayVach = 3,
    this.khe = 6,
    this.mauChuaQua = AppColors.neutralLight,
    this.padding,
  });

  // Số bước đã hoàn thành, tính từ 1
  final int buoc;
  final int tong;
  final double dayVach;
  final double khe;
  final Color mauChuaQua;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final dai = Row(
      children: [
        for (var i = 1; i <= tong; i++) ...[
          if (i > 1) SizedBox(width: khe),
          Expanded(
            child: Container(
              height: dayVach,
              decoration: BoxDecoration(
                color: i <= buoc ? AppColors.primaryColor : mauChuaQua,
                borderRadius: BorderRadius.circular(dayVach / 2),
              ),
            ),
          ),
        ],
      ],
    );
    return padding == null ? dai : Padding(padding: padding!, child: dai);
  }
}
