import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_api.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_wallet.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_card_map.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';

LoaiGiaoDichChuNuoi _loai(String ma) => ma == 'hoanTien'
    ? LoaiGiaoDichChuNuoi.hoanTien
    : LoaiGiaoDichChuNuoi.thanhToan;

ThanhToanChuNuoi thanhToanTuApi(
  AppLocalizations l10n,
  TienDangGiuApi giu,
  int chiTieuThangNay,
) => ThanhToanChuNuoi(
  thangHienTai: nowVn().month,
  chiTieuThangNay: chiTieuThangNay,
  khoanTamGiu: [
    for (final k in giu.khoan)
      if (k.don != null)
        KhoanTamGiuChuNuoi(
          don: cardDonNccTuApi(l10n, k.don!),
          soTien: k.soTien,
          dangKhieuNai: k.dangKhieuNai,
        ),
  ],
);

GiaoDichChuNuoi giaoDichChuNuoiTuApi(
  AppLocalizations l10n,
  GiaoDichChuNuoiApi api,
) => GiaoDichChuNuoi(
  ma: api.ma,
  loai: _loai(api.loai),
  tieuDe: api.tieuDe,
  soTien: api.soTien,
  thoiDiem: api.thoiDiem,
  moTaMoc: mocNgan(l10n, api.thoiDiem),
  don: api.don == null ? null : cardDonNccTuApi(l10n, api.don!),
  nganHang: api.nganHang,
);

ChiTietGiaoDichChuNuoi chiTietThanhToanTuApi(
  AppLocalizations l10n,
  ChiTietThanhToanApi api,
) {
  final gd = giaoDichChuNuoiTuApi(l10n, api.giaoDich);
  final laHoan = gd.loai == LoaiGiaoDichChuNuoi.hoanTien;
  return ChiTietGiaoDichChuNuoi(
    giaoDich: gd,
    nhanTrangThai: mocNgan(l10n, gd.thoiDiem),
    tieuDeKhoiTien: '',
    cacDongTien: const [],
    tongCuoi: (nhan: '', tien: gd.soTien.abs()),
    dienBien: [
      for (final m in api.dienBien)
        (
          viec: m.viec,
          thoiDiem: m.thoiDiem == null ? '' : mocNgan(l10n, m.thoiDiem!),
          daXong: m.daXong,
        ),
    ],
    thongTinKhac: [
      (nhan: l10n.maGiaoDich, giaTri: gd.ma),
      if (gd.nganHang != null)
        (nhan: l10n.nganHangDaQuet, giaTri: gd.nganHang!),
    ],
    nhanNutDay: '',
    giaiThich: laHoan ? l10n.hoanTienVeTaiKhoan : null,
  );
}

ThongKeKy chiTieuTuApi(ChiTieuApi api) => ThongKeKy(
  rangeLabel: api.rangeLabel,
  total: api.total,
  changePercent: api.changePercent ?? 0,
  ordersDone: api.ordersDone,
  hoursWorked: '',
  chartTitle: api.chartTitle,
  bars: api.bars,
  highlightBar: api.highlightBar,
);

List<ChiTieuTheoDichVu> chiTieuTheoDichVuTuApi(ChiTieuApi api) => [
  for (final d in api.theoDichVu)
    (dichVu: d.dichVu, soDon: d.soDon, soTien: d.soTien),
];

typedef DongTienChuNuoi = DongTienVi;
