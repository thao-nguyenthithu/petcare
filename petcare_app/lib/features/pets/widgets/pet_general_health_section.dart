import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

// Khối Tình trạng chung ở bước 2
class PetGeneralHealthSection extends StatelessWidget {
  const PetGeneralHealthSection({
    super.key,
    required this.daTrietSan,
    required this.dangDieuTri,
    required this.onDoiTrietSan,
    required this.onDoiSucKhoe,
    required this.benhNenController,
    required this.thuocController,
  });

  final bool daTrietSan;
  final bool dangDieuTri;
  final ValueChanged<bool> onDoiTrietSan;
  final ValueChanged<bool> onDoiSucKhoe;
  final TextEditingController benhNenController;
  final TextEditingController thuocController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tinhTrangChung, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.stackGap),
        Text(l10n.daTrietSan, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.labelGap),
        AppSegmentedTabs(
          nhat: true,
          labels: [l10n.roi, l10n.chuaTrietSan],
          selectedIndex: daTrietSan ? 0 : 1,
          onChanged: (i) => onDoiTrietSan(i == 0),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        Text(l10n.tinhTrangSucKhoe, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.labelGap),
        AppSegmentedTabs(
          nhat: true,
          labels: [l10n.binhThuong, l10n.dangDieuTri],
          selectedIndex: dangDieuTri ? 1 : 0,
          onChanged: (i) => onDoiSucKhoe(i == 1),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        AppTextField(
          label: l10n.benhNenDiUng,
          hint: l10n.hintNhapNeuCo,
          controller: benhNenController,
          height: AppTextField.caoGon,
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.ghiChuBenhNen, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.stackGap),
        AppTextField(
          label: l10n.thuocDangDung,
          hint: l10n.hintNhapNeuCo,
          controller: thuocController,
          height: AppTextField.caoGon,
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.ghiChuThuocDangDung, style: AppTextStyles.captionSm),
      ],
    );
  }
}
