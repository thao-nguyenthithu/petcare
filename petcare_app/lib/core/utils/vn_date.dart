import 'package:petcare_app/core/l10n/generated/app_localizations.dart';

// Tiện ích ngày tháng theo múi giờ Việt Nam
const Duration _lechGioVn = Duration(hours: 7);

// Thời điểm hiện tại theo giờ Việt Nam, không gắn cờ UTC
DateTime nowVn() {
  final vn = DateTime.now().toUtc().add(_lechGioVn);
  return DateTime(
    vn.year,
    vn.month,
    vn.day,
    vn.hour,
    vn.minute,
    vn.second,
    vn.millisecond,
  );
}

DateTime chiNgay(DateTime d) => DateTime(d.year, d.month, d.day);

String ngayJson(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? docNgayJson(String? s) {
  if (s == null || s.isEmpty) return null;
  final d = DateTime.tryParse(s);
  if (d == null) return null;
  if (s.length == 10) return DateTime(d.year, d.month, d.day);
  final vn = d.toUtc().add(_lechGioVn);
  return DateTime(vn.year, vn.month, vn.day);
}

DateTime? docMocVn(String? s) {
  if (s == null || s.isEmpty) return null;
  final d = DateTime.tryParse(s);
  if (d == null) return null;
  final vn = d.toUtc().add(_lechGioVn);
  return DateTime(
    vn.year,
    vn.month,
    vn.day,
    vn.hour,
    vn.minute,
    vn.second,
    vn.millisecond,
  );
}

// Ngày hôm nay theo giờ Việt Nam
DateTime homNayVn() => chiNgay(nowVn());

DateTime dauTuan(DateTime d) =>
    chiNgay(d).subtract(Duration(days: d.weekday - DateTime.monday));

bool cungNgay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

// Số ngày lệch giữa hai ngày
int soNgayLech(DateTime tu, DateTime den) =>
    chiNgay(den).difference(chiNgay(tu)).inDays;

// Nhãn thứ theo SỐ weekday, dùng cho hàng tiêu đề của lịch tháng
String thuNganTheoSo(AppLocalizations l10n, int weekday) => switch (weekday) {
  DateTime.monday => l10n.thuHaiNgan,
  DateTime.tuesday => l10n.thuBaNgan,
  DateTime.wednesday => l10n.thuTuNgan,
  DateTime.thursday => l10n.thuNamNgan,
  DateTime.friday => l10n.thuSauNgan,
  DateTime.saturday => l10n.thuBayNgan,
  _ => l10n.chuNhatNgan,
};

String thuDaiTheoSo(AppLocalizations l10n, int weekday) => switch (weekday) {
  DateTime.monday => l10n.thuHaiDai,
  DateTime.tuesday => l10n.thuBaDai,
  DateTime.wednesday => l10n.thuTuDai,
  DateTime.thursday => l10n.thuNamDai,
  DateTime.friday => l10n.thuSauDai,
  DateTime.saturday => l10n.thuBayDai,
  _ => l10n.chuNhatDai,
};

String thuNgan(AppLocalizations l10n, DateTime d) => switch (d.weekday) {
  DateTime.monday => l10n.thuHaiNgan,
  DateTime.tuesday => l10n.thuBaNgan,
  DateTime.wednesday => l10n.thuTuNgan,
  DateTime.thursday => l10n.thuNamNgan,
  DateTime.friday => l10n.thuSauNgan,
  DateTime.saturday => l10n.thuBayNgan,
  _ => l10n.chuNhatNgan,
};

// Nhãn thứ đầy đủ
String thuDai(AppLocalizations l10n, DateTime d) => switch (d.weekday) {
  DateTime.monday => l10n.thuHaiDai,
  DateTime.tuesday => l10n.thuBaDai,
  DateTime.wednesday => l10n.thuTuDai,
  DateTime.thursday => l10n.thuNamDai,
  DateTime.friday => l10n.thuSauDai,
  DateTime.saturday => l10n.thuBayDai,
  _ => l10n.chuNhatDai,
};

String ngayThang(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String ngayIso(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String moTaCacThu(
  AppLocalizations l10n,
  Set<int> thu, {
  required String khiRong,
}) {
  if (thu.length == 7) return l10n.caTuan;
  if (thu.isEmpty) return khiRong;
  final sapXep = thu.toList()..sort();
  final homNay = homNayVn();
  DateTime ngayCoThu(int t) => homNay.add(Duration(days: t - homNay.weekday));
  final lienMach = sapXep.last - sapXep.first == sapXep.length - 1;
  if (lienMach && sapXep.length > 2) {
    return '${thuDai(l10n, ngayCoThu(sapXep.first))} - '
        '${thuDai(l10n, ngayCoThu(sapXep.last))}';
  }
  return sapXep.map((t) => thuNgan(l10n, ngayCoThu(t))).join(', ');
}

// Mô tả một khoảng thời gian tính bằng phút
String moTaGioPhut(AppLocalizations l10n, int phut) {
  final gio = phut ~/ 60;
  final le = phut % 60;
  if (gio == 0) return l10n.nPhut('$le');
  if (le == 0) return l10n.soGio('$gio');
  return l10n.soGioSoPhut('$gio', '$le');
}

// Đồng hồ đếm ngược: 11:58:24
String dongHoDem(Duration con) {
  final s = con.isNegative ? Duration.zero : con;
  final gio = s.inHours.toString().padLeft(2, '0');
  final phut = (s.inMinutes % 60).toString().padLeft(2, '0');
  final giay = (s.inSeconds % 60).toString().padLeft(2, '0');
  return '$gio:$phut:$giay';
}

// Đếm ngược ngắn cho khoảng dưới một giờ: 05:59
String dongHoPhutGiay(Duration con) {
  final s = con.isNegative ? Duration.zero : con;
  final phut = s.inMinutes.toString().padLeft(2, '0');
  final giay = (s.inSeconds % 60).toString().padLeft(2, '0');
  return '$phut:$giay';
}

String gioPhut(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String nhanThoiDiemNgan(AppLocalizations l10n, DateTime d) =>
    '${cungNgay(d, homNayVn()) ? l10n.homNay : ngayThang(d)} · ${gioPhut(d)}';

String nhanThoiDiemTin(AppLocalizations l10n, DateTime d) {
  final homNay = homNayVn();
  if (cungNgay(d, homNay)) return gioPhut(d);
  if (cungNgay(d, homNay.subtract(const Duration(days: 1)))) return l10n.homQua;
  return homNay.difference(d).inDays < 7 ? thuDai(l10n, d) : ngayThangNam(d);
}

// 23/07/2026
String ngayThangNam(DateTime d) => '${ngayThang(d)}/${d.year}';

// Thứ Tư, 23/07/2026
String nhanNgayCoNam(AppLocalizations l10n, DateTime d) =>
    '${thuDai(l10n, d)}, ${ngayThangNam(d)}';

// Tháng 7, 2026
String nhanThangNam(AppLocalizations l10n, DateTime d) =>
    l10n.thangNam(d.month.toString(), d.year.toString());

// Hôm nay, Thứ Sáu 24/07
String nhanNgayDayDu(AppLocalizations l10n, DateTime d) {
  final thu = thuDai(l10n, d);
  final ngay = ngayThang(d);
  return cungNgay(d, homNayVn())
      ? l10n.homNayNgay(thu, ngay)
      : l10n.ngayDayDu(thu, ngay);
}
