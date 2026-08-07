import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _duongKinhAvatarBe = 26;

// Không có khoản treo thì màn bỏ hẳn khối này
class WalletHoldingBlock extends StatelessWidget {
  const WalletHoldingBlock({
    super.key,
    required this.khoan,
    required this.onXemTatCa,
  });

  final List<KhoanGiuTam> khoan;
  final VoidCallback onXemTatCa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tong = khoan.fold(0, (t, k) => t + k.soTien);
    final soKhieuNai = khoan.where((k) => k.dangKhieuNai).length;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(color: AppColors.neutralLight),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onXemTatCa,
              child: Container(
                color: AppColors.honey.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppSpacing.itemGap,
                ),
                child: Row(
                  children: [
                    const _ChamCanhBao(),
                    const SizedBox(width: AppSpacing.itemGap),
                    Expanded(
                      child: Text(
                        soKhieuNai == 0
                            ? l10n.dangGiuTamTuDon(
                                dinhDangTien(tong),
                                '${khoan.length}',
                              )
                            : l10n.dangGiuTamCoKhieuNai(
                                dinhDangTien(tong),
                                '${khoan.length}',
                                '$soKhieuNai',
                              ),
                        style: AppTextStyles.captionSm.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.labelGap),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            for (final k in khoan) ...[
              const AppDongKe(),
              _DongGiuTam(khoan: k),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChamCanhBao extends StatelessWidget {
  const _ChamCanhBao();

  static const double _canh = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _canh,
      height: _canh,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        '!',
        style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
      ),
    );
  }
}

// Một khoản treo: avatar bé, tên dịch vụ, lý do và tiền
class _DongGiuTam extends StatelessWidget {
  const _DongGiuTam({required this.khoan});

  final KhoanGiuTam khoan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = khoan.don;
    final be = don.pets.isEmpty ? null : don.pets.first;
    final con = don.phutConLai;
    final ghiChu = khoan.dangKhieuNai
        ? l10n.dangKhieuNai
        : (con != null && con > 0
              ? l10n.vaoViSau(dongHoConLai(l10n, con))
              : l10n.choChuNuoiChot);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: AppSpacing.itemGap,
      ),
      child: Row(
        children: [
          PetAvatar(
            imageUrl: be?.avatar,
            name: be?.name,
            size: _duongKinhAvatarBe,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${don.dichVu.ten(l10n)} · #${don.maDon}',
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  be == null ? ghiChu : '${be.name} · $ghiChu',
                  style: AppTextStyles.captionSm.copyWith(
                    color: khoan.dangKhieuNai ? AppColors.accent : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.labelGap),
          Text(
            '${dinhDangTien(khoan.soTien)}đ',
            style: AppTextStyles.button.copyWith(
              color: khoan.dangKhieuNai
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
