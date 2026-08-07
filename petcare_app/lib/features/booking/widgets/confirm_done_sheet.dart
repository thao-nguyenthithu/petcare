import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

Future<bool> showConfirmDoneSheet(
  BuildContext context, {
  required int soBe,
  required int soAnh,
  required int gioGiuTien,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) =>
        _ConfirmDoneSheet(soBe: soBe, soAnh: soAnh, gioGiuTien: gioGiuTien),
  );
  return ok ?? false;
}

class _ConfirmDoneSheet extends StatelessWidget {
  const _ConfirmDoneSheet({
    required this.soBe,
    required this.soAnh,
    required this.gioGiuTien,
  });

  final int soBe;
  final int soAnh;
  final int gioGiuTien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.groupGap + mq.viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.xacNhanHoanThanhDon, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.textGap),
          Text(l10n.moTaXacNhanHoanThanh, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.stackGap),
          _DongTick(chu: l10n.daNhanLaiDuNBeAnToan('$soBe')),
          const SizedBox(height: AppSpacing.itemGap),
          _DongTick(chu: l10n.daXemNAnhMinhChung('$soAnh')),
          const SizedBox(height: AppSpacing.stackGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Expanded(
                child: Text(
                  l10n.ghiChuSauKhiXacNhan('$gioGiuTien'),
                  style: AppTextStyles.captionSm,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.groupGap),
          AppButton(
            text: l10n.xacNhan,
            color: AppColors.accent,
            onTap: () => Navigator.pop(context, true),
          ),
          const SizedBox(height: AppSpacing.labelGap),
          AppButton(
            text: l10n.deSau,
            flat: true,
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
  }
}

class _DongTick extends StatelessWidget {
  const _DongTick({required this.chu});

  final String chu;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.primaryColor),
        const SizedBox(width: 10),
        Expanded(child: Text(chu, style: AppTextStyles.label)),
      ],
    );
  }
}
