import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';

const double _boGoc = 20;

// Thẻ số dư ví: nền xanh, số dư lớn, nút rút tiền trắng
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.soDu,
    required this.daNhanTrongThang,
    required this.thang,
    required this.onRutTien,
  });

  final int soDu;
  final int daNhanTrongThang;
  final int thang;
  final VoidCallback? onRutTien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chuMo = AppColors.textWhite.withValues(alpha: 0.85);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.blockGap),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(_boGoc),
      ),
      child: Stack(
        children: [
          const ViDauChanChim(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.soDuKhaDung,
                style: AppTextStyles.captionSm.copyWith(color: chuMo),
              ),
              const SizedBox(height: AppSpacing.textGap),
              Text(
                '${dinhDangTien(soDu)}đ',
                style: AppTextStyles.h1.copyWith(color: AppColors.textWhite),
              ),
              const SizedBox(height: AppSpacing.textGap),
              Text(
                l10n.daNhanTrongThang(dinhDangTien(daNhanTrongThang), '$thang'),
                style: AppTextStyles.captionSm.copyWith(color: chuMo),
              ),
              const SizedBox(height: AppSpacing.stackGap),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onRutTien,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.primaryColor,
                    disabledBackgroundColor: AppColors.textWhite.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  child: Text(l10n.rutTienVeNganHang),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
