import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';

const double _caoOKhoa = 160;

// Khối Tới điểm đón, hai nấc theo mốc mở địa chỉ
class SitterOrderRouteBlock extends StatelessWidget {
  const SitterOrderRouteBlock({
    super.key,
    required this.don,
    required this.onXuatPhat,
  });

  final SitterOrderDetail don;

  // Bấm là ghi mốc lên đường rồi mở bản đồ
  final VoidCallback onXuatPhat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daMo = don.viTri != null && don.moXuatPhat;
    final nhanNut = !daMo
        ? l10n.xuatPhatMoLucNgay(
            don.gioMoXuatPhat ?? don.gioMoChiDuong ?? '',
            don.ngayMoChiDuong ?? '',
          )
        : don.daXuatPhat
        ? l10n.moLaiChiDuong
        : (don.laGrooming ? l10n.xuatPhatToiDiemHen : l10n.xuatPhatToiDiemDon);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (daMo)
          MapPreview(
            viTri: don.viTri!,
            icon: Icons.directions_outlined,
            nhan: nhanNut,
            onDoi: onXuatPhat,
          )
        else
          const _OBanDoKhoa(),
        const SizedBox(height: 16),
        Text(
          don.laGrooming ? l10n.toiNhaChuNuoi : l10n.toiDiemDon,
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                daMo ? Icons.location_on_outlined : Icons.lock_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    don.diaChiDayDu ?? don.khuVucDiemDon,
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    daMo || don.laGrooming
                        ? l10n.cachBan(l10n.soKm(soLeKm(don.kmToiDiemDon)))
                        : l10n.diaChiDayDuMoTruocGioHen('$gioMoXuatPhatTruoc'),
                    style: AppTextStyles.captionSm,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppButton(text: nhanNut, height: 50, enabled: daMo, onTap: onXuatPhat),
      ],
    );
  }
}

class _OBanDoKhoa extends StatelessWidget {
  const _OBanDoKhoa();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Container(
        height: _caoOKhoa,
        width: double.infinity,
        color: AppColors.background,
        alignment: Alignment.center,
        child: const Icon(
          Icons.map_outlined,
          size: 34,
          color: AppColors.neutral,
        ),
      ),
    );
  }
}
