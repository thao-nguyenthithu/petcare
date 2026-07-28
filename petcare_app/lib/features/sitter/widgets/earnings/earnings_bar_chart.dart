import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_earnings.dart';

// Biểu đồ cột thu nhập
class EarningsBarChart extends StatelessWidget {
  const EarningsBarChart({
    super.key,
    required this.bars,
    required this.selected,
    required this.onSelect,
  });

  final List<EarningsBar> bars;
  final int selected;
  final ValueChanged<int> onSelect;

  static const double _maxHeight = 120;

  @override
  Widget build(BuildContext context) {
    final maxAmount = bars.fold<int>(0, (m, b) => b.amount > m ? b.amount : m);
    return SizedBox(
      height: _maxHeight + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: bars[i].upcoming ? null : () => onSelect(i),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Mốc chưa diễn ra
                    Container(
                      width: 20,
                      height: bars[i].upcoming
                          ? 6
                          : (maxAmount == 0
                                ? 6
                                : (_maxHeight * bars[i].amount / maxAmount)
                                      .clamp(6, _maxHeight)),
                      decoration: BoxDecoration(
                        color: bars[i].upcoming
                            ? AppColors.neutralLight.withValues(alpha: 0.5)
                            : (i == selected
                                  ? AppColors.primaryColor
                                  : AppColors.cardMint),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bars[i].label,
                      style: AppTextStyles.captionSm.copyWith(
                        fontSize: 11,
                        fontWeight: i == selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: bars[i].upcoming
                            ? AppColors.textSecondary.withValues(alpha: 0.5)
                            : (i == selected ? AppColors.primaryColor : null),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
