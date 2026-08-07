import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';

const double _cham = 18;

// Thanh tiến trình bốn bước: đã đặt, đã nhận, đang diễn ra, hoàn thành
class BookingStepProgress extends StatelessWidget {
  const BookingStepProgress({
    super.key,
    required this.soBuocXong,
    required this.buocHienTai,
    this.dangChay = false,
  });

  final int soBuocXong;
  final BuocDon buocHienTai;
  final bool dangChay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nhan = [
      l10n.buocDaDat,
      l10n.buocDaNhan,
      l10n.buocDangDienRa,
      l10n.buocHoanThanh,
    ];
    final iHienTai = BuocDon.values.indexOf(buocHienTai);
    return Row(
      children: [
        for (var i = 0; i < nhan.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _Noi(hien: i != 0, xong: i <= soBuocXong),
                    _Cham(
                      xong: i < soBuocXong,
                      dangToi: i == iHienTai,
                      dangChay: dangChay && i == iHienTai,
                    ),
                    _Noi(hien: i != nhan.length - 1, xong: i < soBuocXong),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  nhan[i],
                  textAlign: TextAlign.center,
                  style:
                      (i == iHienTai
                              ? AppTextStyles.labelSm
                              : AppTextStyles.captionSm)
                          .copyWith(
                            color: i <= iHienTai
                                ? AppColors.primaryColor
                                : AppColors.neutral,
                          ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Noi extends StatelessWidget {
  const _Noi({required this.hien, required this.xong});

  final bool hien;
  final bool xong;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        color: !hien
            ? Colors.transparent
            : xong
            ? AppColors.primaryColor
            : AppColors.neutralLight,
      ),
    );
  }
}

class _Cham extends StatelessWidget {
  const _Cham({
    required this.xong,
    required this.dangToi,
    this.dangChay = false,
  });

  final bool xong;
  final bool dangToi;
  final bool dangChay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cham,
      height: _cham,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: xong || dangChay ? AppColors.primaryColor : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: xong || dangToi
              ? AppColors.primaryColor
              : AppColors.neutralLight,
          width: 1.5,
        ),
      ),
      child: xong
          ? const Icon(
              Icons.check_rounded,
              size: 12,
              weight: 900,
              color: AppColors.textWhite,
            )
          : null,
    );
  }
}
