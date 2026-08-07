import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

// Số ảnh mỗi bé ở một đầu buổi grooming (bộ luật mục 8)
const int soAnhMoiBeToiDa = 1;
const int soAnhMoiBeToiThieu = 1;

// Chia ở mốc dự kiến xong, quá mốc không phải lỗi
enum GiaiDoanGrooming { dungHen, quaDuKien }

extension GiaiDoanGroomingMa on GiaiDoanGrooming {
  // Mã trên đường dẫn, cùng lối viết với mã giai đoạn phiên dắt
  String get ma => switch (this) {
    GiaiDoanGrooming.dungHen => 'dung-hen',
    GiaiDoanGrooming.quaDuKien => 'qua-du-kien',
  };
}

// Buổi tắm và cắt tỉa đang chạy, đo bằng hạng mục và ảnh
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

  // Giờ đã bấm bắt đầu, ví dụ "08:34"
  final String gioBatDau;

  // Quá mốc dự kiến thì đây là phần đã vượt
  final String conLaiDuKien;

  final int soAnhDaGui;

  // Chỉ có khi đã quá mốc dự kiến
  final String? nhacDonKeTiep;

  bool get quaDuKien => giaiDoan == GiaiDoanGrooming.quaDuKien;

  // Lấy thẳng từ đơn để hai màn không nói khác nhau
  String get gioDuKienXong => don.grooming?.gioDuKienXong ?? '';

  List<GoiGroomingCuaBe> get goiTungBe => don.grooming?.goiTungBe ?? const [];

  // Tổng hạng mục cả đơn, dùng cho bộ đếm màn kết thúc
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
