import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const double _dem = 14;

// Nội dung mỗi gói do nền tảng quy định
class GroomingPackageNote extends StatelessWidget {
  const GroomingPackageNote({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      nen: AppColors.background,
      padding: const EdgeInsets.all(_dem),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.moiGoiGomNhungViecGi, style: AppTextStyles.captionSm),
          const SizedBox(height: 8),
          _Dong(ten: l10n.chiTam, mo: l10n.moTaGoiChiTam),
          const SizedBox(height: 8),
          _Dong(ten: l10n.tamVaCatTia, mo: l10n.moTaGoiTamVaCatTia),
        ],
      ),
    );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({required this.ten, required this.mo});

  final String ten;
  final String mo;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(ten, style: AppTextStyles.label),
      const SizedBox(height: 2),
      Text(mo, style: AppTextStyles.captionSm),
    ],
  );
}
