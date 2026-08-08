import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/booking_card_layout.dart';

// Mở chi tiết đơn theo id
void moChiTietDonNcc(BuildContext context, SitterBooking don) {
  context.push(AppRoutes.sitterOrderDetailPath(don.id));
}

// Nhãn trạng thái đơn NCC
class SitterBookingStatusBadge extends StatelessWidget {
  const SitterBookingStatusBadge({super.key, required this.booking});

  final SitterBooking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final con = booking.phutConLai;
    final demNguoc = con != null && con > 0;

    // Màu đi theo mức độ nóng của việc, các trạng thái đã khép thì xám
    final (nen, chu) = switch (booking.trangThai) {
      SitterBookingStatus.dangDienRa => (
        AppColors.primaryColor,
        AppColors.textWhite,
      ),
      SitterBookingStatus.choChuNuoiXacNhan => (
        AppColors.primaryColor.withValues(alpha: 0.12),
        AppColors.primaryColor,
      ),
      SitterBookingStatus.daXacNhan => (
        AppColors.accent.withValues(alpha: 0.12),
        AppColors.accent,
      ),
      SitterBookingStatus.khieuNai => (
        AppColors.error.withValues(alpha: 0.12),
        AppColors.error,
      ),
      SitterBookingStatus.choXacNhan ||
      SitterBookingStatus.hoanThanh ||
      SitterBookingStatus.daHuy ||
      SitterBookingStatus.khongRo => (
        AppColors.neutralLight,
        AppColors.textSecondary,
      ),
    };

    final nhan = switch (booking.trangThai) {
      SitterBookingStatus.choXacNhan when demNguoc => l10n.conKhoangXacNhan(
        dongHoConLai(l10n, con),
      ),
      SitterBookingStatus.choChuNuoiXacNhan when demNguoc => l10n.choChotKhoang(
        dongHoConLai(l10n, con),
      ),
      SitterBookingStatus.dangDienRa when demNguoc => l10n.conKhoang(
        dongHoConLai(l10n, con),
      ),
      SitterBookingStatus.choXacNhan => l10n.trangThaiChoXacNhan,
      SitterBookingStatus.daXacNhan => l10n.sapToi,
      SitterBookingStatus.dangDienRa => l10n.dangChay,
      SitterBookingStatus.choChuNuoiXacNhan => l10n.choChot,
      SitterBookingStatus.khieuNai => l10n.dangKhieuNai,
      SitterBookingStatus.hoanThanh => l10n.hoanThanh,
      SitterBookingStatus.daHuy => l10n.daHuy,
      SitterBookingStatus.khongRo => l10n.trangThaiChuaDocDuoc,
    };

    return AppStatusBadge(
      label: nhan,
      background: nen,
      textColor: chu,
      leading: demNguoc ? Icon(Icons.schedule, size: 11, color: chu) : null,
    );
  }
}

class SitterBookingCard extends StatelessWidget {
  const SitterBookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.thoiGianGhiDe,
    this.hienNhanTrangThai = true,
    this.tienGhiDe,
    this.mauTienGhiDe,
    this.ghiChuGhiDe,
  });

  final SitterBooking booking;
  final VoidCallback? onTap;
  final String? thoiGianGhiDe;
  final bool hienNhanTrangThai;
  final String? tienGhiDe;
  final Color? mauTienGhiDe;
  final String? ghiChuGhiDe;

  Color get _mauTien {
    if (booking.soTien == 0) return AppColors.textSecondary;
    return switch (booking.trangThai) {
      SitterBookingStatus.khieuNai => AppColors.textSecondary,
      SitterBookingStatus.hoanThanh ||
      SitterBookingStatus.daHuy => AppColors.primaryColor,
      SitterBookingStatus.choXacNhan => AppColors.textPrimary,
      _ => AppColors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final b = booking;

    return BookingCardLayout(
      tenDoiTac: b.tenChuNuoi,
      anhDoiTac: b.anhChuNuoi,
      badge: hienNhanTrangThai ? SitterBookingStatusBadge(booking: b) : null,
      dichVu: b.dichVu,
      thoiLuong: b.nhanThoiLuong(l10n),
      dongThoiGian: thoiGianGhiDe ?? b.nhanThoiGian(l10n),
      maDon: b.maDon,
      pets: b.pets,
      dongBe: ghiChuGhiDe == null
          ? b.nhanCacBeVaGhiChu(l10n)
          : '${b.nhanCacBe(l10n)} · $ghiChuGhiDe',
      tien: tienGhiDe ?? '${b.thucNhan ? '+' : ''}${dinhDangTien(b.soTien)}đ',
      mauTien: mauTienGhiDe ?? _mauTien,
      onTap: onTap,
    );
  }
}
