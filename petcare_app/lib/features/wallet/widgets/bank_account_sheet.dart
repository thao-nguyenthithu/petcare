import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

// Ép in hoa ngay khi gõ, đổi lúc lưu là lệch với chữ đã nhập
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue cu,
    TextEditingValue moi,
  ) => TextEditingValue(text: moi.text.toUpperCase(), selection: moi.selection);
}

// Ba ô nhập của tài khoản nhận tiền
typedef ThongTinNganHang = ({
  String tenNganHang,
  String soTaiKhoan,
  String tenChuTaiKhoan,
});

Future<ThongTinNganHang?> showBankAccountSheet(
  BuildContext context, {
  TaiKhoanNganHang? dangCo,
}) {
  return showModalBottomSheet<ThongTinNganHang>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _BankAccountSheet(dangCo: dangCo),
  );
}

class _BankAccountSheet extends StatefulWidget {
  const _BankAccountSheet({this.dangCo});

  final TaiKhoanNganHang? dangCo;

  @override
  State<_BankAccountSheet> createState() => _BankAccountSheetState();
}

class _BankAccountSheetState extends State<_BankAccountSheet> {
  late final _nganHang = TextEditingController(
    text: widget.dangCo?.tenNganHang ?? '',
  );
  late final _chuTaiKhoan = TextEditingController(
    text: widget.dangCo?.tenChuTaiKhoan ?? '',
  );
  final _soTaiKhoan = TextEditingController();

  String? _loi;

  @override
  void dispose() {
    _nganHang.dispose();
    _soTaiKhoan.dispose();
    _chuTaiKhoan.dispose();
    super.dispose();
  }

  void _luu() {
    final l10n = context.l10n;
    final ten = _nganHang.text.trim();
    final so = _soTaiKhoan.text.trim();
    final chu = _chuTaiKhoan.text.trim();
    if (ten.isEmpty || so.isEmpty || chu.isEmpty) {
      setState(() => _loi = l10n.loiThieuThongTinNganHang);
      return;
    }
    if (!RegExp(r'^\d{6,19}$').hasMatch(so)) {
      setState(() => _loi = l10n.loiSoTaiKhoan);
      return;
    }
    Navigator.pop(context, (
      tenNganHang: ten,
      soTaiKhoan: so,
      tenChuTaiKhoan: chu.toUpperCase(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: AppSpacing.screenPadding,
        bottom:
            MediaQuery.viewInsetsOf(context).bottom + AppSpacing.screenEdgeGap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.taiKhoanNhanTien, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.stackGap),
          AppTextField(
            label: l10n.tenNganHang,
            hint: l10n.hintTenNganHang,
            controller: _nganHang,
            isRequired: true,
          ),
          const SizedBox(height: AppSpacing.itemGap),
          AppTextField(
            label: l10n.soTaiKhoanNhanTien,
            hint: l10n.hintSoTaiKhoan,
            controller: _soTaiKhoan,
            isRequired: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.itemGap),
          AppTextField(
            label: l10n.tenChuTaiKhoan,
            hint: l10n.hintTenChuTaiKhoan,
            controller: _chuTaiKhoan,
            isRequired: true,
            // Tên chủ tài khoản luôn in hoa không dấu
            inputFormatters: [UpperCaseTextFormatter()],
          ),
          if (_loi != null) ...[
            const SizedBox(height: AppSpacing.textGap),
            Text(
              _loi!,
              style: AppTextStyles.captionSm.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.stackGap),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _luu, child: Text(l10n.luu)),
          ),
        ],
      ),
    );
  }
}
