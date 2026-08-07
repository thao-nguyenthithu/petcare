import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

Future<BoLocTimKiem?> showSortFilterSheet({
  required BuildContext context,
  required BoLocTimKiem boLoc,
}) {
  return showModalBottomSheet<BoLocTimKiem>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SortFilterSheet(boLoc: boLoc),
  );
}

class _SortFilterSheet extends StatefulWidget {
  const _SortFilterSheet({required this.boLoc});

  final BoLocTimKiem boLoc;

  @override
  State<_SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<_SortFilterSheet> {
  late BoLocTimKiem _boLoc = widget.boLoc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingWide,
            ),
            children: [
              Text(l10n.sapXepTheo, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.labelGap),
              RadioGroup<SapXepKetQua>(
                groupValue: _boLoc.sapXep,
                onChanged: (cach) =>
                    setState(() => _boLoc = _boLoc.copyWith(sapXep: cach)),
                child: Column(
                  children: [
                    for (final cach in SapXepKetQua.values)
                      _DongSapXep(
                        cach: cach,
                        icon: _icon(cach),
                        nhan: _tenCach(l10n, cach),
                        dangChon: _boLoc.sapXep == cach,
                        onTap: () => setState(
                          () => _boLoc = _boLoc.copyWith(sapXep: cach),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.labelGap),
              const AppDongKe(),
              const SizedBox(height: AppSpacing.stackGap),
              Text(l10n.locNhanh, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.labelGap),
              _DongLocNhanh(
                iconAsset: 'assets/icons/icon_dog.svg',
                nhan: l10n.cho,
                bat: _boLoc.nhanCho,
                onDoi: (v) =>
                    setState(() => _boLoc = _boLoc.copyWith(nhanCho: v)),
              ),
              _DongLocNhanh(
                iconAsset: 'assets/icons/icon_cat.svg',
                nhan: l10n.meo,
                bat: _boLoc.nhanMeo,
                khoa: _boLoc.epLoaiCho,
                onDoi: (v) =>
                    setState(() => _boLoc = _boLoc.copyWith(nhanMeo: v)),
              ),
              _DongLocNhanh(
                icon: Icons.verified_user_outlined,
                nhan: l10n.nguoiChamTinCay,
                bat: _boLoc.chiTinCay,
                onDoi: (v) =>
                    setState(() => _boLoc = _boLoc.copyWith(chiTinCay: v)),
              ),
              _DongLocNhanh(
                icon: Icons.shower_outlined,
                nhan: l10n.chiTam,
                bat: _boLoc.dichVu == MucLocDichVu.chiTam,
                onDoi: (v) => setState(
                  () => _boLoc = _boLoc.copyWith(
                    dichVu: v ? MucLocDichVu.chiTam : MucLocDichVu.catTiaTatCa,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingWide,
              0,
              AppSpacing.screenPaddingWide,
              AppSpacing.screenPadding,
            ),
            child: AppButton(
              text: l10n.xemKetQua,
              onTap: () => Navigator.pop(context, _boLoc),
            ),
          ),
        ),
      ],
    );
  }

  IconData _icon(SapXepKetQua cach) => switch (cach) {
    SapXepKetQua.deXuat => Icons.thumb_up_outlined,
    SapXepKetQua.ganNhat => Icons.location_on_outlined,
    SapXepKetQua.danhGiaCao => Icons.star_border_rounded,
    SapXepKetQua.nhieuDon => Icons.bar_chart_rounded,
    SapXepKetQua.itHuyMuon => Icons.block_outlined,
  };

  String _tenCach(AppLocalizations l10n, SapXepKetQua cach) => switch (cach) {
    SapXepKetQua.deXuat => l10n.duocDeXuat,
    SapXepKetQua.ganNhat => l10n.ganBanNhat,
    SapXepKetQua.danhGiaCao => l10n.danhGiaCaoNhat,
    SapXepKetQua.nhieuDon => l10n.nhieuDonHoanThanhNhat,
    SapXepKetQua.itHuyMuon => l10n.tyLeHuyMuonThapNhat,
  };
}

class _DongSapXep extends StatelessWidget {
  const _DongSapXep({
    required this.cach,
    required this.icon,
    required this.nhan,
    required this.dangChon,
    required this.onTap,
  });

  final SapXepKetQua cach;
  final IconData icon;
  final String nhan;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.textGap),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: dangChon
                  ? AppColors.primaryColor
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Text(
                nhan,
                style: (dangChon ? AppTextStyles.label : AppTextStyles.body)
                    .copyWith(color: AppColors.textPrimary),
              ),
            ),
            Radio<SapXepKetQua>(
              value: cach,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

// Một lọc nhanh: icon + tên + ô tích
class _DongLocNhanh extends StatelessWidget {
  const _DongLocNhanh({
    required this.nhan,
    required this.bat,
    required this.onDoi,
    this.icon,
    this.iconAsset,
    this.khoa = false,
  }) : assert(
         (icon == null) != (iconAsset == null),
         'Truyền đúng một trong hai: icon hoặc iconAsset',
       );

  final IconData? icon;
  final String? iconAsset;
  final String nhan;
  final bool bat;
  final ValueChanged<bool> onDoi;
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: khoa ? null : () => onDoi(!bat),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.textGap),
        child: Row(
          children: [
            _Icon(icon: icon, iconAsset: iconAsset, bat: bat, khoa: khoa),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Text(
                nhan,
                style: khoa
                    ? AppTextStyles.body.copyWith(color: AppColors.neutral)
                    : AppTextStyles.body,
              ),
            ),
            Checkbox(
              value: bat,
              onChanged: khoa ? null : (v) => onDoi(v ?? false),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    required this.icon,
    required this.iconAsset,
    required this.bat,
    required this.khoa,
  });

  static const double _co = 20;

  final IconData? icon;
  final String? iconAsset;
  final bool bat;
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    final mau = khoa
        ? AppColors.neutral
        : (bat ? AppColors.primaryColor : AppColors.textSecondary);
    if (iconAsset != null) {
      return SvgPicture.asset(
        iconAsset!,
        width: _co,
        height: _co,
        colorFilter: ColorFilter.mode(mau, BlendMode.srcIn),
      );
    }
    return Icon(icon, size: _co, color: mau);
  }
}
