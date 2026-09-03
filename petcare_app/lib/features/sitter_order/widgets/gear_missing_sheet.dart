import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Báo thiếu rọ mõm hoặc dây xích, không ảnh thì không gửi được
Future<List<Uint8List>?> showGearMissingSheet(BuildContext context) {
  return showModalBottomSheet<List<Uint8List>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _GearMissingSheet(),
  );
}

class _GearMissingSheet extends StatefulWidget {
  const _GearMissingSheet();

  @override
  State<_GearMissingSheet> createState() => _GearMissingSheetState();
}

class _GearMissingSheetState extends State<_GearMissingSheet> {
  List<Uint8List> _anh = [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.beThieuRoMomHoacDayXich, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(
              l10n.nhacAnhThayRoBe('$soAnhThieuDungCuToiThieu'),
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.blockGap),
            PhotoPickerGrid(
              tieuDe: l10n.anhThayRoBeTrenTran(
                '${_anh.length}',
                '$soAnhThieuDungCuToiDa',
              ),
              anh: _anh,
              tran: soAnhThieuDungCuToiDa,
              onDoi: (ds) => setState(() => _anh = ds),
              batBuocChup: true,
            ),
            const SizedBox(height: AppSpacing.blockGap),
            AppButton(
              text: l10n.guiBaoThieuDungCu,
              height: 50,
              color: AppColors.accent,
              enabled: _anh.length >= soAnhThieuDungCuToiThieu,
              onTap: () => Navigator.of(context).pop(_anh),
            ),
          ],
        ),
      ),
    );
  }
}
