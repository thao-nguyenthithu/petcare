import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/cancel_reasons.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail_api.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/price_line_labels.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

// Dựng model hiển thị của màn chi tiết đơn
const int _phutQuaHenNcc = 15;

OwnerBookingDetail chiTietTuApi(
  BuildContext context,
  ChiTietDonApi api,
  CauHinhNghiepVu cauHinh,
) {
  final l10n = context.l10n;
  final bayGio = nowVn();
  final tinhTrang = _tinhTrang(api, bayGio);
  final boarding = api.loai == ServiceType.boarding;
  final phutQuaHen = bayGio.difference(api.batDau).inMinutes;
  return OwnerBookingDetail(
    id: api.id,
    maDon: api.code,
    tinhTrang: tinhTrang,
    loai: api.loai,
    tenDichVu: _tenDichVu(context, api),
    pets: api.pets,
    tenNcc: api.ncc.ten,
    avatarNcc: api.ncc.avatar,
    sitterId: api.ncc.id,
    ratingNcc: api.ncc.rating,
    soDanhGiaNcc: api.ncc.soDanhGia,
    moTaThoiGian: _moTaThoiGian(context, api),
    moTaTraBe: boarding && api.ketThuc != null
        ? _ngayGio(context, api.ketThuc!)
        : null,
    soDem: boarding ? api.soDem : null,
    mocNhanBe: boarding ? api.batDau : null,
    mocTraBe: boarding ? api.ketThuc : null,
    diaDiem: boarding ? _nhaNcc(context, api) : (api.diaChi ?? ''),
    diaDiemPhu: boarding ? api.choNcc?.khuVuc : null,
    diaChiDayDu: api.choNcc?.diaChiDayDu,
    viTri: boarding ? api.choNcc?.viTri : api.viTri,
    gioNhanBe: boarding ? gioPhut(api.batDau) : null,
    gioMoChiDuong: _gioMoChiDuong(api, bayGio),
    ngayMoChiDuong: _ngayMoChiDuong(api, bayGio),
    ghiChu: api.ghiChu ?? '',
    dongTien: dongHoaDonCuaApi(context, api),
    tongTien: api.tongTien,
    goiTungBe: _goiTungBe(api),
    mocPhu: _mocPhu(l10n, api, tinhTrang, bayGio),
    gioKhoiHanh: api.xuatPhatLuc == null ? null : gioPhut(api.xuatPhatLuc!),
    gioHen: tinhTrang == TinhTrangDon.dangToi ? gioPhut(api.batDau) : null,
    phutKhoiHanhTre: _phutKhoiHanhTre(api),
    gioHienTai: tinhTrang == TinhTrangDon.quaGioHen ? gioPhut(bayGio) : null,
    phutQuaHen: tinhTrang == TinhTrangDon.quaGioHen ? phutQuaHen : null,
    gioToiNoi: api.toiNoiLuc == null ? null : gioPhut(api.toiNoiLuc!),
    phien: _phien(api, tinhTrang, bayGio),
    ketQua: api.ketQua,
    baiDanhGia: api.baiDanhGia,
    anhTruoc: api.anh.truoc,
    anhSau: api.anh.sau,
    anhNhatKy: api.anh.nhatKy,
    tongAnh: api.anh.tong,
    gioHoanThanh: api.ketThucThat == null ? null : gioPhut(api.ketThucThat!),
    ngayHoanThanh:
        api.trangThai == TrangThaiDon.hoanThanh && api.ketThucThat != null
        ? ngayThang(api.ketThucThat!)
        : null,
    gioXongDuKien: api.loai == ServiceType.grooming && api.ketThuc != null
        ? gioPhut(api.ketThuc!)
        : null,
    thongTinHuy: _thongTinHuy(context, api),
    khieuNai: api.khieuNai,
    gioGiuTien: cauHinh.gioGiuTien,
    phanTramPhiHuy: cauHinh.phiHuyMuonPhanTram,
    chinhSachHuy: (
      hanMienPhiAt: api.chinhSachHuy.hanHuyMienPhiAt,
      laDatGap: api.chinhSachHuy.laDatGap,
      hetAnHanDatGapAt: api.chinhSachHuy.hetAnHanDatGapAt,
      mienPhi: api.chinhSachHuy.mienPhi,
      coTheHuy: api.chinhSachHuy.coTheHuy,
      phiHuy: api.chinhSachHuy.phiHuyDuKien,
      tienHoan: api.chinhSachHuy.tienHoanDuKien,
    ),
  );
}

String? mocHuyCuaDon(BuildContext context, OwnerBookingDetail don) {
  final l10n = context.l10n;
  final cs = don.chinhSachHuy;
  if (cs == null || !cs.coTheHuy) return null;

  if (don.tinhTrang == TinhTrangDon.choXacNhan) {
    return l10n.huyMienPhiKhiChuaNhan;
  }

  if (don.tinhTrang == TinhTrangDon.quaGioHen && cs.mienPhi) {
    return l10n.huyMienPhiNccChuaToi;
  }

  if (cs.laDatGap) {
    final het = cs.hetAnHanDatGapAt;
    return het == null ? null : l10n.donGapHuyMienPhiToi(gioPhut(het));
  }

  final moc = cs.hanMienPhiAt;
  if (moc == null) return null;
  final gio = gioPhut(moc);
  final ngay = ngayThang(moc);
  if (cs.mienPhi) return l10n.hanHuyMienPhi(gio, ngay);
  return l10n.quaHanHuyMienPhiChiuPhi(
    gio,
    ngay,
    '${dinhDangTien(cs.phiHuy)}đ',
    '${dinhDangTien(cs.tienHoan)}đ',
  );
}

// Bốn tình trạng suy được từ mốc THẬT của đơn
TinhTrangDon _tinhTrang(ChiTietDonApi api, DateTime bayGio) {
  switch (api.trangThai) {
    case TrangThaiDon.choNhan:
      return TinhTrangDon.choXacNhan;
    case TrangThaiDon.daNhan:
      // Trông giữ đi chiều ngược, mốc tới nơi bên đó không phải của người chăm
      if (api.toiNoiLuc != null && api.loai != ServiceType.boarding) {
        return TinhTrangDon.daToiDiemHen;
      }
      if (api.xuatPhatLuc != null && api.toiNoiLuc == null) {
        return TinhTrangDon.dangToi;
      }
      final quaHen = bayGio.difference(api.batDau).inMinutes >= _phutQuaHenNcc;
      if (quaHen && api.toiNoiLuc == null && api.loai != ServiceType.boarding) {
        return TinhTrangDon.quaGioHen;
      }
      return TinhTrangDon.daXacNhan;
    case TrangThaiDon.dangChay:
    case TrangThaiDon.khieuNai:
      return TinhTrangDon.dangDienRa;
    case TrangThaiDon.choChuNuoiChot:
      return TinhTrangDon.choBanXacNhan;
    case TrangThaiDon.hoanThanh:
    case TrangThaiDon.daXuLy:
      return TinhTrangDon.hoanThanh;
    case TrangThaiDon.daHuy:
      return TinhTrangDon.daHuy;
    case TrangThaiDon.khongRo:
      return TinhTrangDon.khongRo;
  }
}

String _tenDichVu(BuildContext context, ChiTietDonApi api) {
  final l10n = context.l10n;
  final ten = serviceTypeNameDai(context, api.loai);
  final phan = switch (api.loai) {
    ServiceType.boarding =>
      (api.soDem ?? 0) == 0 ? null : l10n.soDemNhan('${api.soDem}'),
    _ =>
      (api.thoiLuongPhut ?? 0) == 0 ? null : l10n.nPhut('${api.thoiLuongPhut}'),
  };
  return phan == null ? ten : '$ten · $phan';
}

String _nhanNgay(BuildContext context, DateTime d) =>
    '${thuDaiTheoSo(context.l10n, d.weekday)}, ${ngayThang(d)}';

String _ngayGio(BuildContext context, DateTime d) =>
    '${_nhanNgay(context, d)} · ${gioPhut(d)}';

String _moTaThoiGian(BuildContext context, ChiTietDonApi api) {
  final l10n = context.l10n;
  final nhanNgay = _nhanNgay(context, api.batDau);
  final gio = gioPhut(api.batDau);
  if (api.loai == ServiceType.grooming) return l10n.ngayLucGio(nhanNgay, gio);
  if (api.loai == ServiceType.boarding || api.ketThuc == null) {
    return '$nhanNgay · $gio';
  }
  return '$nhanNgay · ${l10n.khungGio(gio, gioPhut(api.ketThuc!))}';
}

String _nhaNcc(BuildContext context, ChiTietDonApi api) {
  final l10n = context.l10n;
  final ten = l10n.nhaCuaNcc(api.ncc.ten);
  final km = api.choNcc?.km;
  return km == null ? ten : '$ten · ${l10n.cachBan(l10n.soKm(soLeKm(km)))}';
}

DateTime? _mocMoChiDuong(ChiTietDonApi api, DateTime bayGio) {
  if (api.loai != ServiceType.boarding) return null;
  final moc = api.batDau.subtract(const Duration(hours: gioMoXuatPhatTruoc));
  return bayGio.isBefore(moc) ? moc : null;
}

String? _gioMoChiDuong(ChiTietDonApi api, DateTime bayGio) {
  final moc = _mocMoChiDuong(api, bayGio);
  return moc == null ? null : gioPhut(moc);
}

String? _ngayMoChiDuong(ChiTietDonApi api, DateTime bayGio) {
  final moc = _mocMoChiDuong(api, bayGio);
  return moc == null ? null : ngayThang(moc);
}

int? _phutKhoiHanhTre(ChiTietDonApi api) {
  final di = api.xuatPhatLuc;
  if (di == null || !di.isAfter(api.batDau)) return null;
  final phut = di.difference(api.batDau).inMinutes;
  return phut > 0 ? phut : null;
}

String? _mocPhu(
  AppLocalizations l10n,
  ChiTietDonApi api,
  TinhTrangDon tinhTrang,
  DateTime bayGio,
) {
  int? conLai(DateTime? moc) {
    if (moc == null) return null;
    final phut = moc.difference(bayGio).inMinutes;
    return phut > 0 ? phut : null;
  }

  return switch (tinhTrang) {
    TinhTrangDon.choXacNhan => switch (conLai(api.hanChot)) {
      final phut? => l10n.conKhoang(dongHoConLai(l10n, phut)),
      _ => null,
    },
    TinhTrangDon.choBanXacNhan => switch (conLai(api.hanChot)) {
      final phut? => l10n.xacNhanTrongKhoang(dongHoConLai(l10n, phut)),
      _ => null,
    },
    TinhTrangDon.daToiDiemHen ||
    TinhTrangDon.daXacNhan => switch (conLai(api.batDau)) {
      final phut? => nhanToiTrong(l10n, phut),
      _ => null,
    },
    TinhTrangDon.dangDienRa => switch (conLai(api.ketThuc)) {
      final phut? => l10n.conKhoang(dongHoConLai(l10n, phut)),
      _ => null,
    },
    TinhTrangDon.quaGioHen => l10n.chuaToiNoi,
    _ => null,
  };
}

PhienDangChay? _phien(
  ChiTietDonApi api,
  TinhTrangDon tinhTrang,
  DateTime bayGio,
) {
  final phien = api.phien;
  if (tinhTrang != TinhTrangDon.dangDienRa ||
      api.batDauThat == null ||
      phien == null) {
    return null;
  }
  final con = api.ketThuc?.difference(bayGio).inMinutes ?? 0;
  return (
    gioBatDau: gioPhut(api.batDauThat!),
    kmDaDi: phien.km ?? 0,
    phutConLai: con > 0 ? con : 0,
    giayCapNhat: phien.giayMoiLuotGui ?? 0,
  );
}

List<GoiCuaBe> _goiTungBe(ChiTietDonApi api) {
  if (api.loai != ServiceType.grooming) return const [];
  return [
    for (final be in api.pets)
      if (api.goiTheoBe[be.id] case final m?) (be: be, goi: m.goi, gia: m.gia),
  ];
}

ThongTinHuy? _thongTinHuy(BuildContext context, ChiTietDonApi api) {
  final l10n = context.l10n;
  final huy = api.thongTinHuy;
  if (huy == null) return null;
  final luc = huy.luc;
  final truoc = luc == null ? 0 : api.batDau.difference(luc).inMinutes;
  return (
    ben: _benHuy(huy.ben),
    mocHuy: luc,
    gioHuy: luc == null ? '' : gioPhut(luc),
    ngayHuy: luc == null ? '' : ngayThang(luc),
    lyDo: huy.moTa?.trim().isNotEmpty == true
        ? huy.moTa!.trim()
        : nhanLyDoHuy(context, huy.lyDo).toLowerCase(),
    phiHuy: huy.phiHuy,
    truocGioHen: khoangTho(l10n, truoc),
  );
}

BenHuy _benHuy(String ma) => switch (ma) {
  'owner' => BenHuy.chuNuoi,
  'sitter' => BenHuy.nguoiCham,
  'sitterNoShow' => BenHuy.nccChuaToi,
  'systemSitterNoShow' => BenHuy.heThongNccChuaToi,
  'systemNoStart' => BenHuy.heThongKhongBatDau,
  'systemSitterBusy' => BenHuy.heThongNccBan,
  'noShow' => BenHuy.chuNuoiVangMat,
  'admin' => BenHuy.quanTri,
  _ => BenHuy.heThongHetHan,
};

List<DongHoaDon> dongHoaDonCuaApi(BuildContext context, ChiTietDonApi api) {
  final theoId = {for (final be in api.pets) be.id: be};
  return [
    for (final d in api.dongGia)
      (nhan: _nhanDongGia(context, d, theoId), tien: d.tien),
  ];
}

String _nhanDongGia(
  BuildContext context,
  DongGiaApi d,
  Map<String, Pet> theoId,
) => nhanDongGiaDon(
  context,
  key: d.key,
  tien: d.tien,
  meta: d.meta,
  be: theoId[d.petId],
);
