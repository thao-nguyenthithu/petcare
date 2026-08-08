import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Dùng lại model của tab Lịch, không đẻ thêm model thứ hai
SitterBooking cardDonNccTuApi(AppLocalizations l10n, DongDonNccApi api) {
  final bayGio = nowVn();
  return SitterBooking(
    id: api.id,
    maDon: api.code,
    tenChuNuoi: api.tenChuNuoi,
    anhChuNuoi: api.anhChuNuoi,
    dichVu: _loaiDichVu(api.loai),
    trangThai: _trangThaiCard(api.trangThai),
    batDau: api.batDau,
    ketThuc: api.ketThuc,
    soDem: api.soDem,
    thoiLuongPhut: api.thoiLuongPhut,
    pets: api.pets,
    ghiChu: _ghiChuCard(api.trangThai),
    soTien: api.thucNhan,
    thucNhan:
        api.trangThai == TrangThaiDonApi.hoanThanh ||
        api.trangThai == TrangThaiDonApi.daXuLy,
    phutConLai: _phutConLaiCard(api, bayGio),
  );
}

LoaiDichVu _loaiDichVu(ServiceType loai) => switch (loai) {
  ServiceType.walking => LoaiDichVu.datDiDao,
  ServiceType.boarding => LoaiDichVu.trongGiu,
  ServiceType.grooming => LoaiDichVu.catTia,
};

SitterBookingStatus _trangThaiCard(TrangThaiDonApi tt) => switch (tt) {
  TrangThaiDonApi.choNhan => SitterBookingStatus.choXacNhan,
  TrangThaiDonApi.daNhan => SitterBookingStatus.daXacNhan,
  TrangThaiDonApi.dangChay => SitterBookingStatus.dangDienRa,
  TrangThaiDonApi.choChuNuoiChot => SitterBookingStatus.choChuNuoiXacNhan,
  TrangThaiDonApi.khieuNai => SitterBookingStatus.khieuNai,
  TrangThaiDonApi.hoanThanh ||
  TrangThaiDonApi.daXuLy => SitterBookingStatus.hoanThanh,
  TrangThaiDonApi.huyBoiChuNuoi ||
  TrangThaiDonApi.huyBoiNguoiCham ||
  TrangThaiDonApi.huyHetHan ||
  TrangThaiDonApi.huyVangMat ||
  TrangThaiDonApi.huyBoiQuanTri => SitterBookingStatus.daHuy,
  TrangThaiDonApi.khongRo => SitterBookingStatus.khongRo,
};

GhiChuDon _ghiChuCard(TrangThaiDonApi tt) => switch (tt) {
  TrangThaiDonApi.choNhan => GhiChuDon.choBanNhanDon,
  TrangThaiDonApi.choChuNuoiChot => GhiChuDon.choChuNuoiChot,
  TrangThaiDonApi.khieuNai => GhiChuDon.choHoTroXuLy,
  TrangThaiDonApi.huyVangMat => GhiChuDon.khachVangMat,
  TrangThaiDonApi.huyBoiChuNuoi => GhiChuDon.khachHuy,
  TrangThaiDonApi.huyBoiNguoiCham => GhiChuDon.banDaHuy,
  TrangThaiDonApi.huyHetHan => GhiChuDon.hetHanNhan,
  TrangThaiDonApi.huyBoiQuanTri => GhiChuDon.quanTriHuy,
  _ => GhiChuDon.khong,
};

int? _phutConLaiCard(DongDonNccApi api, DateTime bayGio) {
  final moc = switch (api.trangThai) {
    TrangThaiDonApi.choNhan => api.hanTraLoi,
    TrangThaiDonApi.dangChay => api.ketThuc,
    _ => null,
  };
  if (moc == null) return null;
  final phut = moc.difference(bayGio).inMinutes;
  return phut > 0 ? phut : null;
}
