import 'package:petcare_app/shared/data/sitter_slots.dart';

// Quy tắc ngày giờ đặt lịch
// Cửa sổ đặt trước
const int maxAdvanceDays = 60;
const int minLeadMinutes = 120;
// Bước sinh khung giờ
const int slotStepMinutes = 30;
// Mốc mở nút Xuất phát và số nhà
const int gioMoXuatPhatTruoc = 2;
const int gioMoMacDinh = 7;
const int gioDongMacDinh = 20;

enum LyDoKhungGio {
  daQua,
  chuaDuLeadTime,
  ngoaiGioLamViec,
  daCoDon,
  beDaCoDon,
  khongDuThoiLuong,
}

enum KieuChiem { theoThoiLuong, toiCuoiNgay, tuDauNgay }

const int _phutHetNgay = 24 * 60;

// Một khung giờ bắt đầu trong ngày đã chọn
class KhungGio {
  const KhungGio({required this.gio, required this.phut, this.lyDoChan});

  final int gio;
  final int phut;
  final LyDoKhungGio? lyDoChan;

  bool get chonDuoc => lyDoChan == null;

  String get nhan =>
      '${gio.toString().padLeft(2, '0')}:${phut.toString().padLeft(2, '0')}';

  int get soPhutTrongNgay => gio * 60 + phut;
}

// Sinh khung giờ bước 30 phút trong giờ làm việc
List<KhungGio> sinhKhungGio({
  required DateTime ngay,
  required DateTime bayGio,
  int phutMo = gioMoMacDinh * 60,
  int phutDong = gioDongMacDinh * 60,
  int thoiLuongPhut = 60,
  List<KhoangBanGio> ban = const [],
  List<KhoangBanGio> banCuaBe = const [],
  KieuChiem chiem = KieuChiem.theoThoiLuong,
}) {
  final ds = <KhungGio>[];
  final laHomNay =
      ngay.year == bayGio.year &&
      ngay.month == bayGio.month &&
      ngay.day == bayGio.day;
  for (var phut = phutMo; phut <= phutDong; phut += slotStepMinutes) {
    final batDau = DateTime(ngay.year, ngay.month, ngay.day, 0, phut);
    final (dauChiem, cuoiChiem) = switch (chiem) {
      KieuChiem.theoThoiLuong => (phut, phut + thoiLuongPhut),
      KieuChiem.toiCuoiNgay => (phut, _phutHetNgay),
      KieuChiem.tuDauNgay => (0, phut),
    };
    LyDoKhungGio? ly;
    if (laHomNay && batDau.isBefore(bayGio)) {
      ly = LyDoKhungGio.daQua;
    } else if (batDau.difference(bayGio).inMinutes < minLeadMinutes) {
      ly = LyDoKhungGio.chuaDuLeadTime;
    } else if (phut + thoiLuongPhut > phutDong) {
      ly = LyDoKhungGio.khongDuThoiLuong;
    } else if (banCuaBe.any((b) => b.giaoVoi(dauChiem, cuoiChiem))) {
      ly = LyDoKhungGio.beDaCoDon;
    } else if (ban.any((b) => b.giaoVoi(dauChiem, cuoiChiem))) {
      ly = LyDoKhungGio.daCoDon;
    }
    ds.add(KhungGio(gio: phut ~/ 60, phut: phut % 60, lyDoChan: ly));
  }
  return ds;
}

bool ngayChonDuoc(DateTime ngay, DateTime homNay, List<DateTime> ngayKin) {
  final moc = DateTime(ngay.year, ngay.month, ngay.day);
  final dau = DateTime(homNay.year, homNay.month, homNay.day);
  if (moc.isBefore(dau)) return false;
  if (moc.difference(dau).inDays > maxAdvanceDays) return false;
  return !ngayKin.any(
    (k) => k.year == moc.year && k.month == moc.month && k.day == moc.day,
  );
}

String gioLech(KhungGio moc, int phutLech) {
  final tong = moc.soPhutTrongNgay + phutLech;
  final gio = (tong ~/ 60) % 24;
  final phut = tong % 60;
  return '${gio.toString().padLeft(2, '0')}:${phut.toString().padLeft(2, '0')}';
}

// Giờ kết thúc suy ra từ giờ bắt đầu và thời lượng gói
String gioKetThuc(KhungGio batDau, int thoiLuongPhut) =>
    gioLech(batDau, thoiLuongPhut);

// Số đêm của một kỳ trông giữ, đếm theo NGÀY chứ không theo giờ
int soDemGiua(DateTime nhan, DateTime tra) => DateTime(
  tra.year,
  tra.month,
  tra.day,
).difference(DateTime(nhan.year, nhan.month, nhan.day)).inDays;

// Phụ phí giữ thêm, so giờ đón về ngày cuối với giờ mang đến ngày đầu
int phutGiuThem(KhungGio mangDen, KhungGio donVe) {
  final lech = donVe.soPhutTrongNgay - mangDen.soPhutTrongNgay;
  return lech < 0 ? 0 : lech;
}

int phiGiuThem(int phutLech, int giaMotDemCaDon) {
  if (phutLech <= 120) return 0;
  if (phutLech <= 480) return giaMotDemCaDon ~/ 2;
  final soDem = (phutLech / (24 * 60)).ceil();
  return giaMotDemCaDon * (soDem < 1 ? 1 : soDem);
}

// Hạn NCC phải nhận đơn
Duration hanNhanDon(Duration conToiGioHen) {
  final gio = conToiGioHen.inMinutes / 60;
  if (gio <= 6) return const Duration(minutes: 30);
  if (gio <= 24) return const Duration(hours: 2);
  if (gio <= 24 * 7) return const Duration(hours: 12);
  return const Duration(hours: 24);
}
