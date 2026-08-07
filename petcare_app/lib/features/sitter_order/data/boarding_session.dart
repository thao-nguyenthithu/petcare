import 'dart:typed_data';

import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

const int soAnhBeMoiDauToiDa = 2;
const int soAnhBeMoiDauToiThieu = 1;
const int soAnhDoDungToiDa = 5;
const int soAnhCapNhatToiDa = 5;

enum LoaiBanGiao { nhanBe, traBe }

extension LoaiBanGiaoMa on LoaiBanGiao {
  String get ma => switch (this) {
    LoaiBanGiao.nhanBe => 'nhan-be',
    LoaiBanGiao.traBe => 'tra-be',
  };
}

const tenTinhTrangBeTrongGiu = <String, (String, String)>{
  'anNguTot': ('Ăn ngủ tốt', 'Eating and sleeping well'),
  'choiNhieu': ('Chơi nhiều', 'Very playful'),
  'boAnMotBua': ('Bỏ ăn 1 bữa', 'Skipped a meal'),
  'nhoNha': ('Nhớ nhà', 'Homesick'),
  'veSinhBinhThuong': ('Đi vệ sinh bình thường', 'Normal bathroom habits'),
  'nonHoacTieuChay': ('Có nôn hoặc tiêu chảy', 'Vomiting or diarrhoea'),
  'uongThuocDu': ('Đã uống thuốc đủ', 'Took all medication'),
};

const maTinhTrangHangNgay = [
  'anNguTot',
  'choiNhieu',
  'boAnMotBua',
  'nhoNha',
  'veSinhBinhThuong',
  'nonHoacTieuChay',
];

const maTinhTrangCaKy = [
  'anNguTot',
  'boAnMotBua',
  'veSinhBinhThuong',
  'nhoNha',
  'nonHoacTieuChay',
  'uongThuocDu',
];

typedef AnhBanGiao = ({
  BoardingSession phien,
  LoaiBanGiao loai,
  List<Uint8List> anhBe,
  List<Uint8List> anhDoDung,
});

class BoardingSession {
  const BoardingSession({
    required this.don,
    required this.soAnhDaGui,
    this.moTraBe = false,
    this.gioChupAnh,
  });

  final SitterOrderDetail don;

  final int soAnhDaGui;

  final bool moTraBe;

  final String? gioChupAnh;

  ThongTinTrongGiu? get ky => don.trongGiu;

  int get soDem => ky?.soDem ?? 0;
  int get demHienTai => ky?.demHienTai ?? 0;
  String get ngayTraNgan => ky?.ngayTraNgan ?? '';

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
