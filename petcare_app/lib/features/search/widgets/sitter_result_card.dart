import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/diem_so.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Mở hồ sơ công khai của người chăm
void _moHoSo(BuildContext context, String id) =>
    context.push(AppRoutes.sitterDetail.replaceFirst(':id', id));

class SitterResultCard extends StatelessWidget {
  const SitterResultCard({
    super.key,
    required this.nguoiCham,
    this.soNgayChon = 0,
    this.onTap,
  });

  static const double _coAvatar = 56;

  final SitterResult nguoiCham;
  final int soNgayChon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coLichNhan = soNgayChon > 0;
    return Material(
      color: AppColors.surface,
      elevation: 2,
      shadowColor: AppColors.shadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: onTap ?? () => _moHoSo(context, nguoiCham.id),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    imageUrl: nguoiCham.avatarUrl,
                    name: nguoiCham.name,
                    size: _coAvatar,
                  ),
                  const SizedBox(width: AppSpacing.itemGap),
                  Expanded(child: _ThongTinChinh(nguoiCham: nguoiCham)),
                  const SizedBox(width: AppSpacing.labelGap),
                  _KhoiGia(nguoiCham: nguoiCham),
                ],
              ),
              if (coLichNhan) ...[
                const SizedBox(height: AppSpacing.itemGap),
                const AppDongKe(),
                const SizedBox(height: AppSpacing.itemGap),
                _DongLichNhan(
                  soNgayNhan: nguoiCham.soNgayNhan < soNgayChon
                      ? nguoiCham.soNgayNhan
                      : soNgayChon,
                  soNgayChon: soNgayChon,
                  l10n: l10n,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThongTinChinh extends StatelessWidget {
  const _ThongTinChinh({required this.nguoiCham});

  final SitterResult nguoiCham;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                nguoiCham.name,
                style: AppTextStyles.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (nguoiCham.tinCay) ...[
              const SizedBox(width: AppSpacing.labelGap),
              AppStatusBadge(
                label: l10n.nhanTinCay,
                background: AppColors.cardMint,
                textColor: AppColors.primaryColor,
                leading: const Icon(
                  Icons.verified_user_outlined,
                  size: 13,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.textGap),
        if (_moTaViTri(l10n) != null) ...[
          Text(
            _moTaViTri(l10n)!,
            style: AppTextStyles.captionSm,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.textGap),
        ],
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 16, color: AppColors.honey),
            const SizedBox(width: AppSpacing.textGap),
            Flexible(
              child: Text(
                '${soDiem(nguoiCham.rating)}'
                ' (${nguoiCham.soDanhGia}) · '
                '${l10n.donHoanThanhSo('${nguoiCham.soDonHoanThanh}')}',
                style: AppTextStyles.captionSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _moTaViTri(AppLocalizations l10n) {
    final km = nguoiCham.khoangCachKm;
    final phan = [
      if (nguoiCham.khuVuc != null && nguoiCham.khuVuc!.isNotEmpty)
        nguoiCham.khuVuc!,
      if (km != null) l10n.cachKm(soLeKm(km)),
    ];
    return phan.isEmpty ? null : phan.join(' · ');
  }
}

class _KhoiGia extends StatelessWidget {
  const _KhoiGia({required this.nguoiCham});

  final SitterResult nguoiCham;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (nguoiCham.gia != null) ...[
          Text(l10n.tu, style: AppTextStyles.captionSm),
          Text(
            l10n.giaTien(dinhDangTien(nguoiCham.gia!)),
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryColor),
          ),
          Text(nguoiCham.loai.donVi(l10n), style: AppTextStyles.captionSm),
        ],
      ],
    );
  }
}

class _DongLichNhan extends StatelessWidget {
  const _DongLichNhan({
    required this.soNgayNhan,
    required this.soNgayChon,
    required this.l10n,
  });

  final int soNgayNhan;
  final int soNgayChon;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final mau = soNgayNhan >= soNgayChon
        ? AppColors.primaryColor
        : AppColors.accent;
    return Row(
      children: [
        Icon(Icons.schedule_rounded, size: 16, color: mau),
        const SizedBox(width: AppSpacing.labelGap),
        Expanded(
          child: Text(
            l10n.nhanDonNgayBanChon(soNgayNhan, soNgayChon),
            style: AppTextStyles.captionSm.copyWith(color: mau),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
