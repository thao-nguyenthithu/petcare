import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _dinhDang = NumberFormat.decimalPattern('vi');

// Định dạng số tiền
String dinhDangTien(int soTien) => _dinhDang.format(soTien);

int? docSoTien(String input) {
  final soThuan = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (soThuan.isEmpty) return null;
  return int.tryParse(soThuan);
}

class DinhDangTienFormatter extends TextInputFormatter {
  static const _soChuSoToiDa = 9;

  const DinhDangTienFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final soThuan = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (soThuan.isEmpty) return const TextEditingValue();
    if (soThuan.length > _soChuSoToiDa) return oldValue;
    final so = int.tryParse(soThuan);
    if (so == null) return oldValue;
    final text = dinhDangTien(so);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
