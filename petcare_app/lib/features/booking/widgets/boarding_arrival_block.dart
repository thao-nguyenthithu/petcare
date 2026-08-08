import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';

// Khối khi chủ nuôi đã tới nhà người chăm, thay cho bản đồ chỉ đường
class BoardingArrivalBlock extends StatelessWidget {
  const BoardingArrivalBlock({
    super.key,
    required this.don,
    this.cuoiKy = false,
  });

  final OwnerBookingDetail don;
  final bool cuoiKy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diaChi = don.diaChiDayDu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          diaChi == null
              ? l10n.nhaCuaNcc(don.tenNcc)
              : '${l10n.nhaCuaNcc(don.tenNcc)} · $diaChi',
          style: AppTextStyles.label,
        ),
        if (don.gioToiNoi case final gioToi?) ...[
          const SizedBox(height: 4),
          Text(
            cuoiKy
                ? l10n.daToiLucHenDon(gioToi, don.gioTraBe ?? '')
                : l10n.daToiLucGioHen(gioToi, don.gioNhanBe ?? ''),
            style: AppTextStyles.captionSm,
          ),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardMint,
            borderRadius: BorderRadius.circular(AppRadius.radius14),
          ),
          child: Text(
            cuoiKy
                ? l10n.nccDangDatCacBeRa(don.tenNcc)
                : l10n.nccDangRaNhanBe(don.tenNcc),
            style: AppTextStyles.label.copyWith(color: AppColors.primaryColor),
          ),
        ),
        if (cuoiKy) ...[
          const SizedBox(height: 10),
          Text(
            l10n.moTaDaToiDonBe(don.gioToiNoi ?? ''),
            style: AppTextStyles.captionSm,
          ),
        ],
      ],
    );
  }
}
