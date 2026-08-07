import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';

enum LoaiKy { ngay, thang, nam, tatCa }

class KyThongKe {
  const KyThongKe(this.loai, [this.moc]);

  final LoaiKy loai;
  final DateTime? moc;

  DateTime get mocThuc => moc ?? homNayVn();

  bool chua(DateTime ngay) {
    final m = mocThuc;
    return switch (loai) {
      LoaiKy.ngay => cungNgay(ngay, m),
      LoaiKy.thang => ngay.year == m.year && ngay.month == m.month,
      LoaiKy.nam => ngay.year == m.year,
      LoaiKy.tatCa => true,
    };
  }

  bool giongVoi(KyThongKe khac) => loai == khac.loai && chua(khac.mocThuc);

  String nhanTomTat(AppLocalizations l10n) {
    final m = mocThuc;
    return switch (loai) {
      LoaiKy.ngay => ngayThangNam(m),
      LoaiKy.thang => l10n.thangGachNam('${m.month}', '${m.year}'),
      LoaiKy.nam => l10n.namSo('${m.year}'),
      LoaiKy.tatCa => l10n.tatCaThoiGian,
    };
  }

  String nhanNhanh(AppLocalizations l10n) {
    if (moc != null) return nhanTomTat(l10n);
    return switch (loai) {
      LoaiKy.ngay => l10n.homNay,
      LoaiKy.thang => l10n.thangNay,
      LoaiKy.nam => l10n.namNay,
      LoaiKy.tatCa => l10n.tatCaThoiGian,
    };
  }
}

const List<KyThongKe> kyNhanh = [
  KyThongKe(LoaiKy.ngay),
  KyThongKe(LoaiKy.thang),
  KyThongKe(LoaiKy.nam),
  KyThongKe(LoaiKy.tatCa),
];

class BoLocDon {
  const BoLocDon({
    this.dichVu = const {},
    this.ky = const KyThongKe(LoaiKy.thang),
  });

  final Set<LoaiDichVu> dichVu;
  final KyThongKe ky;

  BoLocDon copyWith({Set<LoaiDichVu>? dichVu, KyThongKe? ky}) =>
      BoLocDon(dichVu: dichVu ?? this.dichVu, ky: ky ?? this.ky);

  // Lệch khỏi mặc định của màn thì nút lọc sáng lên
  bool lechVoi(BoLocDon goc) =>
      !ky.giongVoi(goc.ky) ||
      dichVu.length != goc.dichVu.length ||
      !dichVu.containsAll(goc.dichVu);

  bool nhan(SitterBooking don) =>
      (dichVu.isEmpty || dichVu.contains(don.dichVu)) && ky.chua(don.batDau);
}
