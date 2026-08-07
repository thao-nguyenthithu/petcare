import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/grooming_tasks.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/price_line_labels.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

// Dựng model hiển thị từ payload thô, server quyết trạng thái

SitterOrderDetail donNccTuApi(
  BuildContext context,
  ChiTietDonNccApi api,
  CauHinhNghiepVu cauHinh,
) {
  final l10n = context.l10n;
  final bayGio = nowVn();
  final dong = api.dong;
  final tinhTrang = _tinhTrang(api, bayGio);
  final phien = api.phien;
  return SitterOrderDetail(
    bookingId: dong.id,
    maDon: dong.code,
    tinhTrang: tinhTrang,
    loai: dong.loai,
    tenDichVu: _tenDichVu(context, dong),
    pets: api.pets,
    tenChuNuoi: api.tenChuNuoi,
    avatarChuNuoi: api.avatarChuNuoi,
    soDonDaDat: api.soDonChuNuoiDaDat,
    gioHen: gioPhut(dong.batDau),
    ngayNganHen: '${thuNgan(l10n, dong.batDau)} ${ngayThang(dong.batDau)}',
    moTaThoiGian: _moTaThoiGian(context, dong),
    kmToiDiemDon: api.kmToiDiemDon ?? 0,
    khuVucDiemDon: api.khuVucDiemDon ?? '',
    diaChiDayDu: api.diaChiDayDu,
    viTri: api.viTri,
    ghiChu: api.ghiChu ?? '',
    dongTien: dongHoaDonCuaDonNcc(context, api),
    tongTien: dong.tongTien,
    phanTramPhiNenTang: api.phanTramPhiNenTang,
    phanTramPhiHuy: cauHinh.phiHuyMuonPhanTram,
    gioGiuTien: cauHinh.gioGiuTien,
    tranTyLeHuy: cauHinh.tranTyLeHuy,
    mocPhu: _mocPhu(l10n, api, tinhTrang, bayGio),
    gioMoChiDuong: _gio(api.mocMoChiDuong),
    ngayMoChiDuong: _ngay(api.mocMoChiDuong),
    gioMoXuatPhat: _gioConKhoa(api.mocMoXuatPhat, bayGio),
    gioMoBatDau: _gioConKhoa(api.mocMoBatDau, bayGio),
    phutBaoMuon: api.baoMuon?.phut,
    gioDuKienToi: _gio(api.baoMuon?.duKienLuc),
    gioDaBaoMuon: _gio(api.baoMuon?.baoLuc),
    gioToiNoi: _gio(api.toiNoiLuc),
    metCachDiemDon: api.metCachDiemDon,
    gioMoBaoVangMat: _gioConKhoa(api.mocBaoVangMat, bayGio),
    gioBatDauPhien: _gio(phien?.batDauLuc),
    gioXacMinhDungCu: _gio(phien?.xacMinhLuc),
    kmDaDi: phien?.km,
    phutThucHien: _phutThucHien(api),
    phutConLai: _phutConLai(dong, bayGio),
    gioMoKetThuc: _gioConKhoa(phien?.mocDuGio, bayGio),
    anhNhatKy: _anhNhatKy(api),
    tongAnhNhatKy: _tongAnhNhatKy(api),
    gioHetHan: _gio(api.thongTinHuy?.luc),
    ngayHetHan: _ngay(api.thongTinHuy?.luc),
    tienHuyBanNhan: api.thongTinHuy?.nccNhan ?? 0,
    lyDoHuy: api.thongTinHuy?.lyDo,
    ketQua: _ketQua(api, tinhTrang, bayGio),
    grooming: _grooming(context, api, bayGio),
    trongGiu: _trongGiu(context, api, bayGio, cauHinh.gioGiuTien),
    dienBien: _dienBien(context, api),
    anhTruoc: api.grooming?.anhTruoc ?? const [],
    tongAnhTruoc: api.grooming?.anhTruoc.length ?? 0,
    anhSau: api.grooming?.anhSau ?? const [],
    tongAnhSau: api.grooming?.anhSau.length ?? 0,
  );
}

// Dùng chung bảng nhãn với chủ nuôi, khác chữ là dễ cãi nhau
List<DongHoaDon> dongHoaDonCuaDonNcc(
  BuildContext context,
  ChiTietDonNccApi api,
) {
  final theoId = {for (final be in api.pets) be.id: be};
  return [
    for (final d in api.dongGia)
      (
        nhan: nhanDongGiaDon(
          context,
          key: d.key,
          tien: d.tien,
          meta: d.meta,
          be: theoId[d.petId],
        ),
        tien: d.tien,
      ),
  ];
}

// Rút trạng thái server về các tình trạng của màn
TinhTrangDonNcc _tinhTrang(ChiTietDonNccApi api, DateTime bayGio) {
  final trongGiu = api.dong.loai == ServiceType.boarding;
  switch (api.dong.trangThai) {
    case TrangThaiDonApi.choNhan:
      return TinhTrangDonNcc.choXacNhan;
    case TrangThaiDonApi.daNhan:
      if (trongGiu) return _tinhTrangTrongGiu(api, bayGio);
      if (api.toiNoiLuc != null) return TinhTrangDonNcc.daToiDiemDon;
      if (api.baoMuon != null) return TinhTrangDonNcc.daBaoMuon;
      if (api.xuatPhatLuc != null) return TinhTrangDonNcc.dangToi;
      return TinhTrangDonNcc.daNhanDon;
    case TrangThaiDonApi.dangChay:
    case TrangThaiDonApi.choChuNuoiDuyetAnh:
      return TinhTrangDonNcc.dangDat;
    case TrangThaiDonApi.choChuNuoiChot:
    // Khiếu nại vẫn là chờ chốt, không đẩy sang hoàn thành
    case TrangThaiDonApi.khieuNai:
      return TinhTrangDonNcc.choChuNuoiXacNhan;
    case TrangThaiDonApi.hoanThanh:
    case TrangThaiDonApi.daXuLy:
      return TinhTrangDonNcc.hoanThanh;
    // Giữ nguyên từng kết cục huỷ, gộp lại là đổ lỗi sai người
    case TrangThaiDonApi.huyHetHan:
      // Hệ thống huỷ có hai nguyên nhân, server phân biệt bằng bên huỷ
      return api.thongTinHuy?.ben == 'systemSitterBusy'
          ? TinhTrangDonNcc.tuHuyTrungLich
          : TinhTrangDonNcc.hetHanNhan;
    case TrangThaiDonApi.huyBoiNguoiCham:
      return TinhTrangDonNcc.banDaHuy;
    case TrangThaiDonApi.huyBoiChuNuoi:
      return TinhTrangDonNcc.khachHuy;
    case TrangThaiDonApi.huyVangMat:
      return TinhTrangDonNcc.khachVangMat;
    case TrangThaiDonApi.huyBoiQuanTri:
      return TinhTrangDonNcc.huyBoiQuanTri;
    case TrangThaiDonApi.khongRo:
      return TinhTrangDonNcc.khongRo;
  }
}

// Trông giữ đọc mốc của chủ nuôi, không đọc mốc người chăm
TinhTrangDonNcc _tinhTrangTrongGiu(ChiTietDonNccApi api, DateTime bayGio) {
  if (api.chuNuoiToiLuc != null) return TinhTrangDonNcc.dangToi;
  if (api.baoMuon != null) return TinhTrangDonNcc.daBaoMuon;
  final mocBao = api.mocBaoVangMat;
  if (mocBao != null && !bayGio.isBefore(mocBao)) {
    return TinhTrangDonNcc.quaHenNhanBe;
  }
  return TinhTrangDonNcc.daNhanDon;
}

String _tenDichVu(BuildContext context, DongDonNccApi dong) {
  final l10n = context.l10n;
  final ten = serviceTypeNameDai(context, dong.loai);
  final phan = switch (dong.loai) {
    ServiceType.boarding =>
      (dong.soDem ?? 0) == 0 ? null : l10n.soDemNhan('${dong.soDem}'),
    _ =>
      (dong.thoiLuongPhut ?? 0) == 0
          ? null
          : l10n.nPhut('${dong.thoiLuongPhut}'),
  };
  return phan == null ? ten : '$ten · $phan';
}

String _nhanNgayDai(BuildContext context, DateTime d) =>
    '${thuDaiTheoSo(context.l10n, d.weekday)}, ${ngayThang(d)}';

String _moTaThoiGian(BuildContext context, DongDonNccApi dong) {
  final l10n = context.l10n;
  final nhanNgay = _nhanNgayDai(context, dong.batDau);
  final gio = gioPhut(dong.batDau);
  // Grooming chỉ chốt giờ bắt đầu, giờ xong chỉ là dự kiến
  if (dong.loai == ServiceType.grooming) return l10n.ngayLucGio(nhanNgay, gio);
  // Trông giữ: hàng này chỉ nói mốc nhận bé, mốc trả ở hàng riêng
  if (dong.loai == ServiceType.boarding || dong.ketThuc == null) {
    return '$nhanNgay · $gio';
  }
  return '$nhanNgay · ${l10n.khungGio(gio, gioPhut(dong.ketThuc!))}';
}

String? _gio(DateTime? d) => d == null ? null : gioPhut(d);

String? _ngay(DateTime? d) => d == null ? null : ngayThang(d);

// Còn giá trị là nút vẫn khoá, qua mốc thì trả null
String? _gioConKhoa(DateTime? moc, DateTime bayGio) =>
    moc == null || !bayGio.isBefore(moc) ? null : gioPhut(moc);

int? _phutConLai(DongDonNccApi dong, DateTime bayGio) {
  final het = dong.ketThuc;
  if (het == null) return null;
  final phut = het.difference(bayGio).inMinutes;
  return phut > 0 ? phut : 0;
}

// Chữ bên phải dòng trạng thái, đếm tới mốc đang chờ
String? _mocPhu(
  AppLocalizations l10n,
  ChiTietDonNccApi api,
  TinhTrangDonNcc tinhTrang,
  DateTime bayGio,
) {
  final trongGiu = api.dong.loai == ServiceType.boarding;
  int? conLai(DateTime? moc) {
    if (moc == null) return null;
    final phut = moc.difference(bayGio).inMinutes;
    return phut > 0 ? phut : null;
  }

  switch (tinhTrang) {
    case TinhTrangDonNcc.choXacNhan:
      final phut = conLai(api.dong.hanTraLoi);
      return phut == null
          ? null
          : l10n.tuHuySauKhoang(dongHoConLai(l10n, phut));
    case TinhTrangDonNcc.daNhanDon:
      final phut = conLai(api.dong.batDau);
      if (phut == null) return null;
      final khoang = dongHoConLai(l10n, phut);
      return trongGiu
          ? l10n.nhanBeSauKhoang(khoang)
          : l10n.batDauSauKhoang(khoang);
    case TinhTrangDonNcc.dangToi:
      final phut = conLai(api.dong.batDau);
      return phut == null
          ? null
          : l10n.batDauSauKhoang(dongHoConLai(l10n, phut));
    case TinhTrangDonNcc.daBaoMuon:
      final gio = _gio(api.baoMuon?.duKienLuc);
      return gio == null ? null : l10n.duKienToiGio(gio);
    case TinhTrangDonNcc.quaHenNhanBe:
      final tre = bayGio.difference(api.dong.batDau).inMinutes;
      return tre <= 0 ? null : l10n.quaHenKhoang(dongHoConLai(l10n, tre));
    case TinhTrangDonNcc.daToiDiemDon:
      final met = api.metCachDiemDon;
      return met == null ? null : l10n.cachDiaChiMet('$met');
    case TinhTrangDonNcc.dangDat:
      final phut = conLai(api.dong.ketThuc);
      return phut == null ? null : l10n.conKhoang(dongHoConLai(l10n, phut));
    case TinhTrangDonNcc.choChuNuoiXacNhan:
      final phut = conLai(api.tuChotLuc);
      return phut == null
          ? null
          : l10n.tuXacNhanSauKhoang(dongHoConLai(l10n, phut));
    // Đơn đã khép thì không còn gì để đếm ngược
    case TinhTrangDonNcc.hoanThanh:
    case TinhTrangDonNcc.hetHanNhan:
    case TinhTrangDonNcc.banDaHuy:
    case TinhTrangDonNcc.khachHuy:
    case TinhTrangDonNcc.khachVangMat:
    case TinhTrangDonNcc.tuHuyTrungLich:
    case TinhTrangDonNcc.huyBoiQuanTri:
    case TinhTrangDonNcc.khongRo:
      return null;
  }
}

// Vài tấm mới nhất, cùng nguồn với con số tổng bên dưới
List<String> _anhNhatKy(ChiTietDonNccApi api) {
  final anh = api.trongGiu?.anh ?? api.phien?.anh ?? const [];
  return anh.length <= 3 ? anh : anh.sublist(anh.length - 3);
}

int _tongAnhNhatKy(ChiTietDonNccApi api) =>
    api.trongGiu?.anh.length ?? api.phien?.tongAnh ?? 0;

// Thiếu một đầu thì trả null để màn bỏ hẳn dòng đó
int? _phutThucHien(ChiTietDonNccApi api) {
  final batDau = api.grooming?.batDauLuc ?? api.phien?.batDauLuc;
  final ketThuc = api.grooming?.ketThucLuc ?? api.phien?.ketThucLuc;
  if (batDau == null || ketThuc == null) return null;
  final phut = ketThuc.difference(batDau).inMinutes;
  return phut <= 0 ? null : phut;
}

// Gom các kết cục huỷ vì mọi chỗ tổng kết đối xử như nhau
// Trạng thái lạ không nằm đây, chưa hiểu đơn thì đừng chốt về 0
bool _daBoDangDo(TinhTrangDonNcc t) => switch (t) {
  TinhTrangDonNcc.hetHanNhan ||
  TinhTrangDonNcc.banDaHuy ||
  TinhTrangDonNcc.khachHuy ||
  TinhTrangDonNcc.khachVangMat ||
  TinhTrangDonNcc.tuHuyTrungLich ||
  TinhTrangDonNcc.huyBoiQuanTri => true,
  _ => false,
};

// Đơn huỷ thì ba cột về 0 cho rõ là không có gì diễn ra
KetQuaPhien? _ketQua(
  ChiTietDonNccApi api,
  TinhTrangDonNcc tinhTrang,
  DateTime bayGio,
) {
  if (_daBoDangDo(tinhTrang)) {
    return (phut: 0, km: null, soAnh: 0);
  }
  if (tinhTrang != TinhTrangDonNcc.choChuNuoiXacNhan &&
      tinhTrang != TinhTrangDonNcc.hoanThanh) {
    return null;
  }
  final phien = api.phien;
  final batDau = phien?.batDauLuc;
  final ketThuc = phien?.ketThucLuc ?? bayGio;
  final phut = batDau == null ? 0 : ketThuc.difference(batDau).inMinutes;
  return (
    phut: phut < 0 ? 0 : phut,
    km: phien?.km,
    soAnh:
        _tongAnhNhatKy(api) +
        (api.grooming?.anhTruoc.length ?? 0) +
        (api.grooming?.anhSau.length ?? 0),
  );
}

ThongTinGrooming? _grooming(
  BuildContext context,
  ChiTietDonNccApi api,
  DateTime bayGio,
) {
  final g = api.grooming;
  if (g == null) return null;
  final batDau = g.batDauLuc;
  final ketThuc = g.ketThucLuc;
  final den = ketThuc ?? bayGio;
  return (
    goiTungBe: _goiTungBe(api),
    gioDuKienXong: _gio(g.duKienXongLuc) ?? '',
    gioBatDauLam: _gio(batDau),
    phutDaLam: batDau == null ? null : den.difference(batDau).inMinutes,
    gioKetThuc: _gio(ketThuc),
  );
}

// Hạng mục lấy theo gói, server chưa lưu riêng từng đơn
List<GoiGroomingCuaBe> _goiTungBe(ChiTietDonNccApi api) {
  final theoId = {for (final be in api.pets) be.id: be};
  return [
    for (final t in api.grooming?.goiTungBe ?? const <GoiBeApi>[])
      if (theoId[t.petId] case final Pet be?)
        (
          be: be,
          goi: _goiGrooming(t.maGoi),
          phut: t.phut ?? 0,
          hangMuc: hangMucMacDinhTheoGoi[_goiGrooming(t.maGoi)] ?? const [],
        ),
  ];
}

GroomingPackage _goiGrooming(String? ma) =>
    ma == 'bath' ? GroomingPackage.bath : GroomingPackage.bathAndTrim;

ThongTinTrongGiu? _trongGiu(
  BuildContext context,
  ChiTietDonNccApi api,
  DateTime bayGio,
  int gioGiuTien,
) {
  final l10n = context.l10n;
  final ky = api.trongGiu;
  if (ky == null) return null;
  final nhan = ky.nhanBeLuc ?? api.dong.batDau;
  final tra = ky.traBeLuc;
  final capNhat = ky.capNhatMoiNhat;
  final conLai = tra?.difference(bayGio).inMinutes;
  final ketThuc = ky.ketThucLuc;
  final conBaoSuCo = ketThuc == null
      ? null
      : gioGiuTien - bayGio.difference(ketThuc).inHours;
  return (
    soDem: ky.soDem,
    demHienTai: ky.demHienTai,
    moTaNhanBe: '${_nhanNgayDai(context, nhan)} · ${gioPhut(nhan)}',
    moTaTraBe: tra == null
        ? ''
        : '${_nhanNgayDai(context, tra)} · ${gioPhut(tra)}',
    nhanBeNgan: '${ngayThang(nhan)} · ${gioPhut(nhan)}',
    traBeNgan: tra == null ? '' : '${ngayThang(tra)} · ${gioPhut(tra)}',
    ngayTraNgan: tra == null ? '' : ngayThang(tra),
    conLaiToiTra: conLai == null || conLai <= 0
        ? null
        : dongHoConLai(l10n, conLai),
    gioTraDuKien: tra == null ? null : '${thuNgan(l10n, tra)} ${gioPhut(tra)}',
    ghiChuLucNhanBe: ky.ghiChuNhanBe,
    capNhatMoiNhat: capNhat?.loiNhan,
    gioCapNhatMoiNhat: capNhat?.luc == null
        ? null
        : nhanThoiDiemNgan(l10n, capNhat!.luc!),
    nhanNgayAnh: _nhanNgayAnh(ky),
    gioNhanBe: _gio(ky.daNhanBeLuc),
    gioChuNuoiToiDon: _gio(ky.chuNuoiToiLuc),
    gioKetThuc: _gio(ketThuc),
    gioConBaoSuCo: conBaoSuCo == null || conBaoSuCo <= 0 ? null : conBaoSuCo,
    anhBeNhan: ky.anhBeNhan,
    anhBeTra: ky.anhBeTra,
    anhDoDungNhan: ky.anhDoDungNhan,
    anhDoDungTra: ky.anhDoDungTra,
    // TODO: nối khối earlyEnd và review của chi tiết đơn
    ketThucSom: null,
    danhGia: null,
  );
}

// Ngày chụp mấy tấm mới nhất, tấm cũ để trống chứ không gán bừa
List<String> _nhanNgayAnh(TrongGiuApi ky) {
  final luc = ky.capNhatMoiNhat?.luc;
  if (luc == null) return const [];
  return [for (final _ in _lay3(ky.anh)) ngayThang(luc)];
}

List<String> _lay3(List<String> anh) =>
    anh.length <= 3 ? anh : anh.sublist(anh.length - 3);

// Chỉ kể thứ máy tự biết, lời khai dồn về mốc kết thúc
List<MocDienBien> _dienBien(BuildContext context, ChiTietDonNccApi api) {
  final l10n = context.l10n;
  final phien = api.phien;
  final g = api.grooming;
  final ky = api.trongGiu;
  return [
    if (api.nhanDonLuc case final luc?)
      (gio: gioPhut(luc), viec: l10n.dienBienDaNhanDon, daXong: true),
    if (api.xuatPhatLuc case final luc?)
      (gio: gioPhut(luc), viec: l10n.dienBienXuatPhat, daXong: true),
    if (api.toiNoiLuc case final luc?)
      (gio: gioPhut(luc), viec: l10n.dienBienDaToiNoi, daXong: true),
    if (phien?.xacMinhLuc case final luc?)
      (gio: gioPhut(luc), viec: l10n.dienBienAnhCheckIn, daXong: true),
    if (ky?.daNhanBeLuc case final luc?)
      (
        gio: gioPhut(luc),
        viec: l10n.dienBienNhanNBe('${api.pets.length}', api.tenChuNuoi),
        daXong: true,
      ),
    if (g?.batDauLuc case final luc?)
      (
        gio: gioPhut(luc),
        viec: g!.anhTruoc.isEmpty
            ? l10n.dienBienBatDauLam
            : l10n.dienBienBatDauCoAnh,
        daXong: true,
      )
    else if (phien?.batDauLuc case final luc?)
      (gio: gioPhut(luc), viec: l10n.dienBienBatDauPhien, daXong: true),
    if (ky?.capNhatMoiNhat case final capNhat?)
      if (capNhat.luc case final luc?)
        (
          gio: gioPhut(luc),
          viec: l10n.dienBienCapNhatNAnh('${capNhat.anh.length}'),
          daXong: true,
        ),
    if ((ky?.ketThucLuc ?? g?.ketThucLuc ?? phien?.ketThucLuc) case final luc?)
      (gio: gioPhut(luc), viec: l10n.dienBienKetThuc, daXong: true),
  ];
}
