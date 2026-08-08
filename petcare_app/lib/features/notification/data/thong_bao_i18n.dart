import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/features/notification/data/thong_bao.dart';

String tieuDeThongBao(AppLocalizations l10n, ThongBao tin) =>
    _cau(l10n, tin.titleKey, tin.params) ?? tin.title;

String noiDungThongBao(AppLocalizations l10n, ThongBao tin) =>
    _cau(l10n, tin.bodyKey, tin.params) ?? tin.message;

String _t(Map<String, String> p, String ten) => p[ten] ?? '';

// Tin quản trị tự soạn không có khoá, khoá lạ thì rơi về chữ backend gửi
String? _cau(AppLocalizations l10n, String? khoa, Map<String, String> p) {
  return switch (khoa) {
    'tbHoSoSapBiAnTieuDe' => l10n.tbHoSoSapBiAnTieuDe,
    'tbHoSoSapBiAnNoiDung' => l10n.tbHoSoSapBiAnNoiDung(
      _t(p, 'soCanhCao'),
      _t(p, 'conLai'),
    ),
    'tbHoSoBiKhoaTieuDe' => l10n.tbHoSoBiKhoaTieuDe,
    'tbHoSoBiKhoaNoiDung' => l10n.tbHoSoBiKhoaNoiDung,
    'tbHoSoTamAnTieuDe' => l10n.tbHoSoTamAnTieuDe,
    'tbHoSoTamAnNoiDung' => l10n.tbHoSoTamAnNoiDung(_t(p, 'soNgay')),
    'tbPhongBenhToiHanTieuDe' => l10n.tbPhongBenhToiHanTieuDe(
      _t(p, 'tenHangMuc'),
      _t(p, 'tenBe'),
    ),
    'tbPhongBenhToiHanNoiDung' => l10n.tbPhongBenhToiHanNoiDung(
      _t(p, 'conMayNgay'),
      _t(p, 'tenHangMuc'),
      _t(p, 'tenBe'),
    ),
    'tbPhongBenhNhacCuoiNoiDung' => l10n.tbPhongBenhNhacCuoiNoiDung(
      _t(p, 'tenHangMuc'),
      _t(p, 'tenBe'),
    ),
    'tbDonMoiTieuDe' => l10n.tbDonMoiTieuDe,
    'tbDonMoiNoiDung' => l10n.tbDonMoiNoiDung(
      _t(p, 'tenDichVu'),
      _t(p, 'code'),
    ),
    'tbDaNhanDonTieuDe' => l10n.tbDaNhanDonTieuDe,
    'tbDaNhanDonNoiDung' => l10n.tbDaNhanDonNoiDung(
      _t(p, 'tenNcc'),
      _t(p, 'code'),
    ),
    'tbTuChoiDonTieuDe' => l10n.tbTuChoiDonTieuDe,
    'tbTuChoiDonNoiDung' => l10n.tbTuChoiDonNoiDung(_t(p, 'code')),
    'tbDaXuatPhatTieuDe' => l10n.tbDaXuatPhatTieuDe,
    'tbDaXuatPhatNoiDung' => l10n.tbDaXuatPhatNoiDung(
      _t(p, 'tenNcc'),
      _t(p, 'code'),
    ),
    'tbDaToiNoiTieuDe' => l10n.tbDaToiNoiTieuDe,
    'tbDaToiNoiNoiDung' => l10n.tbDaToiNoiNoiDung(_t(p, 'code')),
    'tbSapHetGioGiaoBeTieuDe' => l10n.tbSapHetGioGiaoBeTieuDe,
    'tbSapHetGioGiaoBeNoiDung' => l10n.tbSapHetGioGiaoBeNoiDung(
      _t(p, 'code'),
      _t(p, 'phanTramPhi'),
    ),
    'tbDaBatDauTieuDe' => l10n.tbDaBatDauTieuDe,
    'tbDaBatDauNoiDung' => l10n.tbDaBatDauNoiDung(
      _t(p, 'tenDichVu'),
      _t(p, 'code'),
    ),
    'tbChoXacNhanTieuDe' => l10n.tbChoXacNhanTieuDe,
    'tbChoXacNhanNoiDung' => l10n.tbChoXacNhanNoiDung(
      _t(p, 'code'),
      _t(p, 'gioGiuTien'),
    ),
    'tbAnhMoiTieuDe' => l10n.tbAnhMoiTieuDe,
    'tbAnhMoiNoiDung' => l10n.tbAnhMoiNoiDung(_t(p, 'code')),
    'tbNccHuyDonTieuDe' => l10n.tbNccHuyDonTieuDe,
    'tbNccHuyDonNoiDung' => l10n.tbNccHuyDonNoiDung(_t(p, 'code')),
    'tbNccKhongTiepNhanTieuDe' => l10n.tbNccKhongTiepNhanTieuDe,
    'tbNccKhongTiepNhanNoiDung' => l10n.tbNccKhongTiepNhanNoiDung(
      _t(p, 'code'),
    ),
    'tbThieuDungCuChuNuoiTieuDe' => l10n.tbThieuDungCuChuNuoiTieuDe,
    'tbThieuDungCuChuNuoiNoiDung' => l10n.tbThieuDungCuChuNuoiNoiDung(
      _t(p, 'code'),
      _t(p, 'phiHuy'),
      _t(p, 'hoanLai'),
    ),
    'tbThieuDungCuNccTieuDe' => l10n.tbThieuDungCuNccTieuDe,
    'tbThieuDungCuNccNoiDung' => l10n.tbThieuDungCuNccNoiDung(
      _t(p, 'code'),
      _t(p, 'nccNhan'),
    ),
    'tbVangMatChuNuoiTieuDe' => l10n.tbVangMatChuNuoiTieuDe,
    'tbVangMatChuNuoiNoiDung' => l10n.tbVangMatChuNuoiNoiDung(
      _t(p, 'code'),
      _t(p, 'phiHuy'),
      _t(p, 'soGioPhanDoi'),
    ),
    'tbVangMatNccTieuDe' => l10n.tbVangMatNccTieuDe,
    'tbVangMatNccNoiDung' => l10n.tbVangMatNccNoiDung(
      _t(p, 'code'),
      _t(p, 'nccNhan'),
      _t(p, 'soGioPhanDoi'),
    ),
    'tbQuaGioHenTieuDe' => l10n.tbQuaGioHenTieuDe,
    'tbQuaGioHenChuNuoiNoiDung' => l10n.tbQuaGioHenChuNuoiNoiDung(
      _t(p, 'code'),
    ),
    'tbQuaGioHenNccNoiDung' => l10n.tbQuaGioHenNccNoiDung(_t(p, 'code')),
    'tbKetThucSomChuNuoiTieuDe' => l10n.tbKetThucSomChuNuoiTieuDe,
    'tbKetThucSomChuNuoiNoiDung' => l10n.tbKetThucSomChuNuoiNoiDung(
      _t(p, 'code'),
      _t(p, 'hoanLai'),
    ),
    'tbKetThucSomNccTieuDe' => l10n.tbKetThucSomNccTieuDe,
    'tbKetThucSomNccNoiDung' => l10n.tbKetThucSomNccNoiDung(_t(p, 'code')),
    'tbChuNuoiHuyDonTieuDe' => l10n.tbChuNuoiHuyDonTieuDe,
    'tbChuNuoiHuyDonNoiDung' => l10n.tbChuNuoiHuyDonNoiDung(_t(p, 'code')),
    'tbQuaHanNhanChuNuoiTieuDe' => l10n.tbQuaHanNhanChuNuoiTieuDe,
    'tbQuaHanNhanChuNuoiNoiDung' => l10n.tbQuaHanNhanChuNuoiNoiDung(
      _t(p, 'code'),
    ),
    'tbQuaHanNhanNccTieuDe' => l10n.tbQuaHanNhanNccTieuDe,
    'tbQuaHanNhanNccNoiDung' => l10n.tbQuaHanNhanNccNoiDung(_t(p, 'code')),
    'tbNccChuaToiChuNuoiTieuDe' => l10n.tbNccChuaToiChuNuoiTieuDe,
    'tbNccChuaToiChuNuoiNoiDung' => l10n.tbNccChuaToiChuNuoiNoiDung(
      _t(p, 'code'),
    ),
    'tbNccChuaToiNccTieuDe' => l10n.tbNccChuaToiNccTieuDe,
    'tbNccChuaToiNccNoiDung' => l10n.tbNccChuaToiNccNoiDung(_t(p, 'code')),
    'tbNccBanChuNuoiTieuDe' => l10n.tbNccBanChuNuoiTieuDe,
    'tbNccBanChuNuoiNoiDung' => l10n.tbNccBanChuNuoiNoiDung(_t(p, 'code')),
    'tbNccBanNccTieuDe' => l10n.tbNccBanNccTieuDe,
    'tbNccBanNccNoiDung' => l10n.tbNccBanNccNoiDung(_t(p, 'code')),
    'tbDanhGiaMoiTieuDe' => l10n.tbDanhGiaMoiTieuDe,
    'tbDanhGiaMoiNoiDung' => l10n.tbDanhGiaMoiNoiDung(_t(p, 'soSao')),
    'tbAdminHuyDonTieuDe' => l10n.tbAdminHuyDonTieuDe,
    'tbAdminHuyDonChuaTraTienNoiDung' => l10n.tbAdminHuyDonChuaTraTienNoiDung(
      _t(p, 'code'),
      _t(p, 'lyDo'),
    ),
    'tbAdminHuyDonHoanDuNoiDung' => l10n.tbAdminHuyDonHoanDuNoiDung(
      _t(p, 'code'),
      _t(p, 'lyDo'),
    ),
    'tbAdminHuyDonNccNoiDung' => l10n.tbAdminHuyDonNccNoiDung(
      _t(p, 'code'),
      _t(p, 'lyDo'),
    ),
    'tbKhieuNaiKetLuanTieuDe' => l10n.tbKhieuNaiKetLuanTieuDe,
    'tbKhieuNaiCoHoanNoiDung' => l10n.tbKhieuNaiCoHoanNoiDung(
      _t(p, 'code'),
      _t(p, 'ketLuan'),
      _t(p, 'soTien'),
      _t(p, 'lyDo'),
    ),
    'tbKhieuNaiKhongHoanNoiDung' => l10n.tbKhieuNaiKhongHoanNoiDung(
      _t(p, 'code'),
      _t(p, 'ketLuan'),
      _t(p, 'lyDo'),
    ),    _ => null,
  };
}
