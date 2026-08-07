import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_parts.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

export 'package:petcare_app/features/sitter_order/data/sitter_order_parts.dart';

// Nút Bắt đầu mở trước giờ hẹn bấy nhiêu phút
const int phutMoNutBatDau = 15;

// Trần ảnh chứng minh khi báo không thể tiếp nhận (bộ luật mục 6)
const int soAnhChungMinhToiDa = 3;

// Bán kính geofence quanh điểm đón, dùng cho cả hai đầu phiên
const int metGeofence = 200;

// Số phút ân hạn sau giờ hẹn nhận bé của kỳ trông giữ
const int phutAnHanNhanBe = 15;

// Tình trạng đơn nhìn từ phía người chăm
enum TinhTrangDonNcc {
  choXacNhan,
  daNhanDon,
  dangToi,
  daBaoMuon,
  // Chỉ kỳ trông giữ: quá hẹn mà chưa thấy bé
  quaHenNhanBe,
  daToiDiemDon,
  dangDat,
  choChuNuoiXacNhan,
  // Chỉ kỳ trông giữ: trả tận tay nên đơn chốt ngay
  hoanThanh,
  // Tách rõ từng kết cục huỷ, gộp lại là sai người sai tiền
  hetHanNhan,
  banDaHuy,
  khachHuy,
  khachVangMat,
  // Đơn chờ tự chết vì đã nhận đơn khác trùng giờ
  tuHuyTrungLich,
  // Quản trị huỷ, không tính vào tỷ lệ huỷ (bộ luật mục 4)
  huyBoiQuanTri,
  // Mã app chưa biết, không suy đoán và không mở nút nào
  khongRo,
}

extension TinhTrangDonNccMa on TinhTrangDonNcc {
  // Mã trên đường dẫn, cùng lối viết với các enum khác
  String get ma => switch (this) {
    TinhTrangDonNcc.choXacNhan => 'cho-xac-nhan',
    TinhTrangDonNcc.daNhanDon => 'da-nhan',
    TinhTrangDonNcc.dangToi => 'dang-toi',
    TinhTrangDonNcc.daBaoMuon => 'da-bao-muon',
    TinhTrangDonNcc.quaHenNhanBe => 'qua-hen',
    TinhTrangDonNcc.daToiDiemDon => 'da-toi',
    TinhTrangDonNcc.dangDat => 'dang-dat',
    TinhTrangDonNcc.choChuNuoiXacNhan => 'cho-chot',
    TinhTrangDonNcc.hoanThanh => 'hoan-thanh',
    TinhTrangDonNcc.hetHanNhan => 'het-han',
    TinhTrangDonNcc.banDaHuy => 'ban-huy',
    TinhTrangDonNcc.khachHuy => 'khach-huy',
    TinhTrangDonNcc.khachVangMat => 'khach-vang-mat',
    TinhTrangDonNcc.tuHuyTrungLich => 'tu-huy-trung-lich',
    TinhTrangDonNcc.huyBoiQuanTri => 'quan-tri-huy',
    TinhTrangDonNcc.khongRo => 'khong-ro',
  };
}

// Mọi số đã chốt, màn chỉ tính thêm phí nền tảng
class SitterOrderDetail {
  const SitterOrderDetail({
    required this.bookingId,
    required this.maDon,
    required this.tinhTrang,
    required this.loai,
    required this.tenDichVu,
    required this.pets,
    required this.tenChuNuoi,
    required this.soDonDaDat,
    required this.gioHen,
    required this.ngayNganHen,
    required this.moTaThoiGian,
    required this.kmToiDiemDon,
    required this.khuVucDiemDon,
    required this.ghiChu,
    required this.dongTien,
    required this.tongTien,
    this.phanTramPhiNenTang = phiNenTangMacDinh,
    this.phanTramPhiHuy = phiHuyMuonMacDinh,
    this.gioGiuTien = gioGiuTienMacDinh,
    this.tranTyLeHuy = tranTyLeHuyMacDinh,
    this.avatarChuNuoi,
    this.diaChiDayDu,
    this.viTri,
    this.mocPhu,
    this.gioMoChiDuong,
    this.ngayMoChiDuong,
    this.gioMoXuatPhat,
    this.gioMoBatDau,
    this.phutBaoMuon,
    this.gioDuKienToi,
    this.gioDaBaoMuon,
    this.gioToiNoi,
    this.metCachDiemDon,
    this.gioMoBaoVangMat,
    this.gioBatDauPhien,
    this.gioXacMinhDungCu,
    this.kmDaDi,
    this.phutThucHien,
    this.phutConLai,
    this.gioMoKetThuc,
    this.anhNhatKy = const [],
    this.tongAnhNhatKy = 0,
    this.gioHetHan,
    this.ngayHetHan,
    this.tienHuyBanNhan = 0,
    this.lyDoHuy,
    this.ketQua,
    this.grooming,
    this.trongGiu,
    this.dienBien = const [],
    this.anhTruoc = const [],
    this.tongAnhTruoc = 0,
    this.anhSau = const [],
    this.tongAnhSau = 0,
  });

  // Id đơn trên server, mọi màn dựng đường dẫn từ đây
  final String bookingId;
  final String maDon;
  final TinhTrangDonNcc tinhTrang;
  final ServiceType loai;

  // Tên dịch vụ kèm gói, ví dụ "Dắt đi dạo · 60 phút"
  final String tenDichVu;
  final List<Pet> pets;

  final String tenChuNuoi;
  final String? avatarChuNuoi;

  // Số đơn chủ nuôi đã đặt, để ước mức quen việc
  final int soDonDaDat;

  // "08:00" và "T4 23/07" cho dải số liệu nhanh
  final String gioHen;
  final String ngayNganHen;

  // "Thứ Tư, 23/07 · 08:00 – 09:00" cho mục Thông tin đơn
  final String moTaThoiGian;

  final double kmToiDiemDon;

  // Địa chỉ do server ẩn theo bậc, client không tự che
  final String khuVucDiemDon;
  final String? diaChiDayDu;
  final LatLng? viTri;

  final String ghiChu;

  final List<DongHoaDon> dongTien;

  // Giá đơn chủ nuôi trả, trước khi trừ phí nền tảng
  final int tongTien;

  // Con số vận hành đóng băng theo đơn (bộ luật mục 15)
  final int phanTramPhiNenTang;
  final int phanTramPhiHuy;
  final int gioGiuTien;
  final int tranTyLeHuy;

  // Chữ bên phải dòng trạng thái, mỗi tình trạng một loại mốc
  final String? mocPhu;

  // Còn giá trị là chưa mở chỉ đường, gồm giờ kèm ngày
  final String? gioMoChiDuong;
  final String? ngayMoChiDuong;

  // Còn giá trị là chưa tới giờ mở nút
  final String? gioMoXuatPhat;
  bool get moXuatPhat => gioMoXuatPhat == null;

  // Còn giá trị là chưa tới giờ bấm Bắt đầu
  final String? gioMoBatDau;
  bool get moBatDau => gioMoBatDau == null;

  // Chỉ có khi đã báo đến muộn
  final int? phutBaoMuon;
  final String? gioDuKienToi;
  final String? gioDaBaoMuon;

  // Bằng chứng nếu sau đó phải báo chủ nuôi vắng mặt
  final String? gioToiNoi;
  final int? metCachDiemDon;

  // Chờ đủ ân hạn, kẻo vừa tới đã tố người ta vắng mặt
  final String? gioMoBaoVangMat;

  // Hai mốc này là bằng chứng đã kiểm dụng cụ trước khi dắt
  final String? gioBatDauPhien;
  final String? gioXacMinhDungCu;

  // Số liệu phiên đang chạy, cập nhật theo GPS
  final double? kmDaDi;

  // Thiếu một mốc thì để trống, không suy từ gói GPS
  final int? phutThucHien;

  final int? phutConLai;

  // Còn giá trị là chưa đủ thời lượng, sau đó còn cửa geofence
  final String? gioMoKetThuc;

  // Vài tấm mới nhất và tổng ảnh đã gửi trong phiên
  final List<String> anhNhatKy;
  final int tongAnhNhatKy;

  // Đơn đã huỷ theo bất kỳ lối nào: mốc đơn khép lại
  final String? gioHetHan;
  final String? ngayHetHan;

  // Thiếu trường này thì khối tiền phải bịa 0đ cho đơn huỷ
  final int tienHuyBanNhan;

  // Mã như server lưu, null khi hệ thống tự huỷ vì hết hạn
  final String? lyDoHuy;

  // Số liệu chốt của phiên, đơn hết hạn thì ba cột đều 0
  final KetQuaPhien? ketQua;

  // Chỉ đơn tắm và cắt tỉa; đơn dắt và đơn trông giữ để trống
  final ThongTinGrooming? grooming;

  // Chỉ đơn trông giữ; hai dịch vụ kia để trống
  final ThongTinTrongGiu? trongGiu;

  // Rỗng là chưa có gì để kể nên khối biến mất khỏi màn
  final List<MocDienBien> dienBien;

  // Hai nhóm tách nhau vì chúng ghép thành album trước - sau
  final List<String> anhTruoc;
  final int tongAnhTruoc;
  final List<String> anhSau;
  final int tongAnhSau;

  // Nhận đơn rồi mới mở chat, mới lộ số nhà và mới có đường đi
  bool get daNhanDon => tinhTrang != TinhTrangDonNcc.choXacNhan && !daBoDangDo;

  // Ẩn nút thì hỏi cờ này, daHetHan chỉ là một trong các lối huỷ
  bool get daBoDangDo => switch (tinhTrang) {
    TinhTrangDonNcc.hetHanNhan ||
    TinhTrangDonNcc.banDaHuy ||
    TinhTrangDonNcc.khachHuy ||
    TinhTrangDonNcc.khachVangMat ||
    TinhTrangDonNcc.tuHuyTrungLich ||
    TinhTrangDonNcc.huyBoiQuanTri ||
    TinhTrangDonNcc.khongRo => true,
    _ => false,
  };

  bool get daHetHan => tinhTrang == TinhTrangDonNcc.hetHanNhan;

  // Mốc chia đôi cách bỏ đơn (bộ luật mục 6)
  bool get daXuatPhat =>
      tinhTrang == TinhTrangDonNcc.dangToi ||
      tinhTrang == TinhTrangDonNcc.daBaoMuon ||
      tinhTrang == TinhTrangDonNcc.daToiDiemDon;

  // Đã tới điểm đón, việc còn lại là nhận bé
  bool get daToiNoi => tinhTrang == TinhTrangDonNcc.daToiDiemDon;

  // Phiên đang chạy, GPS đang ghi quãng đường
  bool get dangDat => tinhTrang == TinhTrangDonNcc.dangDat;

  bool get choChot => tinhTrang == TinhTrangDonNcc.choChuNuoiXacNhan;

  // Làm tại nhà chủ nuôi nên không có lộ trình GPS
  bool get laGrooming => loai == ServiceType.grooming;

  // Trông giữ đảo chiều đi lại nên không có đường đi và báo muộn
  bool get laTrongGiu => loai == ServiceType.boarding;

  // Trả bé tận tay nên đơn chốt ngay, không phải chờ
  bool get daHoanThanh => tinhTrang == TinhTrangDonNcc.hoanThanh;

  // Quá giờ hẹn mà chủ nuôi vẫn chưa mang bé tới
  bool get quaHenNhanBe => tinhTrang == TinhTrangDonNcc.quaHenNhanBe;

  // Chủ nuôi cắt ngắn kỳ giữ, mốc trả và tiền đã tính lại
  bool get daChotKetThucSom => trongGiu?.ketThucSom != null;

  // Tách hai cửa vì nhãn nút phải nói đúng cửa đang chặn
  bool get duGioKetThuc => gioMoKetThuc == null;

  // Mỗi đơn chỉ báo đến muộn một lần, báo rồi nút chết
  bool get daBaoMuon => tinhTrang == TinhTrangDonNcc.daBaoMuon;

  // Cũng là điều kiện có bản đồ và có chuyện báo muộn
  bool get daMoDiaChi => viTri != null;

  // Cam kết rọ mõm và dây xích chỉ hỏi trước khi nhận đơn
  bool get canCamKetAnToan =>
      loai == ServiceType.walking && tinhTrang == TinhTrangDonNcc.choXacNhan;

  // Khối Tới điểm đón có từ lúc nhận đơn và mất khi đã tới nơi
  bool get coKhoiDuongDi =>
      !laTrongGiu && daNhanDon && !daToiNoi && !dangDat && !choChot;

  bool get chiDuongDaMo => gioMoChiDuong == null;

  int get phiNenTang => tongTien * phanTramPhiNenTang ~/ 100;
  int get thucNhan => tongTien - phiNenTang;

  // Đơn bỏ dở ngắt quãng, mốc giữa chỉ tick nếu đã qua thật
  Set<int> get mocXong => switch (tinhTrang) {
    TinhTrangDonNcc.choXacNhan => const {0},
    TinhTrangDonNcc.hetHanNhan ||
    TinhTrangDonNcc.tuHuyTrungLich ||
    TinhTrangDonNcc.huyBoiQuanTri => const {0, 3},
    TinhTrangDonNcc.khongRo => const {},
    TinhTrangDonNcc.banDaHuy ||
    TinhTrangDonNcc.khachHuy ||
    TinhTrangDonNcc.khachVangMat => const {0, 1, 3},
    // Ba mốc đầu tick, mốc Hoàn thành còn chờ chủ nuôi
    TinhTrangDonNcc.choChuNuoiXacNhan => const {0, 1, 2},
    TinhTrangDonNcc.hoanThanh => const {0, 1, 2, 3},
    _ => const {0, 1},
  };

  // Đơn đã dừng hoặc đã xong thì không còn mốc nào chờ
  int? get mocDangO => switch (tinhTrang) {
    TinhTrangDonNcc.choXacNhan => 1,
    TinhTrangDonNcc.hoanThanh => null,
    TinhTrangDonNcc.choChuNuoiXacNhan => 3,
    _ => daBoDangDo ? null : 2,
  };

  // Truyền null là giữ giá trị cũ
  SitterOrderDetail copyWith({
    String? bookingId,
    String? maDon,
    TinhTrangDonNcc? tinhTrang,
    ServiceType? loai,
    String? tenDichVu,
    List<Pet>? pets,
    String? tenChuNuoi,
    int? soDonDaDat,
    String? gioHen,
    String? ngayNganHen,
    String? moTaThoiGian,
    double? kmToiDiemDon,
    String? khuVucDiemDon,
    String? ghiChu,
    List<DongHoaDon>? dongTien,
    int? tongTien,
    int? phanTramPhiNenTang,
    int? phanTramPhiHuy,
    int? gioGiuTien,
    int? tranTyLeHuy,
    String? avatarChuNuoi,
    String? diaChiDayDu,
    LatLng? viTri,
    String? mocPhu,
    String? gioMoChiDuong,
    String? ngayMoChiDuong,
    String? gioMoXuatPhat,
    String? gioMoBatDau,
    int? phutBaoMuon,
    String? gioDuKienToi,
    String? gioDaBaoMuon,
    String? gioToiNoi,
    int? metCachDiemDon,
    String? gioMoBaoVangMat,
    String? gioBatDauPhien,
    String? gioXacMinhDungCu,
    double? kmDaDi,
    int? phutThucHien,
    int? phutConLai,
    String? gioMoKetThuc,
    List<String>? anhNhatKy,
    int? tongAnhNhatKy,
    String? gioHetHan,
    String? ngayHetHan,
    int? tienHuyBanNhan,
    String? lyDoHuy,
    KetQuaPhien? ketQua,
    ThongTinGrooming? grooming,
    ThongTinTrongGiu? trongGiu,
    List<MocDienBien>? dienBien,
    List<String>? anhTruoc,
    int? tongAnhTruoc,
    List<String>? anhSau,
    int? tongAnhSau,
    // Vài trường phải xoá được khi đổi trạng thái
    bool xoaMocChiDuong = false,
    bool xoaMocPhu = false,
    bool xoaMocKetThuc = false,
    bool xoaMocXuatPhat = false,
    bool xoaMocBatDau = false,
  }) => SitterOrderDetail(
    bookingId: bookingId ?? this.bookingId,
    maDon: maDon ?? this.maDon,
    tinhTrang: tinhTrang ?? this.tinhTrang,
    loai: loai ?? this.loai,
    tenDichVu: tenDichVu ?? this.tenDichVu,
    pets: pets ?? this.pets,
    tenChuNuoi: tenChuNuoi ?? this.tenChuNuoi,
    soDonDaDat: soDonDaDat ?? this.soDonDaDat,
    gioHen: gioHen ?? this.gioHen,
    ngayNganHen: ngayNganHen ?? this.ngayNganHen,
    moTaThoiGian: moTaThoiGian ?? this.moTaThoiGian,
    kmToiDiemDon: kmToiDiemDon ?? this.kmToiDiemDon,
    khuVucDiemDon: khuVucDiemDon ?? this.khuVucDiemDon,
    ghiChu: ghiChu ?? this.ghiChu,
    dongTien: dongTien ?? this.dongTien,
    tongTien: tongTien ?? this.tongTien,
    phanTramPhiNenTang: phanTramPhiNenTang ?? this.phanTramPhiNenTang,
    phanTramPhiHuy: phanTramPhiHuy ?? this.phanTramPhiHuy,
    gioGiuTien: gioGiuTien ?? this.gioGiuTien,
    tranTyLeHuy: tranTyLeHuy ?? this.tranTyLeHuy,
    avatarChuNuoi: avatarChuNuoi ?? this.avatarChuNuoi,
    diaChiDayDu: diaChiDayDu ?? this.diaChiDayDu,
    viTri: viTri ?? this.viTri,
    mocPhu: xoaMocPhu ? null : (mocPhu ?? this.mocPhu),
    gioMoChiDuong: xoaMocChiDuong
        ? null
        : (gioMoChiDuong ?? this.gioMoChiDuong),
    ngayMoChiDuong: xoaMocChiDuong
        ? null
        : (ngayMoChiDuong ?? this.ngayMoChiDuong),
    gioMoXuatPhat: xoaMocXuatPhat
        ? null
        : (gioMoXuatPhat ?? this.gioMoXuatPhat),
    gioMoBatDau: xoaMocBatDau ? null : (gioMoBatDau ?? this.gioMoBatDau),
    phutBaoMuon: phutBaoMuon ?? this.phutBaoMuon,
    gioDuKienToi: gioDuKienToi ?? this.gioDuKienToi,
    gioDaBaoMuon: gioDaBaoMuon ?? this.gioDaBaoMuon,
    gioToiNoi: gioToiNoi ?? this.gioToiNoi,
    metCachDiemDon: metCachDiemDon ?? this.metCachDiemDon,
    gioMoBaoVangMat: gioMoBaoVangMat ?? this.gioMoBaoVangMat,
    gioBatDauPhien: gioBatDauPhien ?? this.gioBatDauPhien,
    gioXacMinhDungCu: gioXacMinhDungCu ?? this.gioXacMinhDungCu,
    kmDaDi: kmDaDi ?? this.kmDaDi,
    phutThucHien: phutThucHien ?? this.phutThucHien,
    phutConLai: phutConLai ?? this.phutConLai,
    gioMoKetThuc: xoaMocKetThuc ? null : (gioMoKetThuc ?? this.gioMoKetThuc),
    anhNhatKy: anhNhatKy ?? this.anhNhatKy,
    tongAnhNhatKy: tongAnhNhatKy ?? this.tongAnhNhatKy,
    gioHetHan: gioHetHan ?? this.gioHetHan,
    ngayHetHan: ngayHetHan ?? this.ngayHetHan,
    tienHuyBanNhan: tienHuyBanNhan ?? this.tienHuyBanNhan,
    lyDoHuy: lyDoHuy ?? this.lyDoHuy,
    ketQua: ketQua ?? this.ketQua,
    grooming: grooming ?? this.grooming,
    trongGiu: trongGiu ?? this.trongGiu,
    dienBien: dienBien ?? this.dienBien,
    anhTruoc: anhTruoc ?? this.anhTruoc,
    tongAnhTruoc: tongAnhTruoc ?? this.tongAnhTruoc,
    anhSau: anhSau ?? this.anhSau,
    tongAnhSau: tongAnhSau ?? this.tongAnhSau,
  );
}
