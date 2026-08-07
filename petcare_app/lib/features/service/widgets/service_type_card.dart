import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

// Card mô tả dịch vụ
class ServiceTypeCard extends StatelessWidget {
  const ServiceTypeCard({super.key, required this.loai});

  final LoaiDichVu loai;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.searchPath(dichVu: loai.maApi)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.itemGap),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
                child: Image.asset(
                  loai.anhMinhHoa,
                  width: 104,
                  height: 104,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.itemGap,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(loai.ten(l10n), style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(_moTa(l10n), style: AppTextStyles.captionSm),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.labelGap),
          ],
        ),
      ),
    );
  }

  String _moTa(AppLocalizations l10n) => switch (loai) {
    LoaiDichVu.datDiDao => l10n.moTaLoaiDatDiDao,
    LoaiDichVu.trongGiu => l10n.moTaLoaiTrongGiu,
    LoaiDichVu.catTia => l10n.moTaLoaiCatTia,
  };
}
