import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_booking_filter.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/chip_chon.dart';
import 'package:petcare_app/shared/widgets/sheet_drag_handle.dart';

Future<BoLocDon?> moSheetLocDon(
  BuildContext context, {
  required BoLocDon boLoc,
  required Map<LoaiDichVu, int> soDonMoiDichVu,
  BoLocDon macDinh = const BoLocDon(),
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<BoLocDon>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _SheetLocDon(
      boLoc: boLoc,
      macDinh: macDinh,
      soDonMoiDichVu: soDonMoiDichVu,
    ),
  );
}

class _SheetLocDon extends StatefulWidget {
  const _SheetLocDon({
    required this.boLoc,
    required this.macDinh,
    required this.soDonMoiDichVu,
  });

  final BoLocDon boLoc;
  final BoLocDon macDinh;

  final Map<LoaiDichVu, int> soDonMoiDichVu;

  @override
  State<_SheetLocDon> createState() => _SheetLocDonState();
}

class _SheetLocDonState extends State<_SheetLocDon> {
  late Set<LoaiDichVu> _dichVu = {...widget.boLoc.dichVu};
  late KyThongKe _ky = widget.boLoc.ky;

  void _doiDichVu(LoaiDichVu dv) => setState(() {
    if (!_dichVu.remove(dv)) _dichVu.add(dv);
  });

  void _xoaLoc() => setState(() {
    _dichVu = {...widget.macDinh.dichVu};
    _ky = widget.macDinh.ky;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.blockGap,
        AppSpacing.labelGap,
        AppSpacing.blockGap,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetDragHandle(),
          const SizedBox(height: AppSpacing.blockGap),
          Row(
            children: [
              Expanded(child: Text(l10n.locDon, style: AppTextStyles.h3)),
              TextButton(onPressed: _xoaLoc, child: Text(l10n.xoaLoc)),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _NhanNhom(l10n.dichVu.toUpperCase()),
          const SizedBox(height: AppSpacing.itemGap),
          for (final dv in LoaiDichVu.values) ...[
            _DongDichVu(
              dichVu: dv,
              chon: _dichVu.contains(dv),
              soDon: widget.soDonMoiDichVu[dv] ?? 0,
              onTap: () => _doiDichVu(dv),
            ),
            if (dv != LoaiDichVu.values.last)
              const SizedBox(height: AppSpacing.labelGap),
          ],
          const SizedBox(height: AppSpacing.blockGap),
          _NhanNhom(l10n.kyThoiGian.toUpperCase()),
          const SizedBox(height: AppSpacing.itemGap),
          Wrap(
            spacing: AppSpacing.labelGap,
            runSpacing: AppSpacing.labelGap,
            children: [
              for (final ky in [
                ...kyNhanh,
                if (!kyNhanh.any(_ky.giongVoi)) _ky,
              ])
                ChipChon(
                  nhan: ky.nhanNhanh(l10n),
                  chon: ky.giongVoi(_ky),
                  onTap: () => setState(() => _ky = ky),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.groupGap),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(BoLocDon(dichVu: _dichVu, ky: _ky)),
                  child: Text(l10n.xem),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NhanNhom extends StatelessWidget {
  const _NhanNhom(this.nhan);

  final String nhan;

  @override
  Widget build(BuildContext context) => Text(
    nhan,
    style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
  );
}

class _DongDichVu extends StatelessWidget {
  const _DongDichVu({
    required this.dichVu,
    required this.chon,
    required this.soDon,
    required this.onTap,
  });

  final LoaiDichVu dichVu;
  final bool chon;
  final int soDon;
  final VoidCallback onTap;

  static const double _cham = 8;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: chon ? AppColors.cardMint : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: AppSpacing.labelGap,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(
              color: chon ? AppColors.primaryColor : AppColors.neutralLight,
            ),
          ),
          child: Row(
            children: [
              IgnorePointer(
                child: Checkbox(
                  value: chon,
                  onChanged: (_) {},
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Container(
                width: _cham,
                height: _cham,
                decoration: BoxDecoration(
                  color: dichVu.mauCham,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Text(
                  dichVu.ten(l10n),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Text(l10n.soDon('$soDon'), style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ),
    );
  }
}
