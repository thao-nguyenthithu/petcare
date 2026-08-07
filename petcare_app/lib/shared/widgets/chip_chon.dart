import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Chip pill chọn một giá trị, padding và màu khác nhau thì truyền tham số
class ChipChon extends StatelessWidget {
  const ChipChon({
    super.key,
    required this.nhan,
    required this.chon,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    this.canGiua = false,
    this.mauNenChon = AppColors.primaryColor,
    this.mauChuChon = AppColors.textWhite,
    this.mauChuThuong = AppColors.textPrimary,
  });

  final String nhan;
  final bool chon;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  // Căn giữa nội dung khi chip bị ép cao theo hàng chứa nó
  final bool canGiua;
  final Color mauNenChon;
  final Color mauChuChon;
  final Color mauChuThuong;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        alignment: canGiua ? Alignment.center : null,
        padding: padding,
        decoration: BoxDecoration(
          color: chon ? mauNenChon : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: chon ? AppColors.primaryColor : AppColors.neutralLight,
          ),
        ),
        child: Text(
          nhan,
          style: AppTextStyles.label.copyWith(
            color: chon ? mauChuChon : mauChuThuong,
          ),
        ),
      ),
    );
  }
}
