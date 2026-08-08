import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/active_dot_icon.dart';

// Các ô lọc trên hàng chip
enum OLoc { dichVu, ngay, soBe, danhGia }

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.nhanCuaO,
    required this.oDangChon,
    required this.oDangMo,
    required this.tinCay,
    required this.nhanTinCay,
    required this.onMoO,
    required this.onDoiTinCay,
    required this.onMoSapXep,
    required this.sapXepDangBat,
  });

  static const double chieuCao = 44;

  final String Function(OLoc) nhanCuaO;
  final Set<OLoc> oDangChon;
  final OLoc? oDangMo;
  final bool tinCay;
  final String nhanTinCay;
  final ValueChanged<OLoc> onMoO;
  final ValueChanged<bool> onDoiTinCay;
  final VoidCallback onMoSapXep;
  final bool sapXepDangBat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: chieuCao,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.textGap,
                AppSpacing.screenPadding,
                AppSpacing.labelGap,
              ),
              children: [
                for (final o in OLoc.values) ...[
                  _ChipLoc(
                    nhan: nhanCuaO(o),
                    dangChon: oDangChon.contains(o),
                    dangMo: oDangMo == o,
                    onTap: () => onMoO(o),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                ],
                _ChipLoc(
                  nhan: nhanTinCay,
                  dangChon: tinCay,
                  dangMo: false,
                  kieuCuoi: tinCay ? _KieuCuoiChip.dauX : _KieuCuoiChip.trong,
                  onTap: () => onDoiTinCay(!tinCay),
                ),
              ],
            ),
          ),
          _NutSapXep(onTap: onMoSapXep, dangBat: sapXepDangBat),
        ],
      ),
    );
  }
}

enum _KieuCuoiChip { muiTen, dauX, trong }

class _ChipLoc extends StatelessWidget {
  const _ChipLoc({
    required this.nhan,
    required this.dangChon,
    required this.dangMo,
    required this.onTap,
    this.kieuCuoi = _KieuCuoiChip.muiTen,
  });

  final String nhan;
  final bool dangChon;
  final bool dangMo;
  final _KieuCuoiChip kieuCuoi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final noiBat = dangChon || dangMo;
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: StadiumBorder(
        side: BorderSide(
          color: noiBat ? AppColors.primaryColor : AppColors.neutralLight,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nhan,
                style: AppTextStyles.body.copyWith(
                  color: noiBat
                      ? AppColors.primaryColor
                      : AppColors.textPrimary,
                ),
              ),
              if (kieuCuoi != _KieuCuoiChip.trong) ...[
                const SizedBox(width: AppSpacing.textGap),
                Icon(
                  kieuCuoi == _KieuCuoiChip.dauX
                      ? Icons.close_rounded
                      : (dangMo
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded),
                  size: 18,
                  color: noiBat
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NutSapXep extends StatelessWidget {
  const _NutSapXep({required this.onTap, required this.dangBat});

  final VoidCallback onTap;
  final bool dangBat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.screenPadding),
      child: IconButton(
        onPressed: onTap,
        icon: ActiveDotIcon(icon: Icons.swap_vert_rounded, dangBat: dangBat),
      ),
    );
  }
}
