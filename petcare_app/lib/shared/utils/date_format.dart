import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

// Định dạng ngày kiểu Việt Nam: dd/mm/yyyy
String dinhDangNgay(DateTime ngay) =>
    '${ngay.day.toString().padLeft(2, '0')}/'
    '${ngay.month.toString().padLeft(2, '0')}/${ngay.year}';

String nhanThuNgan(BuildContext context, int weekday) {
  final l10n = context.l10n;
  return switch (weekday) {
    DateTime.monday => l10n.thuHaiNgan,
    DateTime.tuesday => l10n.thuBaNgan,
    DateTime.wednesday => l10n.thuTuNgan,
    DateTime.thursday => l10n.thuNamNgan,
    DateTime.friday => l10n.thuSauNgan,
    DateTime.saturday => l10n.thuBayNgan,
    _ => l10n.chuNhatNgan,
  };
}
