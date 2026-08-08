import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';

class EarlyEndOrderCard extends StatelessWidget {
  const EarlyEndOrderCard({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutralLight),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        children: [
          PetAvatarStack(
            pets: [
              for (final p in don.pets)
                PetBrief(name: p.name, species: '', avatar: p.avatar),
            ],
            size: 40,
            toiDa: 3,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.trongGiu} · ${l10n.soBe('${don.pets.length}')}',
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.nhanTraTenGon(
                    don.moTaThoiGian,
                    don.moTaTraBe ?? '',
                    don.tenNcc,
                  ),
                  style: AppTextStyles.captionSm,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Một ô ngày trong dải tuần
class EarlyEndDayCell extends StatelessWidget {
  const EarlyEndDayCell({
    super.key,
    required this.ngay,
    required this.homNay,
    required this.ngayTraGoc,
    required this.chon,
    required this.onChon,
  });

  final DateTime ngay;
  final DateTime homNay;
  final DateTime ngayTraGoc;
  final DateTime? chon;
  final void Function(DateTime ngay) onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final laGoc = cungNgay(ngay, ngayTraGoc);
    final laHomNay = cungNgay(ngay, homNay);
    final dangChon = chon != null && cungNgay(ngay, chon!);
    final ngoaiKy = ngay.isAfter(ngayTraGoc);
    final Color nen = dangChon
        ? AppColors.primaryColor
        : laGoc
        ? AppColors.accent
        : Colors.transparent;
    final Color chu = dangChon || laGoc
        ? AppColors.textWhite
        : ngoaiKy
        ? AppColors.neutral
        : AppColors.textPrimary;
    return Column(
      children: [
        Text(
          thuNgan(l10n, ngay),
          style: AppTextStyles.captionSm.copyWith(
            color: ngoaiKy ? AppColors.neutral : null,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: ngoaiKy ? null : () => onChon(ngay),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: nen,
              shape: BoxShape.circle,
              border: laHomNay && !dangChon
                  ? Border.all(color: AppColors.primaryColor, width: 1.5)
                  : null,
            ),
            child: Text(
              ngay.day.toString().padLeft(2, '0'),
              style: AppTextStyles.label.copyWith(color: chu),
            ),
          ),
        ),
      ],
    );
  }
}

class EarlyEndLegend extends StatelessWidget {
  const EarlyEndLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muc = [
      (l10n.homNay, AppColors.primaryColor, false),
      (l10n.dangChonNhan, AppColors.primaryColor, true),
      (l10n.ngayTraGocNhan, AppColors.accent, true),
      (l10n.ngoaiKyNhan, AppColors.neutral, true),
    ];
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        for (final (nhan, mau, dac) in muc)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: dac ? mau : Colors.transparent,
                  shape: BoxShape.circle,
                  border: dac ? null : Border.all(color: mau, width: 1.5),
                ),
              ),
              const SizedBox(width: 5),
              Text(nhan, style: AppTextStyles.captionSm),
            ],
          ),
      ],
    );
  }
}

class EarlyEndMoneyRow extends StatelessWidget {
  const EarlyEndMoneyRow({
    super.key,
    required this.nhan,
    required this.congThuc,
    required this.tien,
  });

  final String nhan;
  final String? congThuc;
  final String tien;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nhan, style: AppTextStyles.label),
              if (congThuc case final ct?) ...[
                const SizedBox(height: 2),
                Text(ct, style: AppTextStyles.captionSm),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(tien, style: AppTextStyles.label),
      ],
    );
  }
}
