import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/service/widgets/service_type_card.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';

// Màn tất cả dịch vụ
class ServiceCatalogScreen extends StatelessWidget {
  const ServiceCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.itemGap,
            AppSpacing.screenPadding,
            AppSpacing.groupGap,
          ),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: AppBackButton(),
            ),
            const SizedBox(height: AppSpacing.blockGap),
            Text(l10n.tatCaDichVu, style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.labelGap),
            Text(l10n.chonLoaiDichVuPhuHop, style: AppTextStyles.body),
            const SizedBox(height: AppSpacing.blockGap),
            for (final loai in LoaiDichVu.values) ...[
              ServiceTypeCard(loai: loai),
              const SizedBox(height: AppSpacing.stackGap),
            ],
            const SizedBox(height: AppSpacing.textGap),
          ],
        ),
      ),
    );
  }
}
