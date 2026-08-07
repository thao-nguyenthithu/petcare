import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({
    super.key,
    this.chonDuoc = false,
    this.chonKhoang = false,
    this.hienDaQua = true,
    this.hienCoDon = false,
  });

  final bool chonDuoc;
  final bool chonKhoang;
  final bool hienDaQua;
  final bool hienCoDon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _Muc(nhan: l10n.homNay, vien: true),
        if (chonDuoc)
          _Muc(
            nhan: chonKhoang ? l10n.khoangDangChon : l10n.dangChon,
            nen: AppColors.primaryColor,
          ),
        _Muc(nhan: l10n.daKinDon, nen: AppColors.neutral),
        _Muc(nhan: hienDaQua ? l10n.nghiHoacDaQua : l10n.ngayNghi, chuMo: true),
        if (hienCoDon) _Muc(nhan: l10n.coDon, cham: true),
      ],
    );
  }
}

class _Muc extends StatelessWidget {
  const _Muc({
    required this.nhan,
    this.nen,
    this.vien = false,
    this.cham = false,
    this.chuMo = false,
  });

  final String nhan;
  final Color? nen;
  final bool vien;
  final bool cham;
  final bool chuMo;

  @override
  Widget build(BuildContext context) {
    if (cham) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(nhan, style: AppTextStyles.captionSm),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: nen,
            shape: BoxShape.circle,
            border: chuMo
                ? null
                : Border.all(
                    color: vien ? AppColors.primaryColor : AppColors.neutral,
                    width: vien ? 1.6 : 1,
                  ),
          ),
          child: chuMo
              ? Text(
                  '15',
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.neutral,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(nhan, style: AppTextStyles.captionSm),
      ],
    );
  }
}
