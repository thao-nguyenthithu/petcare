import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_wallet.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';

const double _duongKinhAvatar = 44;

// Màn Chi tiết giao dịch của chủ nuôi
class OwnerTransactionDetailScreen extends StatelessWidget {
  const OwnerTransactionDetailScreen({super.key, required this.chiTiet});

  final ChiTietGiaoDichChuNuoi chiTiet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gd = chiTiet.giaoDich;
    final mau = gd.laTienVao ? AppColors.primaryColor : AppColors.textPrimary;

    final (nhanLoai, nhanTrangThai) = switch (gd.loai) {
      LoaiGiaoDichChuNuoi.thanhToan => (
        l10n.thanhToanDonDichVu,
        l10n.dangTamGiuChoHoanThanh,
      ),
      LoaiGiaoDichChuNuoi.hoanTien => (
        l10n.hoanTienDonHuy,
        l10n.daHoanVeNguonLuc(chiTiet.nhanTrangThai),
      ),
    };

    return AppScreen(
      header: AppScreenHeader(title: l10n.chiTietGiaoDich),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.blockGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          ViAmountHeader(
            nhanLoai: nhanLoai,
            soTien: gd.soTien,
            nhanTrangThai: nhanTrangThai,
            mau: mau,
          ),
          const SizedBox(height: AppSpacing.blockGap),
          const AppDongKe(),
          const SizedBox(height: AppSpacing.stackGap),
          if (gd.don case final don?) ...[
            ViBookingRow(
              avatar: PetAvatar(
                imageUrl: don.pets.isEmpty ? null : don.pets.first.avatar,
                name: don.pets.isEmpty ? null : don.pets.first.name,
                size: _duongKinhAvatar,
              ),
              tieuDe: don.dichVu.ten(l10n),
              maDon: don.maDon,
              tenBe: don.pets.isEmpty ? '' : don.pets.first.nhan,
              moTaMoc: '${don.tenChuNuoi} · ${gd.moTaMoc}',
              onTap: () => context.push(AppRoutes.bookingDetail, extra: don.id),
            ),
            const SizedBox(height: AppSpacing.stackGap),
          ],
          if (chiTiet.giaiThich case final giaiThich?) ...[
            ViNoteBlock(nhan: l10n.viSaoDuocHoan, noiDung: giaiThich),
            const SizedBox(height: AppSpacing.groupGap),
          ],
          ViSectionTitle(_tieuDeKhoiTien(context)),
          const SizedBox(height: AppSpacing.stackGap),
          ViMoneyRows(
            dong: _cacDong(context),
            tong: _tongCuoi(context),
            mauTong: gd.loai == LoaiGiaoDichChuNuoi.thanhToan
                ? AppColors.textPrimary
                : AppColors.primaryColor,
          ),
          const SizedBox(height: AppSpacing.groupGap),
          ViSectionTitle(l10n.dienBien),
          const SizedBox(height: AppSpacing.stackGap),
          ViTimeline(moc: chiTiet.dienBien),
          const SizedBox(height: AppSpacing.groupGap),
          ViSectionTitle(l10n.thongTinKhac),
          const SizedBox(height: AppSpacing.stackGap),
          ViInfoRows(dong: _thongTinKhac(context)),
          const SizedBox(height: AppSpacing.groupGap),
          ViSecondaryButton(
            nhan: _nhanNutDay(context),
            // TODO: nối màn khiếu nại, hỗ trợ và chính sách huỷ của chủ nuôi
            onTap: () => baoDangPhatTrien(context),
          ),
        ],
      ),
    );
  }

  String _tieuDeKhoiTien(BuildContext context) {
    final l10n = context.l10n;
    return chiTiet.giaoDich.loai == LoaiGiaoDichChuNuoi.thanhToan
        ? l10n.banDaTra
        : l10n.soTien;
  }

  List<DongHoaDon> _cacDong(BuildContext context) {
    final l10n = context.l10n;
    final tong = chiTiet.tongCuoi.tien;
    return switch (chiTiet.giaoDich.loai) {
      LoaiGiaoDichChuNuoi.thanhToan => [
        (nhan: l10n.giaDichVu, tien: tong - 20000),
        (nhan: l10n.phuPhiNgoaiGio, tien: 20000),
        (nhan: l10n.khuyenMai, tien: 0),
      ],
      LoaiGiaoDichChuNuoi.hoanTien => [
        (nhan: l10n.banDaTra, tien: tong),
        (nhan: l10n.phiHuy, tien: 0),
      ],
    };
  }

  DongHoaDon _tongCuoi(BuildContext context) {
    final l10n = context.l10n;
    final nhan = switch (chiTiet.giaoDich.loai) {
      LoaiGiaoDichChuNuoi.thanhToan => l10n.tongThanhToan,
      LoaiGiaoDichChuNuoi.hoanTien => l10n.hoanVeNganHang(_nganHang(context)),
    };
    return (nhan: nhan, tien: chiTiet.tongCuoi.tien);
  }

  String _nganHang(BuildContext context) =>
      chiTiet.giaoDich.nganHang ?? context.l10n.nguonDaThanhToan;

  List<({String nhan, String giaTri})> _thongTinKhac(BuildContext context) {
    final l10n = context.l10n;
    final gd = chiTiet.giaoDich;
    return [
      (nhan: l10n.maGiaoDich, giaTri: gd.ma),
      (nhan: l10n.nganHangDaQuet, giaTri: _nganHang(context)),
      if (gd.loai == LoaiGiaoDichChuNuoi.thanhToan)
        (nhan: l10n.nguonTien, giaTri: l10n.thanhToanQuaVnpay),
    ];
  }

  String _nhanNutDay(BuildContext context) {
    final l10n = context.l10n;
    return switch (chiTiet.giaoDich.loai) {
      LoaiGiaoDichChuNuoi.thanhToan => l10n.xemHoSoKhieuNai,
      LoaiGiaoDichChuNuoi.hoanTien => l10n.xemChinhSachHuyDon,
    };
  }
}
