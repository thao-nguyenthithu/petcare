import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class BankAccountCard extends StatelessWidget {
  const BankAccountCard({super.key, required this.taiKhoan, this.duoi});

  final TaiKhoanNganHang taiKhoan;
  final Widget? duoi;
  static const double _oIcon = 44;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: _oIcon,
          height: _oIcon,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.cardMint,
            borderRadius: BorderRadius.circular(AppRadius.radius14),
          ),
          child: const Icon(
            Icons.credit_card,
            color: AppColors.primaryColor,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.itemGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taiKhoan.nhan,
                style: AppTextStyles.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                taiKhoan.tenChuTaiKhoan,
                style: AppTextStyles.captionSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (duoi != null) ...[
          const SizedBox(width: AppSpacing.labelGap),
          duoi!,
        ],
      ],
    );
  }
}

// Thẻ trắng bo góc bọc một khối nội dung của cụm ví
class ViCard extends StatelessWidget {
  const ViCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );
  }
}

class ViCaption extends StatelessWidget {
  const ViCaption(this.nhan, {super.key});

  final String nhan;

  @override
  Widget build(BuildContext context) =>
      Text(nhan, style: AppTextStyles.captionSm);
}

class ViAmountHeader extends StatelessWidget {
  const ViAmountHeader({
    super.key,
    required this.nhanLoai,
    required this.soTien,
    required this.nhanTrangThai,
    required this.mau,
  });

  final String nhanLoai;
  final int soTien;
  final String nhanTrangThai;
  final Color mau;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(nhanLoai, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.labelGap),
        Text(
          '${soTien < 0 ? '−' : '+'}${dinhDangTien(soTien.abs())}đ',
          style: AppTextStyles.h1.copyWith(color: mau),
        ),
        const SizedBox(height: AppSpacing.itemGap),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.itemGap,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: mau.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            nhanTrangThai,
            style: AppTextStyles.captionSm.copyWith(color: mau),
          ),
        ),
      ],
    );
  }
}

class ViBookingRow extends StatelessWidget {
  const ViBookingRow({
    super.key,
    required this.avatar,
    required this.tieuDe,
    required this.maDon,
    required this.tenBe,
    required this.moTaMoc,
    this.duoi,
    this.onTap,
  });

  final Widget avatar;
  final String tieuDe;
  final String maDon;
  final String tenBe;
  final String moTaMoc;
  final Widget? duoi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final noiDung = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        avatar,
        const SizedBox(width: AppSpacing.itemGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      tieuDe,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.textGap),
                  Text('· #$maDon', style: AppTextStyles.captionSm),
                ],
              ),
              Text(tenBe, style: AppTextStyles.captionSm),
              Text(moTaMoc, style: AppTextStyles.captionSm),
            ],
          ),
        ),
        if (duoi != null) ...[
          const SizedBox(width: AppSpacing.labelGap),
          duoi!,
        ] else if (onTap != null)
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
      ],
    );
    if (onTap == null) return noiDung;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: noiDung,
    );
  }
}
