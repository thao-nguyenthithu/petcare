import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/service/data/mock_service_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

// Card mô tả dịch vụ
class ServiceTypeCard extends StatelessWidget {
  const ServiceTypeCard({super.key, required this.service});

  final MockServiceType service;

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
        onTap: () => baoDangPhatTrien(context),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.itemGap),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
                child: Image.asset(
                  service.image,
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
                    Text(_ten(l10n), style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      _moTa(l10n),
                      style: AppTextStyles.captionSm,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.labelGap),
                    Text(
                      _giaHienThi(l10n),
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.labelGap),
          ],
        ),
      ),
    );
  }

  String _ten(AppLocalizations l10n) => switch (service.loai) {
    LoaiDichVu.datDiDao => l10n.datDiDao,
    LoaiDichVu.trongGiu => l10n.trongGiu,
    LoaiDichVu.catTia => l10n.tamVaTia,
  };

  String _moTa(AppLocalizations l10n) => switch (service.loai) {
    LoaiDichVu.datDiDao => l10n.moTaLoaiDatDiDao,
    LoaiDichVu.trongGiu => l10n.moTaLoaiTrongGiu,
    LoaiDichVu.catTia => l10n.moTaLoaiCatTia,
  };

  // Ghép "từ 50.000" + "đ / lượt / bé" từ các key đã có sẵn trong ARB
  String _giaHienThi(AppLocalizations l10n) {
    final donVi = switch (service.loai) {
      LoaiDichVu.datDiDao => l10n.donGiaLuot,
      LoaiDichVu.trongGiu => l10n.donGiaNgay,
      LoaiDichVu.catTia => l10n.donGiaBe,
    };
    final duoi = service.theoCanNang ? l10n.theoCan : '';
    return '${l10n.tuGia(service.giaTu)}$donVi$duoi';
  }
}
