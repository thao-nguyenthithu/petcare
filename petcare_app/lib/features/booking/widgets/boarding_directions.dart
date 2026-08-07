import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Khối dưới bản đồ ở đơn trông giữ, nút chỉ đường ăn thẳng sang Google Maps
class BoardingDirections extends StatelessWidget {
  const BoardingDirections({
    super.key,
    required this.don,
    required this.onXuatPhat,
  });

  final OwnerBookingDetail don;
  final VoidCallback onXuatPhat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diaChi = don.chiDuongDaMo
        ? (don.diaChiDayDu ?? don.diaDiemPhu)
        : don.diaDiemPhu;
    final dangDi = don.tinhTrang == TinhTrangDon.dangToi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(don.diaDiem, style: AppTextStyles.label),
        if (diaChi != null) ...[
          const SizedBox(height: 4),
          Text(diaChi, style: AppTextStyles.captionSm),
        ],
        if (don.gioNhanBe case final gio?) ...[
          const SizedBox(height: 6),
          Text(
            l10n.gioHenNhanBeLuc(gio),
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ],
        const SizedBox(height: 14),
        AppButton(
          text: !don.chiDuongDaMo
              ? l10n.moLucNgay(
                  don.gioMoChiDuong ?? '',
                  don.ngayMoChiDuong ?? '',
                )
              : dangDi
              ? l10n.xemDuongDi
              : l10n.xuatPhatMangBeToi,
          outlined: dangDi || !don.chiDuongDaMo,
          height: 48,
          mauChu: dangDi ? AppColors.primaryColor : null,
          enabled: don.chiDuongDaMo && don.viTri != null,
          onTap: onXuatPhat,
        ),
      ],
    );
  }
}
