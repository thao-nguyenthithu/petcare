import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

class BookingDraft {
  const BookingDraft({
    required this.sitter,
    required this.loai,
    required this.pets,
    required this.tamTinh,
    this.phutMotLuot,
    this.goiTheoBe = const {},
    this.diaChiChon,
    this.ghiChu = '',
    this.giaMotDem = 0,
    this.phutGrooming = 0,
    this.camKetDungCu = false,
    this.ngay,
    this.gio,
    this.ngayTra,
    this.gioTra,
  });

  final SitterProfile sitter;
  final ServiceType loai;
  final List<Pet> pets;
  final int tamTinh;
  final int? phutMotLuot;
  final Map<String, GroomingPackage> goiTheoBe;
  final SavedAddress? diaChiChon;
  final String ghiChu;
  String? get diaChi => diaChiChon?.diaChiDayDu;
  final int giaMotDem;
  final int phutGrooming;
  final bool camKetDungCu;
  final DateTime? ngay;
  final KhungGio? gio;
  final DateTime? ngayTra;
  final KhungGio? gioTra;

  BookingDraft copyWith({
    DateTime? ngay,
    KhungGio? gio,
    DateTime? ngayTra,
    KhungGio? gioTra,
    SavedAddress? diaChiChon,
  }) => BookingDraft(
    sitter: sitter,
    loai: loai,
    pets: pets,
    tamTinh: tamTinh,
    phutMotLuot: phutMotLuot,
    goiTheoBe: goiTheoBe,
    diaChiChon: diaChiChon ?? this.diaChiChon,
    ghiChu: ghiChu,
    giaMotDem: giaMotDem,
    phutGrooming: phutGrooming,
    camKetDungCu: camKetDungCu,
    ngay: ngay ?? this.ngay,
    gio: gio ?? this.gio,
    ngayTra: ngayTra ?? this.ngayTra,
    gioTra: gioTra ?? this.gioTra,
  );

  // Gán lại toàn bộ ngày giờ
  BookingDraft datNgayGio({
    DateTime? ngay,
    KhungGio? gio,
    DateTime? ngayTra,
    KhungGio? gioTra,
  }) => BookingDraft(
    sitter: sitter,
    loai: loai,
    pets: pets,
    tamTinh: tamTinh,
    phutMotLuot: phutMotLuot,
    goiTheoBe: goiTheoBe,
    diaChiChon: diaChiChon,
    ghiChu: ghiChu,
    giaMotDem: giaMotDem,
    phutGrooming: phutGrooming,
    camKetDungCu: camKetDungCu,
    ngay: ngay,
    gio: gio,
    ngayTra: ngayTra,
    gioTra: gioTra,
  );

  int get soDem =>
      ngay == null || ngayTra == null ? 0 : soDemGiua(ngay!, ngayTra!);

  int get phutGiuThemDon =>
      gio == null || gioTra == null ? 0 : phutGiuThem(gio!, gioTra!);

  int get phiGiuThemDon =>
      loai != ServiceType.boarding ? 0 : phiGiuThem(phutGiuThemDon, giaMotDem);

  int get tongTien => loai == ServiceType.boarding
      ? giaMotDem * soDem + phiGiuThemDon
      : tamTinh;

  bool get duNgayGio => loai == ServiceType.boarding
      ? ngay != null && ngayTra != null && gio != null && gioTra != null
      : ngay != null && gio != null;
}

enum MucSuaDon { thuCung, ghiChu }

typedef YeuCauSua = ({MucSuaDon? muc, BookingDraft draft});
