import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/confirm_detail_rows.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';

// Dải số liệu đầu màn và các hàng của mục Thông tin đơn
List<SoLieuPhien> soLieuDonNcc(BuildContext context, SitterOrderDetail don) {
  final l10n = context.l10n;
  if (don.laTrongGiu) {
    final ky = don.trongGiu;
    final soDem = ky?.soDem ?? 0;
    if (don.daHoanThanh) {
      final cat = ky?.ketThucSom;
      return [
        (
          so: l10n.soDemNhan('$soDem'),
          nhan: cat == null
              ? l10n.kyGiuNhan
              : l10n.kyGiuTrenTong('$soDem', '${cat.soDemGoc}'),
        ),
        (so: l10n.soBe('${don.pets.length}'), nhan: l10n.daTraNhan),
        (so: l10n.nAnh('${don.tongAnhNhatKy}'), nhan: l10n.daGui),
      ];
    }
    return [
      (so: don.gioHen, nhan: l10n.nhanBeNgay(don.ngayNganHen)),
      (so: l10n.soDemNhan('$soDem'), nhan: l10n.kyGiuNhan),
      (so: '${dinhDangTien(don.thucNhan)}đ', nhan: l10n.thucNhan),
    ];
  }
  // Grooming không có quãng đường, chỉ nói mốc dự kiến xong
  if (don.laGrooming && (don.dangDat || don.choChot)) {
    final g = don.grooming;
    final phut = g?.phutDaLam ?? 0;
    return [
      if (don.choChot)
        (so: _docGioPhut(context, phut), nhan: l10n.thoiLuong)
      else
        (so: l10n.nPhut('$phut'), nhan: l10n.duKienGio(g?.gioDuKienXong ?? '')),
      (
        so: l10n.soBe('${don.pets.length}'),
        nhan: don.choChot ? l10n.daLamNhan : l10n.dangLam,
      ),
      (so: l10n.nAnh('${don.tongAnhTruoc + don.tongAnhSau}'), nhan: l10n.daGui),
    ];
  }
  if (don.ketQua case final kq?) {
    return [
      (so: l10n.nPhut('${kq.phut}'), nhan: l10n.thoiLuong),
      (so: l10n.soKm(soLeKm(kq.km ?? 0)), nhan: l10n.quangDuong),
      (so: l10n.nAnh('${kq.soAnh}'), nhan: l10n.daGui),
    ];
  }
  // Phiên đang chạy thì ba cột là thời gian, đường và tiền
  if (don.dangDat) {
    return [
      (so: l10n.conNPhut('${don.phutConLai ?? 0}'), nhan: l10n.conLaiNhan),
      (so: l10n.soKm(soLeKm(don.kmDaDi ?? 0)), nhan: l10n.daDi),
      (so: '${dinhDangTien(don.thucNhan)}đ', nhan: l10n.thucNhan),
    ];
  }
  return [
    (
      so: don.gioHen,
      nhan: don.daNhanDon
          ? l10n.batDauVaoNgay(don.ngayNganHen)
          : l10n.gioHenNgay(don.ngayNganHen),
    ),
    (so: l10n.soKm(soLeKm(don.kmToiDiemDon)), nhan: l10n.cachBanNhan),
    (so: '${dinhDangTien(don.thucNhan)}đ', nhan: l10n.thucNhan),
  ];
}

String _docGioPhut(BuildContext context, int phut) {
  final l10n = context.l10n;
  if (phut < 60) return l10n.nPhut('$phut');
  final le = phut % 60;
  return le == 0
      ? l10n.nGio('${phut ~/ 60}')
      : l10n.nGioNPhut('${phut ~/ 60}', le.toString().padLeft(2, '0'));
}

List<DongChiTiet> dongThongTinDonNcc(
  BuildContext context,
  SitterOrderDetail don,
) {
  final l10n = context.l10n;
  if (don.trongGiu case final ky?) {
    return [
      (
        icon: Icons.calendar_today_outlined,
        nhan: l10n.nhanBe,
        giaTri: [ky.moTaNhanBe],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
      (
        icon: Icons.event_available_outlined,
        nhan: l10n.traBe,
        giaTri: [ky.moTaTraBe],
        phu: ky.ketThucSom == null
            ? null
            : l10n.lichTraGoc(ky.ketThucSom!.moTaTraGoc),
        onSua: null,
        duoiXanh: l10n.soDemNhan('${ky.soDem}'),
      ),
      (
        icon: Icons.location_on_outlined,
        nhan: l10n.trongTai,
        giaTri: [l10n.nhaBanChuNuoiDemBeToi, don.khuVucDiemDon],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
      (
        icon: Icons.notes_rounded,
        nhan: l10n.ghiChuCuaDon,
        giaTri: [don.ghiChu.isEmpty ? l10n.khongCoNoiDung : don.ghiChu],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
    ];
  }
  return [
    if (!don.dangDat || don.laGrooming)
      (
        icon: Icons.calendar_today_outlined,
        nhan: l10n.thoiGian,
        giaTri: [
          don.moTaThoiGian,
          if (don.grooming?.gioDuKienXong case final gio?)
            l10n.duKienXongKhoang(gio),
          if (don.grooming?.gioKetThuc case final gio?)
            l10n.hoanThanhLucGio(gio),
        ],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
    if (!don.coKhoiDuongDi && (!don.dangDat || don.laGrooming))
      (
        icon: Icons.location_on_outlined,
        nhan: don.laGrooming ? l10n.lamTai : l10n.diemDon,
        giaTri: [
          l10n.cachBan(l10n.soKm(soLeKm(don.kmToiDiemDon))),
          // Báo xong thì đóng số nhà, chỉ giữ khu vực
          don.choChot
              ? don.khuVucDiemDon
              : (don.diaChiDayDu ?? don.khuVucDiemDon),
        ],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
    (
      icon: Icons.notes_rounded,
      nhan: l10n.ghiChuCuaDon,
      giaTri: [don.ghiChu.isEmpty ? l10n.khongCoNoiDung : don.ghiChu],
      phu: null,
      onSua: null,
      duoiXanh: null,
    ),
  ];
}
