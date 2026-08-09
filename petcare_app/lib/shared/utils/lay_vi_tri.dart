import 'package:geolocator/geolocator.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';

enum KetQuaQuyenViTri { daCap, tuChoi, tuChoiVinhVien, dichVuTat }

enum LoiViTri { dichVuTat, chuaCapQuyen, biChan, khongDoDuoc }

// Hỏi hệ thống cấp quyền vị trí
Future<KetQuaQuyenViTri> xinQuyenViTri() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return KetQuaQuyenViTri.dichVuTat;
  }
  var quyen = await Geolocator.checkPermission();
  if (quyen == LocationPermission.denied) {
    quyen = await Geolocator.requestPermission();
  }
  return switch (quyen) {
    LocationPermission.always ||
    LocationPermission.whileInUse => KetQuaQuyenViTri.daCap,
    LocationPermission.deniedForever => KetQuaQuyenViTri.tuChoiVinhVien,
    _ => KetQuaQuyenViTri.tuChoi,
  };
}

// Xin quyền rồi mới đo, trả lý do hỏng để màn nói đúng việc người dùng phải làm
Future<(Position?, LoiViTri?)> layViTriHienTai({
  Duration hanCho = const Duration(seconds: 15),
}) async {
  final quyen = await xinQuyenViTri();
  switch (quyen) {
    case KetQuaQuyenViTri.dichVuTat:
      return (null, LoiViTri.dichVuTat);
    case KetQuaQuyenViTri.tuChoi:
      return (null, LoiViTri.chuaCapQuyen);
    case KetQuaQuyenViTri.tuChoiVinhVien:
      return (null, LoiViTri.biChan);
    case KetQuaQuyenViTri.daCap:
      break;
  }
  try {
    final viTri = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: hanCho,
      ),
    );
    return (viTri, null);
  } on Exception {
    // Không mượn vị trí cũ: geofence 200 m là bằng chứng, đo hụt phải nói hụt
    return (null, LoiViTri.khongDoDuoc);
  }
}

String chuLoiViTri(AppLocalizations l10n, LoiViTri loi) => switch (loi) {
  LoiViTri.dichVuTat => l10n.loiDinhViDangTat,
  LoiViTri.chuaCapQuyen => l10n.loiChuaCapQuyenViTri,
  LoiViTri.biChan => l10n.loiQuyenViTriBiChan,
  LoiViTri.khongDoDuoc => l10n.loiKhongLayDuocViTri,
};

// Hai nhánh này người dùng phải tự gạt trong trang cài đặt mới qua được
bool canMoCaiDat(LoiViTri loi) =>
    loi == LoiViTri.dichVuTat || loi == LoiViTri.biChan;

Future<void> moCaiDatViTri(LoiViTri loi) => loi == LoiViTri.dichVuTat
    ? Geolocator.openLocationSettings()
    : Geolocator.openAppSettings();
