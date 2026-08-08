import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Bảng chọn số bé cần chăm sóc, chỉ đếm tổng chứ không tách chó mèo
Future<int?> showPetCountSheet({
  required BuildContext context,
  required int banDau,
}) {
  return showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _PetCountSheet(banDau: banDau),
  );
}

class _PetCountSheet extends StatefulWidget {
  const _PetCountSheet({required this.banDau});

  final int banDau;

  @override
  State<_PetCountSheet> createState() => _PetCountSheetState();
}

class _PetCountSheetState extends State<_PetCountSheet> {
  static const int _toiThieu = 1;
  static const int _toiDa = 10;

  late int _soBe = widget.banDau < _toiThieu ? _toiThieu : widget.banDau;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPaddingWide,
          0,
          AppSpacing.screenPaddingWide,
          AppSpacing.screenPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(l10n.baoNhieuBeCanCham, style: AppTextStyles.h2),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 0),
                  child: Text(
                    l10n.xoaBoLoc,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.labelGap),
            Text(l10n.moTaSoBeCanCham, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.blockGap),
            _HangDemBe(
              ten: l10n.be,
              so: _soBe,
              toiThieu: _toiThieu,
              toiDa: _toiDa,
              onDoi: (v) => setState(() => _soBe = v),
            ),
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: l10n.xemKetQua,
              onTap: () => Navigator.pop(context, _soBe),
            ),
          ],
        ),
      ),
    );
  }
}

class _HangDemBe extends StatelessWidget {
  const _HangDemBe({
    required this.ten,
    required this.so,
    required this.toiThieu,
    required this.toiDa,
    required this.onDoi,
  });

  final String ten;
  final int so;
  final int toiThieu;
  final int toiDa;
  final ValueChanged<int> onDoi;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.pets_rounded, size: 22, color: AppColors.textPrimary),
        const SizedBox(width: AppSpacing.itemGap),
        Expanded(child: Text(ten, style: AppTextStyles.label)),
        _NutTron(
          icon: Icons.remove_rounded,
          bat: so > toiThieu,
          onTap: () => onDoi(so - 1),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$so',
            textAlign: TextAlign.center,
            style: AppTextStyles.label,
          ),
        ),
        _NutTron(
          icon: Icons.add_rounded,
          bat: so < toiDa,
          onTap: () => onDoi(so + 1),
        ),
      ],
    );
  }
}

class _NutTron extends StatelessWidget {
  const _NutTron({required this.icon, required this.bat, required this.onTap});

  final IconData icon;
  final bool bat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      onPressed: bat ? onTap : null,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textWhite,
        disabledBackgroundColor: AppColors.neutral,
        disabledForegroundColor: AppColors.textWhite,
        minimumSize: const Size(36, 36),
      ),
    );
  }
}
