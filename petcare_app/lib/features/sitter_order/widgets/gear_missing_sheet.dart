import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';
import 'package:petcare_app/features/sitter_order/widgets/handover_photo_group.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
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
  final List<Uint8List> _anh = [];

  Future<void> _chup() async {
    if (_anh.length >= soAnhThieuDungCuToiDa) return;
    final chon = await chupMotAnh();
    if (!mounted) return;
    if (chon.quaNang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
      return;
    }
    final bytes = chon.anh;
    if (bytes == null) return;
    setState(() => _anh.add(bytes));
  }

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
            HandoverPhotoGroup(
              tieuDe: l10n.anhThayRoBeTrenTran(
                '${_anh.length}',
                '$soAnhThieuDungCuToiDa',
              ),
              anh: _anh,
              tran: soAnhThieuDungCuToiDa,
              onThem: _chup,
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
