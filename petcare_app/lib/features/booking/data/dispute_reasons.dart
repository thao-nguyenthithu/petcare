import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

// Trùng LY_DO_SU_CO_CHU_NUOI của máy chủ, chip giữ MÃ chứ không giữ câu
const List<String> maSuCoChuNuoi = [
  'beBiThuongOm',
  'khongDungDichVu',
  'treGioBoDo',
  'thieuBangChung',
  'khac',
];

const String maSuCoKhac = 'khac';

String nhanSuCoChuNuoi(BuildContext context, String? ma) {
  final l10n = context.l10n;
  return switch (ma) {
    'beBiThuongOm' => l10n.scBeBiThuongOm,
    'khongDungDichVu' => l10n.scKhongDungDichVu,
    'treGioBoDo' => l10n.scTreGioBoDo,
    'thieuBangChung' => l10n.scThieuBangChung,
    _ => l10n.scKhac,
  };
}
