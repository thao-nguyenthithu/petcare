import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';

const double caoDongGio = 44;

class BookingTimeRow extends StatelessWidget {
  const BookingTimeRow({
    super.key,
    required this.khung,
    required this.dangChon,
    required this.onTap,
    this.chuThichPhai,
    this.thoiLuongPhut,
  });

  final KhungGio khung;
  final bool dangChon;
  final VoidCallback onTap;
  final String? chuThichPhai;
  final int? thoiLuongPhut;

  @override
  Widget build(BuildContext context) {
    final chonDuoc = khung.chonDuoc;
    return InkWell(
      onTap: chonDuoc ? onTap : null,
      child: ColoredBox(
        color: dangChon
            ? AppColors.cardMint
            : chonDuoc
            ? AppColors.surface
            : AppColors.background,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Text(
                khung.nhan,
                style: AppTextStyles.label.copyWith(
                  color: dangChon
                      ? AppColors.primaryColor
                      : chonDuoc
                      ? AppColors.textPrimary
                      : AppColors.neutral,
                ),
              ),
              const Spacer(),
              Text(
                dangChon
                    ? (chuThichPhai ?? '')
                    : chonDuoc
                    ? ''
                    : lyDoKhungGioChan(context, khung.lyDoChan!, thoiLuongPhut),
                style: AppTextStyles.captionSm.copyWith(
                  color: dangChon
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                ),
              ),
              if (dangChon) ...[
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String lyDoKhungGioChan(
  BuildContext context,
  LyDoKhungGio ly,
  int? thoiLuongPhut,
) {
  final l10n = context.l10n;
  return switch (ly) {
    LyDoKhungGio.daQua => l10n.daQuaGio,
    LyDoKhungGio.chuaDuLeadTime => l10n.canDatTruocNGio(
      '${minLeadMinutes ~/ 60}',
    ),
    LyDoKhungGio.ngoaiGioLamViec => l10n.ngoaiGioLamViec,
    LyDoKhungGio.daCoDon => l10n.daCoDonKhungNay,
    LyDoKhungGio.beDaCoDon => l10n.beDaCoDonKhungNay,
    LyDoKhungGio.khongDuThoiLuong => l10n.khongDuNPhutTrong(
      '${thoiLuongPhut ?? 0}',
    ),
  };
}
