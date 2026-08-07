import 'dart:typed_data';

import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

// Trần ảnh mỗi bé ở một đầu bàn giao (bộ luật mục 8)
const int soAnhBeMoiDauToiDa = 2;
const int soAnhBeMoiDauToiThieu = 1;

// Trần ảnh đồ dùng gửi kèm, tính chung cả đơn (bộ luật mục 8)
const int soAnhDoDungToiDa = 5;

// Trần ảnh mỗi lần cập nhật hằng ngày
const int soAnhCapNhatToiDa = 5;

// Hai đầu kỳ giữ chung màn camera, khác câu hướng dẫn
enum LoaiBanGiao { nhanBe, traBe }

extension LoaiBanGiaoMa on LoaiBanGiao {
  String get ma => switch (this) {
    LoaiBanGiao.nhanBe => 'nhan-be',
    LoaiBanGiao.traBe => 'tra-be',
  };
}

// TODO: nối GET /boarding/pet-conditions rồi xoá bảng song ngữ này
const tenTinhTrangBeTrongGiu = <String, (String, String)>{
  'anNguTot': ('Ăn ngủ tốt', 'Eating and sleeping well'),
  'choiNhieu': ('Chơi nhiều', 'Very playful'),
  'boAnMotBua': ('Bỏ ăn 1 bữa', 'Skipped a meal'),
  'nhoNha': ('Nhớ nhà', 'Homesick'),
  'veSinhBinhThuong': ('Đi vệ sinh bình thường', 'Normal bathroom habits'),
  'nonHoacTieuChay': ('Có nôn hoặc tiêu chảy', 'Vomiting or diarrhoea'),
  'uongThuocDu': ('Đã uống thuốc đủ', 'Took all medication'),
};

// Bản kê hằng ngày có thêm nết chơi
const maTinhTrangHangNgay = [
  'anNguTot',
  'choiNhieu',
  'boAnMotBua',
  'nhoNha',
  'veSinhBinhThuong',
  'nonHoacTieuChay',
];

// Bản kê lúc trả bé có thêm mục uống thuốc
const maTinhTrangCaKy = [
  'anNguTot',
  'boAnMotBua',
  'veSinhBinhThuong',
  'nhoNha',
  'nonHoacTieuChay',
  'uongThuocDu',
];

// Lô ảnh một lượt bàn giao, tách nhóm bé và nhóm đồ dùng
typedef AnhBanGiao = ({
  BoardingSession phien,
  LoaiBanGiao loai,
  List<Uint8List> anhBe,
  List<Uint8List> anhDoDung,
});

// Kỳ trông giữ đang chạy, tính theo ngày nên không đếm ngược
class BoardingSession {
  const BoardingSession({
    required this.don,
    required this.soAnhDaGui,
    this.moTraBe = false,
    this.gioChupAnh,
  });

  final SitterOrderDetail don;

  // Tổng ảnh đã gửi cho chủ nuôi từ đầu kỳ
  final int soAnhDaGui;

  // Tới ngày trả bé thì nút Trả bé mới mở
  final bool moTraBe;

  // Giờ chụp lô ảnh đang chờ gửi
  final String? gioChupAnh;

  ThongTinTrongGiu? get ky => don.trongGiu;

  int get soDem => ky?.soDem ?? 0;
  int get demHienTai => ky?.demHienTai ?? 0;
  String get ngayTraNgan => ky?.ngayTraNgan ?? '';

  // Trần ảnh bé của đơn, dùng cho bộ đếm trên màn
  int get tranAnhBe => don.pets.length * soAnhBeMoiDauToiDa;

  BoardingSession copyWith({
    SitterOrderDetail? don,
    int? soAnhDaGui,
    bool? moTraBe,
    String? gioChupAnh,
  }) => BoardingSession(
    don: don ?? this.don,
    soAnhDaGui: soAnhDaGui ?? this.soAnhDaGui,
    moTraBe: moTraBe ?? this.moTraBe,
    gioChupAnh: gioChupAnh ?? this.gioChupAnh,
  );
}
