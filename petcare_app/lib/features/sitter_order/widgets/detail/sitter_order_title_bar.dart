import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Hàng trên cùng: back, mã đơn kèm số bé và chip tình trạng
class SitterOrderTitleBar extends StatelessWidget {
  const SitterOrderTitleBar({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mau = switch (don.tinhTrang) {
      TinhTrangDonNcc.choXacNhan ||
      TinhTrangDonNcc.choChuNuoiXacNhan => AppColors.accent,
      TinhTrangDonNcc.quaHenNhanBe => AppColors.accent,
      TinhTrangDonNcc.daBaoMuon when don.laTrongGiu => AppColors.accent,
      TinhTrangDonNcc.dangDat when don.daChotKetThucSom => AppColors.accent,
      TinhTrangDonNcc.hetHanNhan ||
      TinhTrangDonNcc.banDaHuy ||
      TinhTrangDonNcc.khachHuy ||
      TinhTrangDonNcc.khachVangMat ||
      TinhTrangDonNcc.tuHuyTrungLich ||
      TinhTrangDonNcc.hoanThanh => AppColors.textSecondary,
      _ => AppColors.primaryColor,
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
                    Text(
                      l10n.maDonSoBe(don.maDon, '${don.pets.length}'),
                      style: AppTextStyles.captionSm,
                    ),
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

String _nhanTinhTrang(BuildContext context, SitterOrderDetail don) {
  final l10n = context.l10n;
  return switch (don.tinhTrang) {
    TinhTrangDonNcc.choXacNhan => l10n.trangThaiChoXacNhan,
    TinhTrangDonNcc.daNhanDon => l10n.daNhanDonNhan,
    TinhTrangDonNcc.dangToi when don.laTrongGiu => l10n.chuDangDemBeToi,
    TinhTrangDonNcc.daBaoMuon when don.laTrongGiu => l10n.chuNuoiToiMuon,
    TinhTrangDonNcc.quaHenNhanBe => l10n.chuNuoiChuaToi,
    TinhTrangDonNcc.dangToi || TinhTrangDonNcc.daBaoMuon => l10n.dangToiNhan,
    TinhTrangDonNcc.daToiDiemDon => l10n.daToiDiemDonNhan,
    TinhTrangDonNcc.dangDat when don.daChotKetThucSom => l10n.seKetThucSom,
    TinhTrangDonNcc.dangDat => l10n.dangDienRa,
    TinhTrangDonNcc.choChuNuoiXacNhan => l10n.choChuNuoiXacNhan,
    TinhTrangDonNcc.hoanThanh => l10n.hoanThanh,
    TinhTrangDonNcc.hetHanNhan => l10n.daHetHanNhan,
    TinhTrangDonNcc.banDaHuy => l10n.banDaHuyNhan,
    TinhTrangDonNcc.khachHuy => l10n.chuNuoiHuyNhan,
    TinhTrangDonNcc.khachVangMat => l10n.chuNuoiVangMatNhan,
    TinhTrangDonNcc.tuHuyTrungLich => l10n.trungLichNhan,
    TinhTrangDonNcc.huyBoiQuanTri => l10n.quanTriDaHuyNhan,
    TinhTrangDonNcc.khongRo => l10n.trangThaiChuaDocDuoc,
  };
}
