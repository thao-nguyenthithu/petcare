import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_wallet.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/shared/widgets/sitter_booking_card.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';

const double _boGocThe = 20;
const double _duongKinhAvatarBe = 26;

class OwnerHoldingCard extends StatelessWidget {
  const OwnerHoldingCard({
    super.key,
    required this.tongTamGiu,
    required this.soDon,
    required this.chiTieuThangNay,
    required this.thang,
    required this.onXemTatCa,
  });

  final int tongTamGiu;
  final int soDon;
  final int chiTieuThangNay;
  final int thang;
  final VoidCallback onXemTatCa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chuMo = AppColors.textWhite.withValues(alpha: 0.85);
    return Material(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(_boGocThe),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: soDon == 0 ? null : onXemTatCa,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.blockGap),
          child: Stack(
            children: [
              const ViDauChanChim(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 16, color: chuMo),
                      const SizedBox(width: AppSpacing.labelGap),
                      Expanded(
                        child: Text(
                          l10n.tienDangTamGiu,
                          style: AppTextStyles.captionSm.copyWith(color: chuMo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    '${dinhDangTien(tongTamGiu)}đ',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    soDon == 0
                        ? l10n.khongCoDonDangGiuTien
                        : l10n.moTaGiuHoNDon('$soDon'),
                    style: AppTextStyles.captionSm.copyWith(color: chuMo),
                  ),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    l10n.daChiTrongThang(
                      dinhDangTien(chiTieuThangNay),
                      '$thang',
                    ),
                    style: AppTextStyles.captionSm.copyWith(color: chuMo),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OwnerHoldingBlock extends StatelessWidget {
  const OwnerHoldingBlock({
    super.key,
    required this.khoan,
    required this.onXemTatCa,
  });

  final List<KhoanTamGiuChuNuoi> khoan;
  final VoidCallback onXemTatCa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tong = khoan.fold(0, (t, k) => t + k.soTien);

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
                color: AppColors.cardMint,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppSpacing.itemGap,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: AppSpacing.itemGap),
                    Expanded(
                      child: Text(
                        l10n.dangTamGiuChoDon(
                          dinhDangTien(tong),
                          '${khoan.length}',
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
              _DongTamGiu(khoan: k),
            ],
          ],
        ),
      ),
    );
  }
}

class _DongTamGiu extends StatelessWidget {
  const _DongTamGiu({required this.khoan});

  final KhoanTamGiuChuNuoi khoan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = khoan.don;
    final be = don.pets.isEmpty ? null : don.pets.first;
    final ghiChu = khoan.dangKhieuNai
        ? l10n.banDangKhieuNai
        : don.nhanCacBe(l10n);

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
                  ghiChu,
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
            style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class OwnerTransactionCard extends StatelessWidget {
  const OwnerTransactionCard({super.key, required this.giaoDich, this.onTap});

  final GiaoDichChuNuoi giaoDich;
  final VoidCallback? onTap;

  static const double _vong = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = giaoDich.don;
    if (don != null) {
      return SitterBookingCard(
        booking: don,
        onTap: onTap,
        thoiGianGhiDe: giaoDich.moTaMoc,
        tienGhiDe: _nhanTien,
        mauTienGhiDe: giaoDich.laTienVao
            ? AppColors.primaryColor
            : AppColors.textPrimary,
        ghiChuGhiDe: giaoDich.loai == LoaiGiaoDichChuNuoi.hoanTien
            ? l10n.hoanDuKhongMatPhi
            : (giaoDich.maKhieuNai != null ? l10n.banDangKhieuNai : null),
      );
    }

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
                  color: AppColors.cardMint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_downward_rounded,
                  size: 20,
                  color: AppColors.primaryColor,
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
                    Text(
                      giaoDich.moTaMoc,
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              Text(
                _nhanTien,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _nhanTien =>
      '${giaoDich.laTienVao ? '+' : '−'}'
      '${dinhDangTien(giaoDich.soTien.abs())}đ';
}

class OwnerSpendByService extends StatelessWidget {
  const OwnerSpendByService({super.key, required this.dong});

  final List<ChiTieuTheoDichVu> dong;
  static const double _dayThanh = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lonNhat = dong.fold(0, (m, d) => d.soTien > m ? d.soTien : m);
    return ViCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViSectionTitle(l10n.tieuVaoViecGi),
          const SizedBox(height: AppSpacing.stackGap),
          for (final (i, d) in dong.indexed) ...[
            if (i != 0) const SizedBox(height: AppSpacing.stackGap),
            Row(
              children: [
                Expanded(
                  child: Text(d.dichVu.ten(l10n), style: AppTextStyles.label),
                ),
                Text(l10n.soDon('${d.soDon}'), style: AppTextStyles.captionSm),
                const SizedBox(width: AppSpacing.labelGap),
                Text('${dinhDangTien(d.soTien)}đ', style: AppTextStyles.label),
              ],
            ),
            const SizedBox(height: AppSpacing.labelGap),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: lonNhat == 0 ? 0 : d.soTien / lonNhat,
                minHeight: _dayThanh,
                backgroundColor: AppColors.neutralLight,
                valueColor: AlwaysStoppedAnimation(d.dichVu.mauCham),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
