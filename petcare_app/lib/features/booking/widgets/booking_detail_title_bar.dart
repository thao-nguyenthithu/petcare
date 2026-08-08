import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Hàng trên cùng: back, mã đơn và chip tình trạng
class BookingDetailTitleBar extends StatelessWidget {
  const BookingDetailTitleBar({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mau = switch (don.tinhTrang) {
      TinhTrangDon.dangDienRa when don.daChotKetThucSom => AppColors.accent,
      TinhTrangDon.denMuon when don.dangGiaoBe => AppColors.primaryColor,
      TinhTrangDon.daXacNhan ||
      TinhTrangDon.dangToi ||
      TinhTrangDon.dangDienRa => AppColors.primaryColor,
      TinhTrangDon.hoanThanh || TinhTrangDon.daHuy => AppColors.neutral,
      _ => AppColors.accent,
    };
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
          child: Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.chiTietDon, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(don.maDon, style: AppTextStyles.captionSm),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: mau, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                _nhanTinhTrang(context, don),
                style: AppTextStyles.label.copyWith(color: mau),
              ),
            ],
          ),
        ),
        const AppDongKe(),
      ],
    );
  }
}

String _nhanTinhTrang(BuildContext context, OwnerBookingDetail don) {
  final l10n = context.l10n;
  return switch (don.tinhTrang) {
    TinhTrangDon.choXacNhan => l10n.trangThaiChoXacNhan,
    TinhTrangDon.daXacNhan => l10n.daXacNhan,
    TinhTrangDon.dangToi when don.chuNuoiPhaiDi => l10n.dangMangBeToi,
    TinhTrangDon.dangToi => l10n.nguoiChamDenMuon,
    TinhTrangDon.denMuon when don.dangGiaoBe => l10n.dangGiaoBe,
    TinhTrangDon.denMuon => l10n.nguoiChamDenMuon,
    TinhTrangDon.dangDienRa when don.dangDiDonBe => l10n.dangDonBeVeNhan,
    TinhTrangDon.dangDienRa when don.dangNhanBeVe => l10n.dangNhanBeVeNhan,
    TinhTrangDon.dangDienRa when don.daChotKetThucSom => l10n.ketThucSomNhan,
    TinhTrangDon.quaGioHen => l10n.quaGioHen,
    TinhTrangDon.dangDienRa => l10n.dangDienRaNhan,
    TinhTrangDon.choBanXacNhan => l10n.choBanXacNhan,
    TinhTrangDon.hoanThanh => l10n.hoanThanhNhan,
    TinhTrangDon.daHuy => l10n.daHuy,
    TinhTrangDon.khongRo => l10n.trangThaiChuaDocDuoc,
  };
}
