import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

enum KetQuaQuyenViTri { daCap, tuChoi, tuChoiVinhVien, dichVuTat }

// Mở bottom sheet xin quyền vị trí
Future<KetQuaQuyenViTri?> moSheetQuyenViTri(BuildContext context) {
  return showModalBottomSheet<KetQuaQuyenViTri>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius14),
      ),
    ),
    builder: (context) => const _LocationPermissionSheet(),
  );
}

// Hỏi hệ thống cấp quyền vị trí
Future<KetQuaQuyenViTri> xinQuyenViTri() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return KetQuaQuyenViTri.dichVuTat;
  }
  var quyen = await Geolocator.checkPermission();
  if (quyen == LocationPermission.denied) {
    quyen = await Geolocator.requestPermission();
  }
  return switch (quyen) {
    LocationPermission.always ||
    LocationPermission.whileInUse => KetQuaQuyenViTri.daCap,
    LocationPermission.deniedForever => KetQuaQuyenViTri.tuChoiVinhVien,
    _ => KetQuaQuyenViTri.tuChoi,
  };
}

class _LocationPermissionSheet extends StatefulWidget {
  const _LocationPermissionSheet();

  @override
  State<_LocationPermissionSheet> createState() =>
      _LocationPermissionSheetState();
}

class _LocationPermissionSheetState extends State<_LocationPermissionSheet> {
  bool _dangXin = false;

  Future<void> _choPhep() async {
    setState(() => _dangXin = true);
    final ketQua = await xinQuyenViTri();
    if (!mounted) return;
    Navigator.of(context).pop(ketQua);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingWide,
          AppSpacing.itemGap,
          AppSpacing.screenPaddingWide,
          AppSpacing.cardPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.cardMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: AppSpacing.blockGap),
            Text(
              l10n.choPhepTruyCapViTri,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              l10n.moTaQuyenViTri,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.groupGap),
            FilledButton(
              onPressed: _dangXin ? null : _choPhep,
              child: Text(_dangXin ? l10n.dangLayViTri : l10n.choPhepTruyCap),
            ),
            const SizedBox(height: AppSpacing.textGap),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.deSau,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
