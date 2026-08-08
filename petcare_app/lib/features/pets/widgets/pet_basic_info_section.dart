import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/widgets/icon_option_row.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

// Bàn phím số
const _banPhimCan = TextInputType.numberWithOptions(decimal: true);

// Khối Thông tin cơ bản ở bước 1
class PetBasicInfoSection extends StatelessWidget {
  const PetBasicInfoSection({
    super.key,
    required this.tenController,
    required this.giongController,
    required this.ngaySinhController,
    required this.canNangController,
    required this.loai,
    required this.gioiTinh,
    required this.onDoiLoai,
    required this.onDoiGioiTinh,
    required this.onChonGiong,
    required this.onChonNgaySinh,
    required this.validatorTen,
    required this.validatorCanNang,
  });

  final TextEditingController tenController;
  final TextEditingController giongController;
  final TextEditingController ngaySinhController;
  final TextEditingController canNangController;
  final PetSpecies loai;
  final PetGender gioiTinh;
  final ValueChanged<PetSpecies> onDoiLoai;
  final ValueChanged<PetGender> onDoiGioiTinh;
  final VoidCallback onChonGiong;
  final VoidCallback onChonNgaySinh;
  final FormFieldValidator<String> validatorTen;
  final FormFieldValidator<String> validatorCanNang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.thongTinCoBan, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.stackGap),
        AppTextField(
          label: l10n.tenBe,
          hint: l10n.hintTenBe,
          controller: tenController,
          isRequired: true,
          validator: validatorTen,
          height: AppTextField.caoGon,
        ),
        const SizedBox(height: AppSpacing.stackGap),
        Text(l10n.loai, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.textGap),
        IconOptionRow<PetSpecies>(
          selected: loai,
          onChon: onDoiLoai,
          options: [
            IconOption(
              value: PetSpecies.dog,
              label: l10n.cho,
              asset: 'assets/icons/icon_dog.svg',
              size: 30,
            ),
            IconOption(
              value: PetSpecies.cat,
              label: l10n.meo,
              asset: 'assets/icons/icon_cat.svg',
              size: 30,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackGap),
        AppTextField(
          label: l10n.giong,
          hint: l10n.chonGiong,
          controller: giongController,
          readOnly: true,
          onTap: onChonGiong,
          suffixIcon: Icons.chevron_right,
          height: AppTextField.caoGon,
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.ghiChuChonGiongKhac, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.stackGap),
        Text(l10n.gioiTinh, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.textGap),
        IconOptionRow<PetGender>(
          selected: gioiTinh,
          onChon: onDoiGioiTinh,
          options: [
            IconOption(
              value: PetGender.male,
              label: l10n.duc,
              icon: Icons.male,
            ),
            IconOption(
              value: PetGender.female,
              label: l10n.cai,
              icon: Icons.female,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackGap),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppTextField(
                label: l10n.ngaySinh,
                hint: l10n.chonNgay,
                controller: ngaySinhController,
                readOnly: true,
                onTap: onChonNgaySinh,
                suffixIcon: Icons.chevron_right,
                height: AppTextField.caoGon,
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: AppTextField(
                label: l10n.canNangKg,
                hint: l10n.hintSoKg,
                controller: canNangController,
                isRequired: true,
                validator: validatorCanNang,
                keyboardType: _banPhimCan,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  LengthLimitingTextInputFormatter(5),
                ],
                height: AppTextField.caoGon,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        AppNoteBox(text: l10n.ghiChuCanNangBatBuoc),
      ],
    );
  }
}
