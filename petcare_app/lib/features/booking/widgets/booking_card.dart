import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/booking_card_layout.dart';

// Nhãn trạng thái đơn nhìn từ chủ nuôi, cùng bảng màu với nhãn bên người chăm
class OwnerBookingStatusBadge extends StatelessWidget {
  const OwnerBookingStatusBadge({super.key, required this.booking});

  final OwnerBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final b = booking;

    final (nen, chu) = switch (b.trangThai) {
      TrangThaiDon.dangChay => (AppColors.primaryColor, AppColors.textWhite),
      TrangThaiDon.choChuNuoiChot => (
        AppColors.primaryColor.withValues(alpha: 0.12),
        AppColors.primaryColor,
      ),
      TrangThaiDon.daNhan => (
        AppColors.accent.withValues(alpha: 0.12),
        AppColors.accent,
      ),
      TrangThaiDon.khieuNai => (
        AppColors.error.withValues(alpha: 0.12),
        AppColors.error,
      ),
      TrangThaiDon.choNhan ||
      TrangThaiDon.hoanThanh ||
      TrangThaiDon.daXuLy ||
      TrangThaiDon.khongRo ||
      TrangThaiDon.daHuy => (AppColors.neutralLight, AppColors.textSecondary),
    };

    final con = b.remainingMinutes;
    final demNguoc =
        (con ?? 0) > 0 &&
        switch (b.trangThai) {
          TrangThaiDon.choNhan ||
          TrangThaiDon.choChuNuoiChot ||
          TrangThaiDon.dangChay => true,
          TrangThaiDon.daNhan => b.sapToiGan,
          _ => false,
        };

    final nhan = switch (b.trangThai) {
      TrangThaiDon.choNhan when demNguoc => l10n.conKhoangXacNhan(
        dongHoConLai(l10n, con!),
      ),
      TrangThaiDon.daNhan when demNguoc => nhanToiTrong(l10n, con!),
      TrangThaiDon.choChuNuoiChot when demNguoc => l10n.xacNhanTrongKhoang(
        dongHoConLai(l10n, con!),
      ),
      TrangThaiDon.dangChay when demNguoc => l10n.conKhoang(
        dongHoConLai(l10n, con!),
      ),
      TrangThaiDon.choNhan => l10n.trangThaiChoXacNhan,
      TrangThaiDon.daNhan => l10n.sapToi,
      TrangThaiDon.dangChay => l10n.dangDienRa,
      TrangThaiDon.choChuNuoiChot => l10n.choBanChot,
      TrangThaiDon.khieuNai => l10n.dangKhieuNai,
      TrangThaiDon.hoanThanh => l10n.hoanThanh,
      TrangThaiDon.daXuLy => l10n.daXuLy,
      TrangThaiDon.daHuy => l10n.daHuy,
      TrangThaiDon.khongRo => l10n.trangThaiChuaDocDuoc,
    };

    return AppStatusBadge(
      label: nhan,
      background: nen,
      textColor: chu,
      leading: demNguoc ? Icon(Icons.schedule, size: 11, color: chu) : null,
    );
  }
}

class OwnerBookingCard extends StatelessWidget {
  const OwnerBookingCard({super.key, required this.booking, this.onTap});

  final OwnerBooking booking;
  final VoidCallback? onTap;

  Color get _mauTien => booking.trangThai == TrangThaiDon.daHuy
      ? AppColors.textSecondary
      : AppColors.accent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final b = booking;

    return BookingCardLayout(
      tenDoiTac: b.providerName,
      anhDoiTac: b.providerAvatar,
      badge: OwnerBookingStatusBadge(booking: b),
      dichVu: b.loaiDichVu,
      thoiLuong: b.nhanThoiLuong(l10n),
      dongThoiGian: b.nhanThoiGian(l10n),
      maDon: b.code,
      pets: b.pets,
      dongBe: b.nhanCacBeVaGhiChu(l10n),
      tien: '${dinhDangTien(b.price)}đ',
      mauTien: _mauTien,
      onTap: onTap ?? () => context.push(AppRoutes.bookingDetail, extra: b.id),
    );
  }
}
