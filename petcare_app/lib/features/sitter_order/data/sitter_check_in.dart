import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

const int phutChoDungCu = 10;
const int soAnhThieuDungCuToiThieu = 1;
const int soAnhThieuDungCuToiDa = 3;

enum TrangThaiCheckIn { binhThuong, daBaoThieu, hetHanDungCu }

extension TrangThaiCheckInMa on TrangThaiCheckIn {
  String get ma => switch (this) {
    TrangThaiCheckIn.binhThuong => 'binh-thuong',
    TrangThaiCheckIn.daBaoThieu => 'da-bao-thieu',
    TrangThaiCheckIn.hetHanDungCu => 'het-han-dung-cu',
  };
}

typedef CheckInArgs = ({
  SitterOrderDetail don,
  TrangThaiCheckIn trangThai,
  String? gioBaoThieu,
  String? conLai,
});
