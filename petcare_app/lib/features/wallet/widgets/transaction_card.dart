import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';

// Giao dịch sinh từ đơn thì mượn thẻ đơn dùng chung
class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key, required this.giaoDich, this.onTap});

  final GiaoDichVi giaoDich;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = giaoDich.don;
    if (don != null) {
      return SitterBookingCard(
        booking: don,
        onTap: onTap,
        hienNhanTrangThai: false,
        thoiGianGhiDe: l10n.vaoViLuc(giaoDich.moTaMoc),
      );
    }
    return _DongGiaoDich(giaoDich: giaoDich, onTap: onTap);
  }
}

// Không gắn đơn: mũi tên lên là tiền ra, xuống là tiền vào
class _DongGiaoDich extends StatelessWidget {
  const _DongGiaoDich({required this.giaoDich, this.onTap});

  final GiaoDichVi giaoDich;
  final VoidCallback? onTap;
  static const double _vong = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vao = giaoDich.laTienVao;
    final mauVong = giaoDich.loai == LoaiGiaoDich.dieuChinh
        ? AppColors.accent
        : AppColors.textSecondary;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.all(14), // padding riêng thẻ giao dịch
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Row(
            children: [
              Container(
                width: _vong,
                height: _vong,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mauVong.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  vao
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 20,
                  color: mauVong,
                ),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      giaoDich.tieuDe,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            giaoDich.loai == LoaiGiaoDich.rutRa
                                ? l10n.chuyenDiLuc(giaoDich.moTaMoc)
                                : l10n.truKhoiViLuc(giaoDich.moTaMoc),
                            style: AppTextStyles.captionSm,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (giaoDich.don == null && giaoDich.maKhieuNai != null)
                          Text(
                            '#${giaoDich.maKhieuNai}',
                            style: AppTextStyles.captionSm,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Text(
                '${vao ? '+' : '−'}${dinhDangTien(giaoDich.soTien.abs())}đ',
                style: AppTextStyles.button.copyWith(
                  color: vao ? AppColors.primaryColor : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
