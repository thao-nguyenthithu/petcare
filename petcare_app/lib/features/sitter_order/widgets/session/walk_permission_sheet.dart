import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Ba sheet của chuỗi xin quyền chia sẻ vị trí phiên dắt
enum LuaChonQuyenNen { moCaiDat, tiepTucThieu }

// Giải thích trước khi bật hộp thoại hệ thống
Future<bool> moSheetGioiThieuChiaSe(BuildContext context) async {
  final l10n = context.l10n;
  final ketQua = await _moSheet<bool>(
    context,
    _NoiDungSheet(
      icon: Icons.share_location_outlined,
      tieuDe: l10n.chiaSeViTriChoChuNuoi,
      moTa: l10n.moTaChiaSeViTriNen,
      nutChinh: l10n.tiepTuc,
      giaTriChinh: true,
      nutPhu: l10n.deSau,
    ),
  );
  return ketQua ?? false;
}

Future<LuaChonQuyenNen?> moSheetThieuQuyenNen(BuildContext context) {
  final l10n = context.l10n;
  return _moSheet<LuaChonQuyenNen>(
    context,
    _NoiDungSheet(
      icon: Icons.location_off_outlined,
      tieuDe: l10n.thieuQuyenNenTieuDe,
      moTa: l10n.thieuQuyenNenMoTa,
      nutChinh: l10n.moCaiDat,
      giaTriChinh: LuaChonQuyenNen.moCaiDat,
      nutPhu: l10n.tiepTucThieuQuyenNen,
      giaTriPhu: LuaChonQuyenNen.tiepTucThieu,
    ),
  );
}

// Xin bỏ tối ưu pin
Future<bool> moSheetBoToiUuPin(BuildContext context) async {
  final l10n = context.l10n;
  final ketQua = await _moSheet<bool>(
    context,
    _NoiDungSheet(
      icon: Icons.battery_saver_outlined,
      tieuDe: l10n.boToiUuPinTieuDe,
      moTa: l10n.boToiUuPinMoTa,
      nutChinh: l10n.tiepTuc,
      giaTriChinh: true,
      nutPhu: l10n.boQua,
    ),
  );
  return ketQua ?? false;
}

Future<T?> _moSheet<T>(BuildContext context, Widget noiDung) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius14),
      ),
    ),
    builder: (context) => noiDung,
  );
}

class _NoiDungSheet<T> extends StatelessWidget {
  const _NoiDungSheet({
    required this.icon,
    required this.tieuDe,
    required this.moTa,
    required this.nutChinh,
    required this.giaTriChinh,
    required this.nutPhu,
    this.giaTriPhu,
  });

  final IconData icon;
  final String tieuDe;
  final String moTa;
  final String nutChinh;
  final T giaTriChinh;
  final String nutPhu;
  final T? giaTriPhu;

  @override
  Widget build(BuildContext context) {
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
              child: Icon(icon, size: 40, color: AppColors.accent),
            ),
            const SizedBox(height: AppSpacing.blockGap),
            Text(tieuDe, style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.labelGap),
            Text(moTa, style: AppTextStyles.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.groupGap),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(giaTriChinh),
              child: Text(nutChinh),
            ),
            const SizedBox(height: AppSpacing.textGap),
            TextButton(
              onPressed: () => Navigator.of(context).pop(giaTriPhu),
              child: Text(
                nutPhu,
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
