import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';

// Không có người chăm nào khớp
class SearchEmptyResult extends StatelessWidget {
  const SearchEmptyResult({super.key, required this.onChonTuKhoa});

  final ValueChanged<String> onChonTuKhoa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        40,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      children: [
        AppEmptyState(
          icon: Icons.search_off_rounded,
          title: l10n.khongTimThayKetQua,
          message: l10n.moTaKhongTimThay,
        ),
        const SizedBox(height: AppSpacing.screenEdgeGap),
        Text(
          l10n.coTheBanQuanTam,
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.titleGap),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.labelGap,
          runSpacing: AppSpacing.labelGap,
          children: [
            for (final loai in LoaiDichVu.values)
              ActionChip(
                label: Text(loai.ten(l10n)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onPressed: () => onChonTuKhoa(loai.ten(l10n)),
              ),
          ],
        ),
      ],
    );
  }
}
