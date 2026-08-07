import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

const int soAnhMoiBeToiDa = 1;
const int soAnhMoiBeToiThieu = 1;

enum GiaiDoanGrooming { dungHen, quaDuKien }

extension GiaiDoanGroomingMa on GiaiDoanGrooming {
  String get ma => switch (this) {
    GiaiDoanGrooming.dungHen => 'dung-hen',
    GiaiDoanGrooming.quaDuKien => 'qua-du-kien',
  };
}

class GroomingSession {
  const GroomingSession({
    required this.don,
    required this.giaiDoan,
    required this.gioBatDau,
    required this.conLaiDuKien,
    required this.soAnhDaGui,
    this.nhacDonKeTiep,
  });

  final SitterOrderDetail don;
  final GiaiDoanGrooming giaiDoan;

  final String gioBatDau;
  final String conLaiDuKien;

  final int soAnhDaGui;

  final String? nhacDonKeTiep;

  bool get quaDuKien => giaiDoan == GiaiDoanGrooming.quaDuKien;
  String get gioDuKienXong => don.grooming?.gioDuKienXong ?? '';

  List<GoiGroomingCuaBe> get goiTungBe => don.grooming?.goiTungBe ?? const [];

  int get tongHangMuc =>
      goiTungBe.fold(0, (tong, goi) => tong + goi.hangMuc.length);

  GroomingSession copyWith({
    SitterOrderDetail? don,
    GiaiDoanGrooming? giaiDoan,
    String? gioBatDau,
    String? conLaiDuKien,
    int? soAnhDaGui,
    String? nhacDonKeTiep,
  }) => GroomingSession(
    don: don ?? this.don,
    giaiDoan: giaiDoan ?? this.giaiDoan,
    gioBatDau: gioBatDau ?? this.gioBatDau,
    conLaiDuKien: conLaiDuKien ?? this.conLaiDuKien,
    soAnhDaGui: soAnhDaGui ?? this.soAnhDaGui,
    nhacDonKeTiep: nhacDonKeTiep ?? this.nhacDonKeTiep,
  );
}
