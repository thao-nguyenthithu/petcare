import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';

// Thứ tự chip theo vòng đời đơn, null là không lọc
const List<SitterBookingStatus?> _thuTuChip = [
  null,
  SitterBookingStatus.choXacNhan,
  SitterBookingStatus.daXacNhan,
  SitterBookingStatus.dangDienRa,
  SitterBookingStatus.choChuNuoiXacNhan,
  SitterBookingStatus.khieuNai,
  SitterBookingStatus.daHuy,
  SitterBookingStatus.hoanThanh,
];

const double _caoHang = 56;

// Hàng chip lọc trạng thái, việc cần xử lý gấp có thêm số đếm
class SitterBookingStatusChips extends StatelessWidget {
  const SitterBookingStatusChips({
    super.key,
    required this.dangChon,
    required this.dem,
    required this.onChon,
  });

  final SitterBookingStatus? dangChon;

  // Số đơn mỗi trạng thái, chỉ dùng cho chip có đếm
  final Map<SitterBookingStatus, int> dem;

  final ValueChanged<SitterBookingStatus?> onChon;

  // Chỉ hai mốc này phải xử lý trong hạn nên mới hiện số
  static const Set<SitterBookingStatus> _coDem = {
    SitterBookingStatus.choXacNhan,
    SitterBookingStatus.khieuNai,
  };

  String _nhan(BuildContext context, SitterBookingStatus? tt) {
    final l10n = context.l10n;
    return switch (tt) {
      null => l10n.tatCa,
      SitterBookingStatus.choXacNhan => l10n.trangThaiChoXacNhan,
      SitterBookingStatus.daXacNhan => l10n.sapToi,
      SitterBookingStatus.dangDienRa => l10n.dangChay,
      SitterBookingStatus.choChuNuoiXacNhan => l10n.choChot,
      SitterBookingStatus.khieuNai => l10n.khieuNai,
      SitterBookingStatus.daHuy => l10n.daHuy,
      SitterBookingStatus.hoanThanh => l10n.hoanThanh,
      SitterBookingStatus.khongRo => l10n.trangThaiChuaDocDuoc,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _caoHang,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.itemGap,
        ),
        itemCount: _thuTuChip.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (context, i) {
          final tt = _thuTuChip[i];
          final so = tt != null && _coDem.contains(tt) ? (dem[tt] ?? 0) : 0;
          return _ChipTrangThai(
            nhan: _nhan(context, tt),
            chon: tt == dangChon,
            dem: so,
            onTap: () => onChon(tt),
          );
        },
      ),
    );
  }
}

class _ChipTrangThai extends StatelessWidget {
  const _ChipTrangThai({
    required this.nhan,
    required this.chon,
    required this.dem,
    required this.onTap,
  });

  final String nhan;
  final bool chon;
  final int dem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mauChu = chon ? AppColors.textWhite : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: chon ? AppColors.primaryColor : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: chon ? AppColors.primaryColor : AppColors.neutralLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nhan, style: AppTextStyles.label.copyWith(color: mauChu)),
            if (dem > 0) ...[
              const SizedBox(width: AppSpacing.textGap),
              _ODem(so: dem, tren: chon),
            ],
          ],
        ),
      ),
    );
  }
}

// Chip đang chọn đổi nền trắng mờ cho khỏi chọi nền xanh
class _ODem extends StatelessWidget {
  const _ODem({required this.so, required this.tren});

  final int so;
  final bool tren;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: tren
            ? AppColors.textWhite.withValues(alpha: 0.24)
            : AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$so',
        style: AppTextStyles.captionSm.copyWith(
          color: tren ? AppColors.textWhite : AppColors.accent,
        ),
      ),
    );
  }
}
