import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';

// Số phút chờ chủ nuôi mang đủ dụng cụ ra (bộ luật mục 5)
const int phutChoDungCu = 10;

// Ảnh kèm lời báo thiếu dụng cụ, phải thấy được bé (bộ luật mục 8)
const int soAnhThieuDungCuToiThieu = 1;
const int soAnhThieuDungCuToiDa = 3;

// Ba tình huống màn nhận bé, khác nhau dòng nhắc và nút phụ
enum TrangThaiCheckIn { binhThuong, daBaoThieu, hetHanDungCu }

extension TrangThaiCheckInMa on TrangThaiCheckIn {
  // Mã trên đường dẫn, cùng lối viết với mã tình trạng đơn
  String get ma => switch (this) {
    TrangThaiCheckIn.binhThuong => 'binh-thuong',
    TrangThaiCheckIn.daBaoThieu => 'da-bao-thieu',
    TrangThaiCheckIn.hetHanDungCu => 'het-han-dung-cu',
  };
}

// Màn nhận bé cần đơn và tình huống đang xảy ra
typedef CheckInArgs = ({
  SitterOrderDetail don,
  TrangThaiCheckIn trangThai,
  // Giờ bấm báo thiếu dụng cụ và thời gian còn lại của cửa sổ chờ
  String? gioBaoThieu,
  String? conLai,
});
