import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

const int soAnhKetThucToiDa = 3;
const int soAnhKetThucToiThieu = 1;

enum GiaiDoanPhien { dangDat, phaiQuayVe }

extension GiaiDoanPhienMa on GiaiDoanPhien {
  String get ma => switch (this) {
    GiaiDoanPhien.dangDat => 'dang-dat',
    GiaiDoanPhien.phaiQuayVe => 'phai-quay-ve',
  };
}

// Một phiên dắt đang chạy
class WalkingSession {
  const WalkingSession({
    required this.don,
    required this.giaiDoan,
    required this.kmDaDi,
    required this.kmLoTrinh,
    required this.conLai,
    required this.phutDaDat,
    required this.soAnhDaGui,
    this.bookingId,
    this.metConToiDiemTra,
  });

  final String? bookingId;
  final SitterOrderDetail don;
  final GiaiDoanPhien giaiDoan;
  final double kmDaDi;
  final double kmLoTrinh;
  final String conLai;
  final int phutDaDat;
  final int soAnhDaGui;
  final int? metConToiDiemTra;

  bool get duGio => don.duGioKetThuc;

  bool get duGan =>
      don.viTri == null || (metConToiDiemTra ?? metGeofence + 1) <= metGeofence;

  bool get moKetThuc => duGio && duGan;

  bool get phaiQuayVe => giaiDoan == GiaiDoanPhien.phaiQuayVe;

  WalkingSession copyWith({
    SitterOrderDetail? don,
    GiaiDoanPhien? giaiDoan,
    double? kmDaDi,
    double? kmLoTrinh,
    String? conLai,
    int? phutDaDat,
    int? soAnhDaGui,
    String? bookingId,
    int? metConToiDiemTra,
  }) => WalkingSession(
    don: don ?? this.don,
    giaiDoan: giaiDoan ?? this.giaiDoan,
    kmDaDi: kmDaDi ?? this.kmDaDi,
    kmLoTrinh: kmLoTrinh ?? this.kmLoTrinh,
    conLai: conLai ?? this.conLai,
    phutDaDat: phutDaDat ?? this.phutDaDat,
    soAnhDaGui: soAnhDaGui ?? this.soAnhDaGui,
    bookingId: bookingId ?? this.bookingId,
    metConToiDiemTra: metConToiDiemTra ?? this.metConToiDiemTra,
  );
}
