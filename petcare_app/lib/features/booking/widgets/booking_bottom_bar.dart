import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Thanh dưới các trang đặt lịch
class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    super.key,
    required this.tongTien,
    required this.onTiepTuc,
    required this.choPhep,
    this.nhan,
    this.moTa,
    this.nhanNut,
  });

  final int? tongTien;
  final VoidCallback onTiepTuc;
  final bool choPhep;
  final String? nhan;
  final String? moTa;
  final String? nhanNut;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nhan ?? l10n.tamTinh,
                style: nhan == null
                    ? AppTextStyles.captionSm
                    : AppTextStyles.label,
              ),
              if (moTa != null) ...[
                const SizedBox(height: 2),
                Text(moTa!, style: AppTextStyles.captionSm),
              ],
              const SizedBox(height: 2),
              Text(
                tongTien == null ? '—' : '${dinhDangTien(tongTien!)}đ',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: nhanNut ?? l10n.tiepTuc,
                enabled: choPhep,
                onTap: onTiepTuc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
