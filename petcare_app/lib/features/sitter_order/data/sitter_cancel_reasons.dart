import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';

const List<String> maLyDoTuChoiDon = [
  'trungLich',
  'quaXa',
  'khongNhanGiongNay',
  'banDotXuat',
  'khac',
];

// Huỷ đơn đã nhận nhưng chưa xuất phát
const List<String> maLyDoHuyDonNcc = [
  'banViecDotXuat',
  'trungLichDonKhac',
  'sucKhoeKhongTot',
  'quaXaKhongToiKip',
  'khac',
];

const List<String> maLyDoKhongTheTiepNhan = [
  'taiNanSuCo',
  'xeHongGiuaDuong',
  'sucKhoeKhongTot',
  'khac',
];

const String maLyDoKhacNcc = 'khac';

String nhanLyDoNcc(BuildContext context, String ma) {
  final l10n = context.l10n;
  return switch (ma) {
    'trungLich' => l10n.lyDoTrungLich,
    'quaXa' => l10n.lyDoQuaXa,
    'khongNhanGiongNay' => l10n.lyDoKhongNhanGiongNay,
    'banDotXuat' => l10n.lyDoBanDotXuat,
    'banViecDotXuat' => l10n.lyDoBanViecDotXuat,
    'trungLichDonKhac' => l10n.lyDoTrungLichDonKhac,
    'sucKhoeKhongTot' => l10n.lyDoSucKhoeKhongTot,
    'quaXaKhongToiKip' => l10n.lyDoQuaXaKhongToiKip,
    'taiNanSuCo' => l10n.lyDoTaiNanSuCo,
    'xeHongGiuaDuong' => l10n.lyDoXeHongGiuaDuong,
    _ => l10n.lyDoKhac,
  };
}
