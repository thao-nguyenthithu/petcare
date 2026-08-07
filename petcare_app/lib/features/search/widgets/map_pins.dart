import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/search/data/noi_tim_quanh.dart';

// Ghim chỗ đang lấy làm tâm tìm
class MapCenterPin extends StatelessWidget {
  const MapCenterPin({super.key, required this.nguon, this.moNhat = false});

  final NguonNoiTim nguon;
  final bool moNhat;

  @override
  Widget build(BuildContext context) {
    final icon = switch (nguon) {
      NguonNoiTim.diaChiLuu => Icons.home_rounded,
      NguonNoiTim.viTriHienTai => Icons.my_location_rounded,
      NguonNoiTim.ghimTrenBanDo ||
      NguonNoiTim.vungDangXem => Icons.place_rounded,
    };
    final mau = moNhat
        ? AppColors.primaryColor.withValues(alpha: 0.6)
        : AppColors.primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: mau,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 3),
            boxShadow: const [
              BoxShadow(color: AppColors.shadow, blurRadius: 6),
            ],
          ),
          child: Icon(icon, size: 18, color: AppColors.textWhite),
        ),
        Container(width: 3, height: 10, color: mau),
      ],
    );
  }
}

class MapPricePin extends StatelessWidget {
  const MapPricePin({
    super.key,
    required this.gia,
    required this.dangXem,
    required this.onTap,
  });

  final int gia;
  final bool dangXem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        color: dangXem ? AppColors.primaryColor : AppColors.surface,
        elevation: 3,
        shadowColor: AppColors.shadow,
        shape: const StadiumBorder(),
        child: Center(
          child: Text(
            '${(gia / 1000).round()}k',
            style: AppTextStyles.label.copyWith(
              color: dangXem ? AppColors.textWhite : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
