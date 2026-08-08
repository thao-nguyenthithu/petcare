import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_card_map.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/features/wallet/data/wallet_api.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/data/thong_ke_ky.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';

// Dựng model hiển thị của cụm ví
String mocNgan(AppLocalizations l10n, DateTime d) =>
    '${thuNgan(l10n, d)} ${ngayThang(d)} · ${gioPhut(d)}';

TaiKhoanNganHang? taiKhoanTuApi(TaiKhoanNganHangApi? api) => api == null
    ? null
    : TaiKhoanNganHang(
        tenNganHang: api.tenNganHang,
        bonSoCuoi: api.bonSoCuoi,
        tenChuTaiKhoan: api.tenChuTaiKhoan,
        daXacThuc: api.daXacThuc,
        soLuotConLai: api.soLuotConLai,
        soLuotMoiNgay: api.soLuotMoiNgay,
      );

LoaiGiaoDich loaiGiaoDichTuMa(String ma) => switch (ma) {
  'RUT_RA' => LoaiGiaoDich.rutRa,
  'DIEU_CHINH' => LoaiGiaoDich.dieuChinh,
  _ => LoaiGiaoDich.tienVao,
};

String maLoaiGiaoDich(LoaiGiaoDich loai) => switch (loai) {
  LoaiGiaoDich.tienVao => 'TIEN_VAO',
  LoaiGiaoDich.rutRa => 'RUT_RA',
  LoaiGiaoDich.dieuChinh => 'DIEU_CHINH',
};

ViNguoiCham viTuApi(AppLocalizations l10n, ViApi api) => ViNguoiCham(
  soDuKhaDung: api.soDuKhaDung,
  daNhanTrongThang: api.daNhanTrongThang,
  thangHienTai: api.thangHienTai,
  thuNhapTuanNay: api.thuNhapTuanNay,
  cotTuanNay: api.cotTuanNay,
  chiSoHomNay: api.chiSoHomNay,
  nganHang: taiKhoanTuApi(api.nganHang),
  khoanGiuTam: [
    for (final k in api.khoanGiuTam)
      if (k.don != null)
        KhoanGiuTam(
          don: cardDonNccTuApi(l10n, k.don!),
          soTien: k.soTien,
          dangKhieuNai: k.dangKhieuNai,
          motaMoc: k.moc == null ? '' : mocNgan(l10n, k.moc!),
        ),
  ],
);

GiaoDichVi giaoDichTuApi(AppLocalizations l10n, GiaoDichViApi api) =>
    GiaoDichVi(
      ma: api.ma,
      loai: loaiGiaoDichTuMa(api.loai),
      tieuDe: api.tieuDe,
      soTien: api.soTien,
      thoiDiem: api.thoiDiem,
      moTaMoc: mocNgan(l10n, api.thoiDiem),
      soDuSau: api.soDuSau,
      don: api.don == null ? null : cardDonNccTuApi(l10n, api.don!),
      maThamChieu: api.maThamChieu,
      maKhieuNai: api.maKhieuNai,
    );

GiaoDichVi giaoDichGanDayThanhGiaoDich(
  AppLocalizations l10n,
  GiaoDichGanDayApi api,
) => GiaoDichVi(
  ma: api.ma,
  loai: LoaiGiaoDich.tienVao,
  tieuDe: api.tieuDe,
  soTien: api.soTien,
  thoiDiem: api.thoiDiem,
  moTaMoc: mocNgan(l10n, api.thoiDiem),
  soDuSau: 0,
  don: api.don == null ? null : cardDonNccTuApi(l10n, api.don!),
);

List<MocViDien> dienBienTuApi(AppLocalizations l10n, List<MocDienBienApi> ds) =>
    [
      for (final m in ds)
        (
          viec: m.viec,
          thoiDiem: m.thoiDiem == null ? '' : mocNgan(l10n, m.thoiDiem!),
          daXong: m.daXong,
        ),
    ];

ChiTietGiaoDich chiTietGiaoDichTuApi(
  AppLocalizations l10n,
  ChiTietGiaoDichApi api,
) => ChiTietGiaoDich(
  giaoDich: giaoDichTuApi(l10n, api.giaoDich),
  mocTrangThai: api.moc == null
      ? ''
      : '${nhanNgayCoNam(l10n, api.moc!)} ${l10n.nhanLucGio(gioPhut(api.moc!))}',
  dongMot: api.dongMot,
  dongHai: api.dongHai,
  tong: api.tong,
  dienBien: dienBienTuApi(l10n, api.dienBien),
  chuNuoiPhanAnh: api.khieuNai?.chuNuoiPhanAnh,
  ketLuan: api.khieuNai?.ketLuan == null
      ? null
      : (
          noiDung: api.khieuNai!.ketLuan!,
          lyDo: api.khieuNai!.lyDo,
          nguoiXuLy: l10n.boPhanHoTro,
          thoiDiem: api.khieuNai!.thoiDiem == null
              ? ''
              : mocNgan(l10n, api.khieuNai!.thoiDiem!),
        ),
);

TrangThaiKhieuNai trangThaiKhieuNaiTuMa(String ma) => switch (ma) {
  'choHoTroXuLy' => TrangThaiKhieuNai.choHoTroXuLy,
  'daHoanMotPhan' => TrangThaiKhieuNai.daHoanMotPhan,
  'khongChapNhan' => TrangThaiKhieuNai.khongChapNhan,
  _ => TrangThaiKhieuNai.choBanPhanHoi,
};

HoSoKhieuNai khieuNaiTuApi(AppLocalizations l10n, HoSoKhieuNaiApi api) {
  final don = api.don;
  return HoSoKhieuNai(
    ma: api.ma,
    trangThai: trangThaiKhieuNaiTuMa(api.trangThai),
    don: don == null ? _donTrong(l10n) : cardDonNccTuApi(l10n, don),
    soTien: api.soTien,
    moTaMoc: api.thoiDiemPhanAnh == null
        ? ''
        : mocNgan(l10n, api.thoiDiemPhanAnh!),
    phanAnh: api.phanAnh,
    thoiDiemPhanAnh: api.thoiDiemPhanAnh == null
        ? ''
        : mocNgan(l10n, api.thoiDiemPhanAnh!),
    anhPhanAnh: api.anhPhanAnh,
    phanHoiCuaBan: api.phanHoiCuaBan,
    thoiDiemPhanHoi: api.thoiDiemPhanHoi == null
        ? null
        : mocNgan(l10n, api.thoiDiemPhanHoi!),
    anhPhanHoi: api.anhPhanHoi,
    hanPhanHoi: api.hanPhanHoi == null
        ? null
        : '${nhanNgayCoNam(l10n, api.hanPhanHoi!)} ${l10n.nhanLucGio(gioPhut(api.hanPhanHoi!))}',
    phutConLai: api.hanPhanHoi == null ? null : _phutToi(api.hanPhanHoi!),
    ketLuan: api.ketLuan?.ketLuan == null
        ? null
        : (
            noiDung: api.ketLuan!.ketLuan!,
            lyDo: api.ketLuan!.lyDo,
            nguoiXuLy: l10n.boPhanHoTro,
            thoiDiem: api.ketLuan!.thoiDiem == null
                ? ''
                : mocNgan(l10n, api.ketLuan!.thoiDiem!),
          ),
    cacDongTien: [
      for (final d in api.cacDongTien) (nhan: d.nhan, tien: d.tien),
    ],
    tongCuoi: api.tongCuoi == null
        ? null
        : (nhan: api.tongCuoi!.nhan, tien: api.tongCuoi!.tien),
    dienBien: const [],
  );
}

List<ThongKeCot> cotTuanTuVi(AppLocalizations l10n, ViNguoiCham vi) {
  final nhan = [
    for (var thu = DateTime.monday; thu <= DateTime.sunday; thu++)
      thuNganTheoSo(l10n, thu),
  ];
  return [
    for (var i = 0; i < nhan.length; i++)
      ThongKeCot(
        label: nhan[i],
        amount: i < vi.cotTuanNay.length ? vi.cotTuanNay[i] : 0,
        upcoming: i > vi.chiSoHomNay,
      ),
  ];
}

ThongKeKy thuNhapTuApi(AppLocalizations l10n, ThuNhapApi api) => ThongKeKy(
  rangeLabel: api.rangeLabel,
  total: api.total,
  changePercent: api.changePercent ?? 0,
  ordersDone: api.ordersDone,
  hoursWorked: api.hoursWorked == 0 ? '' : l10n.nGioNhan('${api.hoursWorked}'),
  chartTitle: api.chartTitle,
  bars: api.bars,
  highlightBar: api.highlightBar,
);

int? _phutToi(DateTime moc) {
  final con = moc.difference(nowVn()).inMinutes;
  return con > 0 ? con : null;
}

SitterBooking _donTrong(AppLocalizations l10n) => SitterBooking(
  id: '',
  maDon: '',
  tenChuNuoi: '',
  dichVu: LoaiDichVu.datDiDao,
  trangThai: SitterBookingStatus.khieuNai,
  batDau: nowVn(),
  pets: const [],
  soTien: 0,
);
