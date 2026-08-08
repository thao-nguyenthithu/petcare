import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';

class FilterWeightTiers extends StatelessWidget {
  const FilterWeightTiers({
    super.key,
    required this.daTick,
    required this.theoBeDaChon,
    required this.onDoi,
  });

  final Set<MucCan> daTick;
  final Set<MucCan> theoBeDaChon;
  final ValueChanged<Set<MucCan>> onDoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.mucCanCuaBe, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.textGap),
        Text(l10n.moTaMucCanCuaBe, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.labelGap),
        for (final muc in MucCan.values)
          _Dong(
            nhan: muc.ten(l10n),
            khoa: theoBeDaChon.contains(muc),
            bat: theoBeDaChon.contains(muc) || daTick.contains(muc),
            onDoi: () {
              final moi = {...daTick};
              if (!moi.remove(muc)) moi.add(muc);
              onDoi(moi);
            },
          ),
      ],
    );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({
    required this.nhan,
    required this.bat,
    required this.khoa,
    required this.onDoi,
  });

  final String nhan;
  final bool bat;
  final bool khoa;
  final VoidCallback onDoi;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: khoa ? null : onDoi,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.textGap),
        child: Row(
          children: [
            Checkbox(
              value: bat,
              onChanged: khoa ? null : (_) => onDoi(),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: AppSpacing.labelGap),
            Expanded(child: Text(nhan, style: AppTextStyles.body)),
            if (khoa)
              Text(context.l10n.theoBeDaChon, style: AppTextStyles.captionSm),
          ],
        ),
      ),
    );
  }
}
