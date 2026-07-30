import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/grooming_form.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

const _banPhimSo = TextInputType.numberWithOptions(
  signed: false,
  decimal: false,
);

const double _rongOPhut = 104;
const double _caoO = 46;

// Một mức cân trong bảng giá grooming
class GroomingTierCard extends StatelessWidget {
  const GroomingTierCard({
    super.key,
    required this.nhan,
    required this.hintGia,
    required this.hintPhut,
    required this.gia,
    required this.phut,
    required this.oGia,
    required this.oPhut,
    required this.chon,
    required this.loi,
    required this.onToggle,
  });

  final String nhan;
  final String hintGia;
  final String hintPhut;
  final TextEditingController gia;
  final TextEditingController phut;
  final FocusNode oGia;
  final FocusNode oPhut;
  final bool chon;
  final GroomingTierError? loi;
  final ValueChanged<bool> onToggle;

  String? _cauLoi(BuildContext context) => switch (loi) {
    null => null,
    GroomingTierError.trong => context.l10n.thongTinKhongDuocBoTrong,
    GroomingTierError.giaKhongHopLe => context.l10n.loiGiaPhaiLonHonKhong,
    GroomingTierError.thoiLuong => context.l10n.loiThoiLuongGrooming(
      '$groomingPhutToiThieu',
      '$groomingPhutToiDa',
      '$groomingPhutBuoc',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loiGia =
        loi == GroomingTierError.giaKhongHopLe ||
        (loi == GroomingTierError.trong && docSoTien(gia.text) == null);
    final loiPhut =
        loi == GroomingTierError.thoiLuong ||
        (loi == GroomingTierError.trong && int.tryParse(phut.text) == null);
    final cauLoi = _cauLoi(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(14, 12, 14, chon ? 14 : 12),
          decoration: BoxDecoration(
            color: chon ? AppColors.surface : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(
              color: loi != null ? AppColors.error : AppColors.neutral,
              width: loi != null ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Material trong suốt để vệt chạm nổi trên nền thẻ
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => onToggle(!chon),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: chon,
                          onChanged: (v) => onToggle(v ?? false),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          side: const BorderSide(color: AppColors.neutral),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        nhan,
                        style: AppTextStyles.label.copyWith(
                          color: chon
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (!chon)
                        Text(
                          l10n.chamDeNhanMucNay,
                          style: AppTextStyles.captionSm,
                        ),
                    ],
                  ),
                ),
              ),
              if (chon) ...[
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _ONhap(
                        nhan: l10n.giaMoiBe,
                        hint: hintGia,
                        donVi: l10n.donViDong,
                        controller: gia,
                        focusNode: oGia,
                        formatters: const [DinhDangTienFormatter()],
                        loi: loiGia,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: _rongOPhut,
                      child: _ONhap(
                        nhan: l10n.thoiLuong,
                        hint: hintPhut,
                        donVi: l10n.donViPhut,
                        controller: phut,
                        focusNode: oPhut,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        loi: loiPhut,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (cauLoi != null) ...[
          const SizedBox(height: 6),
          Text(
            cauLoi,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

// Ô nhập có nhãn nhỏ phía trên và đơn vị nằm mép phải trong khung
class _ONhap extends StatelessWidget {
  const _ONhap({
    required this.nhan,
    required this.hint,
    required this.donVi,
    required this.controller,
    required this.focusNode,
    required this.formatters,
    required this.loi,
  });

  final String nhan;
  final String hint;
  final String donVi;
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<TextInputFormatter> formatters;
  final bool loi;

  OutlineInputBorder _vien(Color mau, double day) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.radius14),
    borderSide: BorderSide(color: mau, width: day),
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(nhan, style: AppTextStyles.captionSm),
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: _banPhimSo,
        inputFormatters: formatters,
        style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.caption,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: (_caoO - 22) / 2,
          ),
          enabledBorder: _vien(
            loi ? AppColors.error : AppColors.neutral,
            loi ? 1.5 : 1,
          ),
          focusedBorder: _vien(
            loi ? AppColors.error : AppColors.primaryColor,
            1.5,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 6, right: 12),
            child: Text(donVi, style: AppTextStyles.captionSm),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    ],
  );
}
