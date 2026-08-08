import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/mo_chi_duong.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

class BoardingPickupBlock extends StatelessWidget {
  const BoardingPickupBlock({super.key, required this.don});

  final OwnerBookingDetail don;

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
        const SizedBox(height: 4),
        Text(
          l10n.conCachHenDon(
            l10n.soKm(soLeKm(don.kmConToiDon ?? 0)),
            '${don.phutConToiDon ?? 0}',
            don.gioTraBe ?? '',
          ),
          style: AppTextStyles.captionSm,
        ),
        const SizedBox(height: 14),
        AppButton(
          text: l10n.moLaiChiDuong,
          height: 48,
          onTap: () => moChiDuong(context, don.viTri!),
        ),
        const SizedBox(height: 10),
        Text(l10n.ghiChuGeofenceDon, style: AppTextStyles.captionSm),
      ],
    );
  }
}
