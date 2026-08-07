import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

typedef GoiGroomingCuaBe = ({
  Pet be,
  GroomingPackage goi,
  int phut,
  List<String> hangMuc,
});

typedef ThongTinGrooming = ({
  List<GoiGroomingCuaBe> goiTungBe,
  String gioDuKienXong,
  String? gioBatDauLam,
  int? phutDaLam,
  String? gioKetThuc,
});

typedef KetThucSomCuaKy = ({String moTaTraGoc, int soDemGoc});

typedef DanhGiaChuNuoi = ({int sao, double diem, String ngay, String noiDung});

typedef ThongTinTrongGiu = ({
  int soDem,
  int? demHienTai,
  String moTaNhanBe,
  String moTaTraBe,
  String nhanBeNgan,
  String traBeNgan,
  String ngayTraNgan,
  String? conLaiToiTra,
  String? gioTraDuKien,
  String? ghiChuLucNhanBe,
  String? capNhatMoiNhat,
  String? gioCapNhatMoiNhat,
  List<String> nhanNgayAnh,
  String? gioNhanBe,
  String? gioChuNuoiToiDon,
  String? gioKetThuc,
  int? gioConBaoSuCo,
  List<String> anhBeNhan,
  List<String> anhBeTra,
  List<String> anhDoDungNhan,
  List<String> anhDoDungTra,
  KetThucSomCuaKy? ketThucSom,
  DanhGiaChuNuoi? danhGia,
});

extension ThongTinTrongGiuCopy on ThongTinTrongGiu {
  ThongTinTrongGiu copyWith({
    int? soDem,
    int? demHienTai,
    String? moTaNhanBe,
    String? moTaTraBe,
    String? nhanBeNgan,
    String? traBeNgan,
    String? ngayTraNgan,
    String? conLaiToiTra,
    String? gioTraDuKien,
    String? ghiChuLucNhanBe,
    String? capNhatMoiNhat,
    String? gioCapNhatMoiNhat,
    List<String>? nhanNgayAnh,
    String? gioNhanBe,
    String? gioChuNuoiToiDon,
    String? gioKetThuc,
    int? gioConBaoSuCo,
    List<String>? anhBeNhan,
    List<String>? anhBeTra,
    List<String>? anhDoDungNhan,
    List<String>? anhDoDungTra,
    KetThucSomCuaKy? ketThucSom,
    DanhGiaChuNuoi? danhGia,
  }) => (
    soDem: soDem ?? this.soDem,
    demHienTai: demHienTai ?? this.demHienTai,
    moTaNhanBe: moTaNhanBe ?? this.moTaNhanBe,
    moTaTraBe: moTaTraBe ?? this.moTaTraBe,
    nhanBeNgan: nhanBeNgan ?? this.nhanBeNgan,
    traBeNgan: traBeNgan ?? this.traBeNgan,
    ngayTraNgan: ngayTraNgan ?? this.ngayTraNgan,
    conLaiToiTra: conLaiToiTra ?? this.conLaiToiTra,
    gioTraDuKien: gioTraDuKien ?? this.gioTraDuKien,
    ghiChuLucNhanBe: ghiChuLucNhanBe ?? this.ghiChuLucNhanBe,
    capNhatMoiNhat: capNhatMoiNhat ?? this.capNhatMoiNhat,
    gioCapNhatMoiNhat: gioCapNhatMoiNhat ?? this.gioCapNhatMoiNhat,
    nhanNgayAnh: nhanNgayAnh ?? this.nhanNgayAnh,
    gioNhanBe: gioNhanBe ?? this.gioNhanBe,
    gioChuNuoiToiDon: gioChuNuoiToiDon ?? this.gioChuNuoiToiDon,
    gioKetThuc: gioKetThuc ?? this.gioKetThuc,
    gioConBaoSuCo: gioConBaoSuCo ?? this.gioConBaoSuCo,
    anhBeNhan: anhBeNhan ?? this.anhBeNhan,
    anhBeTra: anhBeTra ?? this.anhBeTra,
    anhDoDungNhan: anhDoDungNhan ?? this.anhDoDungNhan,
    anhDoDungTra: anhDoDungTra ?? this.anhDoDungTra,
    ketThucSom: ketThucSom ?? this.ketThucSom,
    danhGia: danhGia ?? this.danhGia,
  );
}
