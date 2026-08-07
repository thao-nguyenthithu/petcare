import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Thanh chọn dạng segmented
class AppSegmentedTabs extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.nhat = false,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool nhat;

  @override
  Widget build(BuildContext context) {
    final boNgoai = nhat ? AppRadius.radius14 : 999.0;
    final boTrong = nhat ? AppRadius.radius14 - 4 : 999.0;
    return Container(
      padding: EdgeInsets.all(nhat ? 3 : 4),
      decoration: BoxDecoration(
        color: nhat ? AppColors.neutralLight : AppColors.cardMint,
        borderRadius: BorderRadius.circular(boNgoai),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: nhat ? 37 : 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? (nhat ? AppColors.cardMint : AppColors.primaryColor)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(boTrong),
                    border: nhat && i == selectedIndex
                        ? Border.all(color: AppColors.primaryColor)
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: AppTextStyles.label.copyWith(
                      color: i == selectedIndex
                          ? (nhat
                                ? AppColors.primaryColor
                                : AppColors.textWhite)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
