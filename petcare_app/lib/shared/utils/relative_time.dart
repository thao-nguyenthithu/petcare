import 'package:petcare_app/core/l10n/generated/app_localizations.dart';

String thoiGianTuongDoi(AppLocalizations l10n, int soPhutTruoc) {
  if (soPhutTruoc < 60) return l10n.truocSoPhut('$soPhutTruoc');
  final soGio = soPhutTruoc ~/ 60;
  if (soGio < 24) return l10n.truocSoGio('$soGio');
  return l10n.truocSoNgay('${soGio ~/ 24}');
}

String khoangChinhXac(AppLocalizations l10n, int soPhut) {
  final phut = soPhut < 0 ? 0 : soPhut;
  if (phut < 60) return l10n.nPhutNhan('$phut');
  final gio = phut ~/ 60;
  final le = phut % 60;
  return le == 0 ? l10n.nGioNhan('$gio') : l10n.soGioSoPhut('$gio', '$le');
}

// Khoảng thời gian làm tròn
String khoangTho(AppLocalizations l10n, int soPhut) {
  final phut = soPhut < 0 ? 0 : soPhut;
  if (phut < 60) return l10n.nPhutNhan('$phut');
  final gio = phut ~/ 60;
  return gio < 24 ? l10n.nGioNhan('$gio') : l10n.nNgayNhan('${gio ~/ 24}');
}

// Đồng hồ đếm ngược
String dongHoConLai(AppLocalizations l10n, int soPhut) {
  final phut = soPhut < 0 ? 0 : soPhut;
  if (phut < 60) return l10n.nPhutNhan('$phut');
  final gio = phut ~/ 60;
  if (gio < 24) {
    final le = phut % 60;
    return le == 0 ? l10n.nGioNhan('$gio') : l10n.soGioSoPhut('$gio', '$le');
  }
  final ngay = gio ~/ 24;
  final gioLe = gio % 24;
  return gioLe == 0
      ? l10n.nNgayNhan('$ngay')
      : l10n.soNgaySoGio('$ngay', '$gioLe');
}

// Còn bao lâu tới giờ hẹn, dùng cho chip đơn sắp tới
String nhanToiTrong(AppLocalizations l10n, int soPhutConLai) =>
    l10n.toiTrongKhoang(dongHoConLai(l10n, soPhutConLai));
