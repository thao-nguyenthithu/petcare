import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';

DongDonNccApi? _don(Object? o) =>
    o is Map ? DongDonNccApi.fromJson(Map<String, dynamic>.from(o)) : null;

int _tien(Object? o) => o is num ? o.round() : 0;

class KhoanTamGiuApi {
  const KhoanTamGiuApi({
    required this.soTien,
    required this.dangKhieuNai,
    this.don,
    this.maKhieuNai,
  });

  factory KhoanTamGiuApi.fromJson(Map<String, dynamic> j) => KhoanTamGiuApi(
    don: _don(j['don']),
    soTien: _tien(j['soTien']),
    dangKhieuNai: j['dangKhieuNai'] as bool? ?? false,
    maKhieuNai: j['maKhieuNai'] as String?,
  );

  final DongDonNccApi? don;
  final int soTien;
  final bool dangKhieuNai;
  final String? maKhieuNai;
}

class TienDangGiuApi {
  const TienDangGiuApi({required this.tong, required this.khoan});

  factory TienDangGiuApi.fromJson(Map<String, dynamic> j) => TienDangGiuApi(
    tong: _tien(j['tong']),
    khoan: [
      for (final e in (j['khoan'] as List? ?? const []))
        KhoanTamGiuApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final int tong;
  final List<KhoanTamGiuApi> khoan;
}

class GiaoDichChuNuoiApi {
  const GiaoDichChuNuoiApi({
    required this.ma,
    required this.loai,
    required this.tieuDe,
    required this.soTien,
    required this.thoiDiem,
    this.trangThai,
    this.nganHang,
    this.don,
  });

  factory GiaoDichChuNuoiApi.fromJson(Map<String, dynamic> j) =>
      GiaoDichChuNuoiApi(
        ma: j['ma'] as String? ?? '',
        loai: j['loai'] as String? ?? 'thanhToan',
        tieuDe: j['tieuDe'] as String? ?? '',
        soTien: _tien(j['soTien']),
        thoiDiem: docMocVn(j['thoiDiem'] as String?) ?? nowVn(),
        trangThai: j['trangThai'] as String?,
        // Cổng không trả số thẻ, thiếu thì CẤM bịa bốn số cuối
        nganHang: j['nganHang'] as String?,
        don: _don(j['don']),
      );

  final String ma;

  final String loai;
  final String tieuDe;

  final int soTien;
  final DateTime thoiDiem;
  final String? trangThai;
  final String? nganHang;
  final DongDonNccApi? don;
}

class MocThanhToanApi {
  const MocThanhToanApi({
    required this.viec,
    required this.daXong,
    this.thoiDiem,
  });

  factory MocThanhToanApi.fromJson(Map<String, dynamic> j) => MocThanhToanApi(
    viec: j['viec'] as String? ?? '',
    daXong: j['daXong'] as bool? ?? false,
    thoiDiem: docMocVn(j['thoiDiem'] as String?),
  );

  final String viec;
  final bool daXong;
  final DateTime? thoiDiem;
}

class ChiTietThanhToanApi {
  const ChiTietThanhToanApi({
    required this.giaoDich,
    required this.dienBien,
    this.maKhieuNai,
  });

  factory ChiTietThanhToanApi.fromJson(Map<String, dynamic> j) =>
      ChiTietThanhToanApi(
        giaoDich: GiaoDichChuNuoiApi.fromJson(
          Map<String, dynamic>.from(j['giaoDich'] as Map),
        ),
        maKhieuNai: j['maKhieuNai'] as String?,
        dienBien: [
          for (final e in (j['dienBien'] as List? ?? const []))
            MocThanhToanApi.fromJson(Map<String, dynamic>.from(e as Map)),
        ],
      );

  final GiaoDichChuNuoiApi giaoDich;
  final String? maKhieuNai;
  final List<MocThanhToanApi> dienBien;
}

class ChiTieuTheoDichVuApi {
  const ChiTieuTheoDichVuApi({
    required this.dichVu,
    required this.soDon,
    required this.soTien,
  });

  factory ChiTieuTheoDichVuApi.fromJson(Map<String, dynamic> j) =>
      ChiTieuTheoDichVuApi(
        dichVu: switch (j['dichVu'] as String?) {
          'boarding' => LoaiDichVu.trongGiu,
          'grooming' => LoaiDichVu.catTia,
          _ => LoaiDichVu.datDiDao,
        },
        soDon: (j['soDon'] as num?)?.toInt() ?? 0,
        soTien: _tien(j['soTien']),
      );

  final LoaiDichVu dichVu;
  final int soDon;
  final int soTien;
}

class ChiTieuApi {
  const ChiTieuApi({
    required this.rangeLabel,
    required this.thangHienTai,
    required this.total,
    required this.ordersDone,
    required this.chartTitle,
    required this.bars,
    required this.highlightBar,
    required this.theoDichVu,
    this.changePercent,
  });

  factory ChiTieuApi.fromJson(Map<String, dynamic> j) => ChiTieuApi(
    rangeLabel: j['rangeLabel'] as String? ?? '',
    thangHienTai: (j['thangHienTai'] as num?)?.toInt() ?? nowVn().month,
    total: _tien(j['total']),
    changePercent: (j['changePercent'] as num?)?.toInt(),
    ordersDone: (j['ordersDone'] as num?)?.toInt() ?? 0,
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
    theoDichVu: [
      for (final e in (j['theoDichVu'] as List? ?? const []))
        ChiTieuTheoDichVuApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final String rangeLabel;
  final int thangHienTai;
  final int total;

  final int? changePercent;
  final int ordersDone;
  final String chartTitle;
  final List<ThongKeCot> bars;
  final int highlightBar;
  final List<ChiTieuTheoDichVuApi> theoDichVu;
}
