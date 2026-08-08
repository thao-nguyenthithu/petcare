import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/shared/utils/song_ngu.dart';

// Nhãn tình trạng bé của kỳ trông giữ, chọn nhiều và không bắt buộc
class PetConditionChips extends StatelessWidget {
  const PetConditionChips({
    super.key,
    required this.tieuDe,
    required this.ma,
    required this.dangChon,
    required this.onDoi,
  });

  final String tieuDe;
  final List<String> ma;
  final Set<String> dangChon;
  final void Function(String ma, bool chon) onDoi;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in ma)
              FilterChip(
                label: Text(
                  tenSongNgu(
                    context,
                    vi: tenTinhTrangBeTrongGiu[m]!.$1,
                    en: tenTinhTrangBeTrongGiu[m]!.$2,
                  ),
                ),
                selected: dangChon.contains(m),
                onSelected: (chon) => onDoi(m, chon),
              ),
          ],
        ),
      ],
    );
  }
}
