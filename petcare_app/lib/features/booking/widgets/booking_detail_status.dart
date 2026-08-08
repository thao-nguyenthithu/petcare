import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/widgets/booking_status_block.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';

// Khối trạng thái đổi theo tình huống, phần thanh tiến trình dùng chung
class BookingDetailStatus extends StatelessWidget {
  const BookingDetailStatus({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ten = don.tenNcc;
    final (
      IconData icon,
      String tieuDe,
      String moTa,
      Color mauMoc,
    ) = switch (don.tinhTrang) {
      TinhTrangDon.choXacNhan => (
        Icons.schedule,
        l10n.choNccXacNhan(ten),
        l10n.moTaChoNccXacNhan,
        AppColors.accent,
      ),
      TinhTrangDon.daXacNhan when don.chuNuoiPhaiDi => (
        Icons.check_circle_outline,
        l10n.nccDaNhanDon(ten),
        l10n.moTaMangBeQuaNhaNcc(ten),
        AppColors.textSecondary,
      ),
      TinhTrangDon.daXacNhan when don.loai == ServiceType.grooming => (
        Icons.check_circle_outline,
        l10n.nccSeToiNhaBan(ten),
        l10n.moTaNccMangDungCu,
        AppColors.textSecondary,
      ),
      TinhTrangDon.daXacNhan => (
        Icons.check_circle_outline,
        l10n.nccDaNhanDon(ten),
        l10n.moTaNccDaNhanDon,
        AppColors.textSecondary,
      ),
      TinhTrangDon.dangToi when don.chuNuoiPhaiDi => (
        Icons.directions_walk,
        l10n.banDangMangBeToi(ten),
        l10n.moTaBanDangMangBeToi,
        AppColors.primaryColor,
      ),
      TinhTrangDon.dangToi when don.phutKhoiHanhTre != null => (
        Icons.check_circle_outline,
        l10n.nccDangTrenDuongToi(ten),
        l10n.moTaKhoiHanhTre(
          ten,
          don.gioKhoiHanh ?? '',
          '${don.phutKhoiHanhTre}',
          don.gioHen ?? '',
        ),
        AppColors.accent,
      ),
      TinhTrangDon.dangToi => (
        Icons.check_circle_outline,
        l10n.nccDangTrenDuongToi(ten),
        l10n.moTaKhoiHanhKipGio(ten, don.gioKhoiHanh ?? '', don.gioHen ?? ''),
        AppColors.primaryColor,
      ),
      TinhTrangDon.denMuon when don.dangGiaoBe => (
        Icons.check_circle_outline,
        l10n.banDaToiNhaNcc(ten),
        l10n.moTaDaToiDangRaNhan(ten, don.gioMoBaoKhongCoNha ?? ''),
        AppColors.primaryColor,
      ),
      TinhTrangDon.denMuon => (
        Icons.check_circle_outline,
        l10n.nccBaoDenMuon(ten, '${don.phutDenMuon ?? 0}'),
        l10n.moTaNccDenMuon,
        AppColors.accent,
      ),
      TinhTrangDon.quaGioHen when don.choNhanBeQuaLau => (
        Icons.report,
        l10n.banDaToiChoQuaNPhut('${don.phutQuaHen ?? 0}'),
        l10n.moTaDaToiNccChuaNhan(don.gioToiNoi ?? ''),
        AppColors.accent,
      ),
      TinhTrangDon.quaGioHen => (
        Icons.report,
        l10n.daGioQuaGioHenNPhut('${don.phutQuaHen ?? 0}'),
        l10n.moTaNccChuaXacThucViTri(ten),
        AppColors.accent,
      ),
      TinhTrangDon.dangDienRa when don.dangDiDonBe => (
        Icons.directions_walk,
        l10n.banDangToiDonBeVe,
        l10n.moTaDangToiDon(don.gioTraBe ?? '', ten),
        AppColors.primaryColor,
      ),
      TinhTrangDon.dangDienRa when don.dangNhanBeVe => (
        Icons.check_circle_outline,
        l10n.banDaToiNhaNcc(ten),
        l10n.moTaDaToiDonBe(don.gioToiNoi ?? ''),
        AppColors.primaryColor,
      ),
      TinhTrangDon.dangDienRa when don.daChotKetThucSom => (
        Icons.home_outlined,
        l10n.cacBeDangONha(ten),
        l10n.moTaChotKetThucSom(
          don.gioChotKetThucSom ?? '',
          don.gioDonMoi ?? '',
          ten,
        ),
        AppColors.accent,
      ),
      TinhTrangDon.dangDienRa when don.chuNuoiPhaiDi => (
        Icons.home_outlined,
        l10n.cacBeDangONha(ten),
        don.laNgayCuoiKy
            ? l10n.moTaHomNayDonBe(don.gioTraBe ?? '', don.conLaiToiTra ?? '')
            : l10n.moTaTraBeConLai(
                don.ngayTraNgan ?? '',
                don.gioTraBe ?? '',
                don.conLaiToiTra ?? '',
              ),
        AppColors.primaryColor,
      ),
      TinhTrangDon.dangDienRa when don.loai == ServiceType.grooming => (
        Icons.home_outlined,
        l10n.nccDangTamTaiNhaBan(ten),
        l10n.daXacThucViTriNhaBanLuc(don.phien?.gioBatDau ?? ''),
        AppColors.accent,
      ),
      TinhTrangDon.dangDienRa => (
        Icons.earbuds,
        _viecDangDienRa(context, don.loai),
        _moTaPhien(context, don),
        AppColors.accent,
      ),
      TinhTrangDon.choBanXacNhan => (
        Icons.check_circle_outline,
        l10n.nccDaBaoHoanThanh(ten),
        l10n.moTaXemMinhChungRoiXacNhan,
        AppColors.accent,
      ),
      TinhTrangDon.hoanThanh when don.chuNuoiPhaiDi => (
        Icons.check_circle_outline,
        l10n.hoanThanhLuc(don.gioHoanThanh ?? '', don.ngayHoanThanh ?? ''),
        l10n.moTaHoanThanhTrongGiu(
          don.gioToiNoi ?? '',
          don.gioTraBe ?? '',
          ten,
          '${don.gioGiuTien}',
        ),
        AppColors.textSecondary,
      ),
      TinhTrangDon.hoanThanh => (
        Icons.check_circle_outline,
        l10n.hoanThanhLuc(don.gioHoanThanh ?? '', don.ngayHoanThanh ?? ''),
        l10n.moTaHanDanhGiaVaBaoSuCo('${don.gioGiuTien}'),
        AppColors.textSecondary,
      ),
      TinhTrangDon.daHuy => (
        Icons.cancel_outlined,
        l10n.daHuy,
        '',
        AppColors.neutral,
      ),
      TinhTrangDon.khongRo => (
        Icons.help_outline,
        l10n.trangThaiChuaDocDuoc,
        l10n.moTaTrangThaiChuaDocDuoc,
        AppColors.neutral,
      ),
    };
    return BookingStatusBlock(
      icon: icon,
      tieuDe: tieuDe,
      moTa: moTa,
      mocPhu: don.mocPhu,
      mauMocPhu: mauMoc,
      mauNhanManh: don.tinhTrang == TinhTrangDon.quaGioHen
          ? AppColors.accent
          : null,
      soBuocXong: don.soBuocXong,
      buocHienTai: don.buocHienTai,
      dangChay: don.dangChay || don.daToiNoi,
    );
  }
}

String _moTaPhien(BuildContext context, OwnerBookingDetail don) {
  final l10n = context.l10n;
  final phien = don.phien;
  final batDau = phien?.gioBatDau ?? '';
  return switch (don.loai) {
    ServiceType.walking => l10n.moTaPhienDangChay(
      batDau,
      l10n.soKm(soLeKm(phien?.kmDaDi ?? 0)),
      '${phien?.giayCapNhat ?? 0}',
    ),
    ServiceType.boarding => l10n.moTaPhienTrongGiu(batDau),
    ServiceType.grooming => l10n.moTaPhienGrooming(batDau, don.gioHen ?? ''),
  };
}

// Việc đang diễn ra, nói theo đúng dịch vụ
String _viecDangDienRa(BuildContext context, ServiceType loai) {
  final l10n = context.l10n;
  return switch (loai) {
    ServiceType.walking => l10n.dangDatDiDao,
    ServiceType.boarding => l10n.dangTrongGiu,
    ServiceType.grooming => l10n.dangTamVaCatTia,
  };
}
