import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_boarding_blocks.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_step_progress.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';

// Khối trạng thái đơn, kèm mốc thời gian và hệ quả
class SitterOrderStatus extends StatelessWidget {
  const SitterOrderStatus({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (don.laTrongGiu && don.dangDat) {
      final ky = don.trongGiu;
      final ketThucSom = don.daChotKetThucSom;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BoardingStayBanner(
            soBe: don.pets.length,
            soDem: ky?.soDem ?? 0,
            demHienTai: ky?.demHienTai ?? 0,
            ketThucSom: ketThucSom,
            dongTrai: ketThucSom
                ? l10n.nhanBeLucDaChotKetThucSom(ky?.nhanBeNgan ?? '')
                : l10n.nhanBeLuc(ky?.nhanBeNgan ?? ''),
            dongPhai: ketThucSom ? null : l10n.traBeLuc(ky?.traBeNgan ?? ''),
            dongCuoi: ketThucSom || ky?.conLaiToiTra == null
                ? null
                : l10n.conLaiKhoang(ky!.conLaiToiTra!),
          ),
          const SizedBox(height: 20),
          _Stepper(don: don),
        ],
      );
    }
    final (
      IconData icon,
      String tieuDe,
      String moTa,
      Color mauMoc,
    ) = switch (don.tinhTrang) {
      TinhTrangDonNcc.choXacNhan => (
        Icons.schedule,
        l10n.choBanPhanHoi,
        l10n.moTaChoBanPhanHoi,
        AppColors.accent,
      ),
      TinhTrangDonNcc.daNhanDon when don.laTrongGiu => (
        Icons.check_circle_outline,
        l10n.banDaNhanDon,
        l10n.moTaChuNuoiSeMangBeToi('${don.pets.length}'),
        AppColors.accent,
      ),
      TinhTrangDonNcc.dangToi when don.laTrongGiu => (
        Icons.check_circle_outline,
        l10n.banDaNhanDon,
        l10n.moTaChuNuoiMangBeLuc(don.gioHen, don.ngayNganHen),
        AppColors.accent,
      ),
      TinhTrangDonNcc.quaHenNhanBe => (
        Icons.check_circle_outline,
        l10n.daGioChuNuoiChuaMangBeToi(don.gioMoBaoVangMat ?? ''),
        l10n.moTaDaGoiNhanChuNuoiHaiLan,
        AppColors.accent,
      ),
      TinhTrangDonNcc.daBaoMuon when don.laTrongGiu => (
        Icons.check_circle_outline,
        l10n.chuNuoiBaoToiMuonNPhut('${don.phutBaoMuon ?? 0}'),
        l10n.moTaChuNuoiDuKienToiTheoGps(
          don.tenChuNuoi,
          don.gioDuKienToi ?? '',
        ),
        AppColors.accent,
      ),
      TinhTrangDonNcc.hoanThanh => (
        Icons.check_circle_outline,
        l10n.hoanThanhLucTraBeTrucTiep(don.trongGiu?.gioKetThuc ?? ''),
        l10n.moTaDonDaChotVaoVi('${don.gioGiuTien}'),
        AppColors.textSecondary,
      ),
      TinhTrangDonNcc.daNhanDon => (
        Icons.check_circle_outline,
        l10n.banDaNhanDon,
        _moTaDaNhan(context, don),
        AppColors.textSecondary,
      ),
      TinhTrangDonNcc.dangToi => (
        Icons.directions_walk,
        l10n.dangTrenDuongToiDiemDon,
        _moTaDaNhan(context, don),
        AppColors.primaryColor,
      ),
      TinhTrangDonNcc.daBaoMuon => (
        Icons.directions_walk,
        l10n.banDaBaoMuonNPhut('${don.phutBaoMuon ?? 0}'),
        l10n.moTaDaBaoMuonNcc(don.gioDaBaoMuon ?? ''),
        AppColors.accent,
      ),
      TinhTrangDonNcc.daToiDiemDon => (
        Icons.check_circle_outline,
        l10n.banDaToiLuc(don.gioToiNoi ?? ''),
        don.laGrooming
            ? l10n.cachDiaChiHenDaXacThuc(
                '${don.metCachDiemDon ?? 0}',
                don.gioToiNoi ?? '',
              )
            : l10n.moTaDaBaoChuNuoiLuc(don.gioToiNoi ?? ''),
        AppColors.primaryColor,
      ),
      TinhTrangDonNcc.dangDat =>
        don.laGrooming
            ? (
                Icons.home_outlined,
                l10n.dangLamTaiNhaChuNuoi,
                l10n.moTaDangLamGrooming(
                  don.gioToiNoi ?? '',
                  don.grooming?.gioBatDauLam ?? '',
                  don.grooming?.gioDuKienXong ?? '',
                ),
                AppColors.primaryColor,
              )
            : (
                Icons.directions_walk,
                l10n.dangDatNBe('${don.pets.length}'),
                l10n.moTaDangDatGuiAnh,
                AppColors.primaryColor,
              ),
      TinhTrangDonNcc.choChuNuoiXacNhan => (
        Icons.check_circle_outline,
        l10n.banDaKetThucLuc(don.grooming?.gioKetThuc ?? ''),
        l10n.moTaChuNuoiDangXemMinhChung('${don.gioGiuTien}'),
        AppColors.accent,
      ),
      TinhTrangDonNcc.hetHanNhan ||
      TinhTrangDonNcc.banDaHuy ||
      TinhTrangDonNcc.khachHuy ||
      TinhTrangDonNcc.khachVangMat ||
      TinhTrangDonNcc.tuHuyTrungLich => (
        Icons.cancel_outlined,
        l10n.donDaHetHanNhan,
        l10n.moTaBoLoHanNhan,
        AppColors.textSecondary,
      ),
      TinhTrangDonNcc.huyBoiQuanTri => (
        Icons.cancel_outlined,
        l10n.quanTriDaHuyNhan,
        l10n.moTaQuanTriHuyNcc,
        AppColors.textSecondary,
      ),
      TinhTrangDonNcc.khongRo => (
        Icons.help_outline,
        l10n.trangThaiChuaDocDuoc,
        l10n.moTaTrangThaiChuaDocDuoc,
        AppColors.textSecondary,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: don.daBoDangDo
                  ? AppColors.textSecondary
                  : AppColors.primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(tieuDe, style: AppTextStyles.label)),
            if (don.mocPhu case final moc?) ...[
              const SizedBox(width: 10),
              Text(moc, style: AppTextStyles.label.copyWith(color: mauMoc)),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Text(moTa, style: AppTextStyles.captionSm),
        const SizedBox(height: 20),
        _Stepper(don: don),
      ],
    );
  }
}

// Tách ra vì kỳ giữ dựng thân khác mà vẫn dùng thanh này
class _Stepper extends StatelessWidget {
  const _Stepper({required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SitterStepProgress(
      nhan: [
        don.laGrooming ? l10n.buocNhanDon : l10n.buocDonToi,
        l10n.buocDaNhan,
        l10n.buocDangLam,
        don.daBoDangDo ? l10n.buocKetThuc : l10n.buocHoanThanh,
      ],
      mocXong: don.mocXong,
      mocDangO: don.mocDangO,
    );
  }
}

// Câu phụ lúc đã nhận đơn và đang trên đường
String _moTaDaNhan(BuildContext context, SitterOrderDetail don) {
  final l10n = context.l10n;
  if (!don.laGrooming) return l10n.moTaDaNhanDonNcc('$phutMoNutBatDau');
  return don.daMoDiaChi
      ? l10n.moTaCoMatDungGioTaiNhaChuNuoi('$phutMoNutBatDau')
      : l10n.moTaMangDuDungCuChoXuatPhat('$gioMoXuatPhatTruoc');
}
