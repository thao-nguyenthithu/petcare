import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';

DongDonNccApi? _don(Object? o) =>
    o is Map ? DongDonNccApi.fromJson(Map<String, dynamic>.from(o)) : null;

int _tien(Object? o) => o is num ? o.round() : 0;

class TaiKhoanNganHangApi {
  const TaiKhoanNganHangApi({
    required this.tenNganHang,
    required this.bonSoCuoi,
    required this.tenChuTaiKhoan,
    required this.daXacThuc,
    this.soLuotConLai,
    this.soLuotMoiNgay,
  });

  factory TaiKhoanNganHangApi.fromJson(Map<String, dynamic> j) =>
      TaiKhoanNganHangApi(
        tenNganHang: j['tenNganHang'] as String? ?? '',
        bonSoCuoi: j['bonSoCuoi'] as String? ?? '',
        tenChuTaiKhoan: j['tenChuTaiKhoan'] as String? ?? '',
        daXacThuc: j['daXacThuc'] as bool? ?? false,
        soLuotConLai: (j['soLuotConLai'] as num?)?.toInt(),
        soLuotMoiNgay: (j['soLuotMoiNgay'] as num?)?.toInt(),
      );

  final String tenNganHang;
  final String bonSoCuoi;
  final String tenChuTaiKhoan;
  final bool daXacThuc;

  final int? soLuotConLai;
  final int? soLuotMoiNgay;
}

class KhoanGiuTamApi {
  const KhoanGiuTamApi({
    required this.don,
    required this.soTien,
    required this.dangKhieuNai,
    required this.moc,
    this.maKhieuNai,
  });

  factory KhoanGiuTamApi.fromJson(Map<String, dynamic> j) => KhoanGiuTamApi(
    don: _don(j['don']),
    soTien: _tien(j['soTien']),
    dangKhieuNai: j['dangKhieuNai'] as bool? ?? false,
    maKhieuNai: j['maKhieuNai'] as String?,
    moc: docMocVn(j['moc'] as String?),
  );

  final DongDonNccApi? don;
  final int soTien;
  final bool dangKhieuNai;
  final String? maKhieuNai;
  final DateTime? moc;
}

class ViApi {
  const ViApi({
    required this.soDuKhaDung,
    required this.daNhanTrongThang,
    required this.thangHienTai,
    required this.thuNhapTuanNay,
    required this.cotTuanNay,
    required this.chiSoHomNay,
    required this.khoanGiuTam,
    this.nganHang,
  });

  factory ViApi.fromJson(Map<String, dynamic> j) => ViApi(
    soDuKhaDung: _tien(j['soDuKhaDung']),
    daNhanTrongThang: _tien(j['daNhanTrongThang']),
    thangHienTai: (j['thangHienTai'] as num?)?.toInt() ?? nowVn().month,
    thuNhapTuanNay: _tien(j['thuNhapTuanNay']),
    cotTuanNay: [
      for (final e in (j['cotTuanNay'] as List? ?? const [])) _tien(e),
    ],
    chiSoHomNay: (j['chiSoHomNay'] as num?)?.toInt() ?? 0,
    nganHang: j['nganHang'] == null
        ? null
        : TaiKhoanNganHangApi.fromJson(
            Map<String, dynamic>.from(j['nganHang'] as Map),
          ),
    khoanGiuTam: [
      for (final e in (j['khoanGiuTam'] as List? ?? const []))
        KhoanGiuTamApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final int soDuKhaDung;
  final int daNhanTrongThang;
  final int thangHienTai;
  final int thuNhapTuanNay;
  final List<int> cotTuanNay;
  final int chiSoHomNay;
  final TaiKhoanNganHangApi? nganHang;
  final List<KhoanGiuTamApi> khoanGiuTam;
}

class GiaoDichViApi {
  const GiaoDichViApi({
    required this.ma,
    required this.loai,
    required this.tieuDe,
    required this.soTien,
    required this.soDuSau,
    required this.thoiDiem,
    this.don,
    this.maKhieuNai,
    this.maThamChieu,
  });

  factory GiaoDichViApi.fromJson(Map<String, dynamic> j) => GiaoDichViApi(
    ma: j['ma'] as String? ?? '',
    loai: j['loai'] as String? ?? 'TIEN_VAO',
    tieuDe: j['tieuDe'] as String? ?? '',
    soTien: _tien(j['soTien']),
    soDuSau: _tien(j['soDuSau']),
    thoiDiem: docMocVn(j['thoiDiem'] as String?) ?? nowVn(),
    don: _don(j['don']),
    maKhieuNai: j['maKhieuNai'] as String?,
    maThamChieu: j['maThamChieu'] as String?,
  );

  final String ma;

  final String loai;
  final String tieuDe;

  final int soTien;
  final int soDuSau;
  final DateTime thoiDiem;
  final DongDonNccApi? don;
  final String? maKhieuNai;
  final String? maThamChieu;
}

class TrangGiaoDichVi {
  const TrangGiaoDichVi({required this.items, this.truocTiep});

  factory TrangGiaoDichVi.fromJson(Map<String, dynamic> j) => TrangGiaoDichVi(
    items: [
      for (final e in (j['items'] as List? ?? const []))
        GiaoDichViApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    truocTiep: j['truocTiep'] as String?,
  );

  final List<GiaoDichViApi> items;
  final String? truocTiep;
}

class MocDienBienApi {
  const MocDienBienApi({
    required this.viec,
    required this.daXong,
    this.thoiDiem,
  });

  factory MocDienBienApi.fromJson(Map<String, dynamic> j) => MocDienBienApi(
    viec: j['viec'] as String? ?? '',
    daXong: j['daXong'] as bool? ?? false,
    thoiDiem: docMocVn(j['thoiDiem'] as String?),
  );

  final String viec;
  final bool daXong;
  final DateTime? thoiDiem;
}

class ChiTietGiaoDichApi {
  const ChiTietGiaoDichApi({
    required this.giaoDich,
    required this.dongMot,
    required this.dongHai,
    required this.tong,
    required this.dienBien,
    this.moc,
    this.khieuNai,
  });

  factory ChiTietGiaoDichApi.fromJson(Map<String, dynamic> j) =>
      ChiTietGiaoDichApi(
        giaoDich: GiaoDichViApi.fromJson(
          Map<String, dynamic>.from(j['giaoDich'] as Map),
        ),
        dongMot: _tien(j['dongMot']),
        dongHai: _tien(j['dongHai']),
        tong: _tien(j['tong']),
        moc: docMocVn(j['moc'] as String?),
        dienBien: [
          for (final e in (j['dienBien'] as List? ?? const []))
            MocDienBienApi.fromJson(Map<String, dynamic>.from(e as Map)),
        ],
        khieuNai: j['khieuNai'] == null
            ? null
            : KetLuanKhieuNaiApi.fromJson(
                Map<String, dynamic>.from(j['khieuNai'] as Map),
              ),
      );

  final GiaoDichViApi giaoDich;
  final int dongMot;
  final int dongHai;
  final int tong;
  final DateTime? moc;
  final List<MocDienBienApi> dienBien;
  final KetLuanKhieuNaiApi? khieuNai;
}

class KetLuanKhieuNaiApi {
  const KetLuanKhieuNaiApi({
    required this.ma,
    this.chuNuoiPhanAnh,
    this.ketLuan,
    this.lyDo,
    this.thoiDiem,
  });

  factory KetLuanKhieuNaiApi.fromJson(Map<String, dynamic> j) =>
      KetLuanKhieuNaiApi(
        ma: j['ma'] as String? ?? '',
        chuNuoiPhanAnh: j['chuNuoiPhanAnh'] as String?,
        ketLuan: j['ketLuan'] as String? ?? j['noiDung'] as String?,
        lyDo: j['lyDo'] as String?,
        thoiDiem: docMocVn(j['thoiDiem'] as String?),
      );

  final String ma;
  final String? chuNuoiPhanAnh;
  final String? ketLuan;
  final String? lyDo;
  final DateTime? thoiDiem;
}

class DongTienApi {
  const DongTienApi({required this.nhan, required this.tien});

  factory DongTienApi.fromJson(Map<String, dynamic> j) =>
      DongTienApi(nhan: j['nhan'] as String? ?? '', tien: _tien(j['tien']));

  final String nhan;
  final int tien;
}

class HoSoKhieuNaiApi {
  const HoSoKhieuNaiApi({
    required this.ma,
    required this.trangThai,
    required this.soTien,
    required this.phanAnh,
    required this.anhPhanAnh,
    required this.anhPhanHoi,
    required this.cacDongTien,
    this.don,
    this.thoiDiemPhanAnh,
    this.phanHoiCuaBan,
    this.thoiDiemPhanHoi,
    this.hanPhanHoi,
    this.ketLuan,
    this.tongCuoi,
  });

  factory HoSoKhieuNaiApi.fromJson(Map<String, dynamic> j) => HoSoKhieuNaiApi(
    ma: j['ma'] as String? ?? '',
    trangThai: j['trangThai'] as String? ?? 'choBanPhanHoi',
    don: _don(j['don']),
    soTien: _tien(j['soTien']),
    phanAnh: j['phanAnh'] as String? ?? '',
    anhPhanAnh: [
      for (final e in (j['anhPhanAnh'] as List? ?? const [])) e as String,
    ],
    thoiDiemPhanAnh: docMocVn(j['thoiDiemPhanAnh'] as String?),
    phanHoiCuaBan: j['phanHoiCuaBan'] as String?,
    anhPhanHoi: [
      for (final e in (j['anhPhanHoi'] as List? ?? const [])) e as String,
    ],
    thoiDiemPhanHoi: docMocVn(j['thoiDiemPhanHoi'] as String?),
    hanPhanHoi: docMocVn(j['hanPhanHoi'] as String?),
    ketLuan: j['ketLuan'] == null
        ? null
        : KetLuanKhieuNaiApi.fromJson(
            Map<String, dynamic>.from(j['ketLuan'] as Map),
          ),
    cacDongTien: [
      for (final e in (j['cacDongTien'] as List? ?? const []))
        DongTienApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    tongCuoi: j['tongCuoi'] == null
        ? null
        : DongTienApi.fromJson(Map<String, dynamic>.from(j['tongCuoi'] as Map)),
  );

  final String ma;

  final String trangThai;
  final DongDonNccApi? don;
  final int soTien;
  final String phanAnh;
  final List<String> anhPhanAnh;
  final DateTime? thoiDiemPhanAnh;
  final String? phanHoiCuaBan;
  final List<String> anhPhanHoi;
  final DateTime? thoiDiemPhanHoi;
  final DateTime? hanPhanHoi;
  final KetLuanKhieuNaiApi? ketLuan;
  final List<DongTienApi> cacDongTien;
  final DongTienApi? tongCuoi;
}

class KetQuaRutTien {
  const KetQuaRutTien({
    required this.maGiaoDich,
    required this.soTien,
    required this.phi,
    required this.thucNhan,
    required this.soDuConLai,
  });

  factory KetQuaRutTien.fromJson(Map<String, dynamic> j) => KetQuaRutTien(
    maGiaoDich: j['maGiaoDich'] as String? ?? '',
    soTien: _tien(j['soTien']),
    phi: _tien(j['phi']),
    thucNhan: _tien(j['thucNhan']),
    soDuConLai: _tien(j['soDuConLai']),
  );

  final String maGiaoDich;
  final int soTien;
  final int phi;
  final int thucNhan;
  final int soDuConLai;
}

class GiaoDichGanDayApi {
  const GiaoDichGanDayApi({
    required this.ma,
    required this.tieuDe,
    required this.soTien,
    required this.thoiDiem,
    this.don,
  });

  factory GiaoDichGanDayApi.fromJson(Map<String, dynamic> j) =>
      GiaoDichGanDayApi(
        ma: j['ma'] as String? ?? '',
        tieuDe: j['tieuDe'] as String? ?? '',
        soTien: _tien(j['soTien']),
        thoiDiem: docMocVn(j['thoiDiem'] as String?) ?? nowVn(),
        don: _don(j['don']),
      );

  final String ma;
  final String tieuDe;
  final int soTien;
  final DateTime thoiDiem;
  final DongDonNccApi? don;
}

class ThuNhapApi {
  const ThuNhapApi({
    required this.rangeLabel,
    required this.total,
    required this.ordersDone,
    required this.hoursWorked,
    required this.chartTitle,
    required this.bars,
    required this.highlightBar,
    required this.transactions,
    this.changePercent,
  });

  factory ThuNhapApi.fromJson(Map<String, dynamic> j) => ThuNhapApi(
    rangeLabel: j['rangeLabel'] as String? ?? '',
    total: _tien(j['total']),
    changePercent: (j['changePercent'] as num?)?.toInt(),
    ordersDone: (j['ordersDone'] as num?)?.toInt() ?? 0,
    hoursWorked: (j['hoursWorked'] as num?)?.toInt() ?? 0,
    chartTitle: j['chartTitle'] as String? ?? '',
    bars: [
      for (final e in (j['bars'] as List? ?? const []))
        ThongKeCot(
          label: (e as Map)['label'] as String? ?? '',
          amount: _tien(e['amount']),
          upcoming: e['upcoming'] as bool? ?? false,
        ),
    ],
    highlightBar: (j['highlightBar'] as num?)?.toInt() ?? 0,
    transactions: [
      for (final e in (j['transactions'] as List? ?? const []))
        GiaoDichGanDayApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final String rangeLabel;
  final int total;

  final int? changePercent;
  final int ordersDone;
  final int hoursWorked;
  final String chartTitle;
  final List<ThongKeCot> bars;
  final int highlightBar;
  final List<GiaoDichGanDayApi> transactions;
}
