import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

export 'package:petcare_app/shared/widgets/vi_cards.dart';

class ViDauChanChim extends StatelessWidget {
  const ViDauChanChim({super.key});
  static const double _coHinh = 64;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 0,
      top: 0,
      child: SvgPicture.asset(
        'assets/icons/paw.svg',
        width: _coHinh,
        height: _coHinh,
        colorFilter: ColorFilter.mode(
          AppColors.textWhite.withValues(alpha: 0.12),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class ViSectionTitle extends StatelessWidget {
  const ViSectionTitle(this.nhan, {super.key});

  final String nhan;

  @override
  Widget build(BuildContext context) => Text(nhan, style: AppTextStyles.h3);
}

class ViMoneyRows extends StatelessWidget {
  const ViMoneyRows({
    super.key,
    required this.dong,
    required this.tong,
    this.mauTong = AppColors.accent,
  });

  final List<DongHoaDon> dong;
  final DongHoaDon tong;
  final Color mauTong;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final d in dong) ...[
          _Dong(nhan: d.nhan, giaTri: _tien(d.tien)),
          const SizedBox(height: AppSpacing.itemGap),
        ],
        const AppDongKe(),
        const SizedBox(height: AppSpacing.itemGap),
        Row(
          children: [
            Expanded(child: Text(tong.nhan, style: AppTextStyles.label)),
            Text(
              _tien(tong.tien),
              style: AppTextStyles.button.copyWith(color: mauTong),
            ),
          ],
        ),
      ],
    );
  }

  static String _tien(int so) =>
      '${so < 0 ? '−' : ''}${dinhDangTien(so.abs())}đ';
}

class _Dong extends StatelessWidget {
  const _Dong({required this.nhan, required this.giaTri});

  final String nhan;
  final String giaTri;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(nhan, style: AppTextStyles.body)),
        const SizedBox(width: AppSpacing.labelGap),
        Text(
          giaTri,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class ViInfoRows extends StatelessWidget {
  const ViInfoRows({super.key, required this.dong});

  final List<({String nhan, String giaTri})> dong;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, d) in dong.indexed) ...[
          if (i != 0) const SizedBox(height: AppSpacing.labelGap),
          Row(
            children: [
              Expanded(child: Text(d.nhan, style: AppTextStyles.captionSm)),
              const SizedBox(width: AppSpacing.labelGap),
              Text(
                d.giaTri,
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ViTimeline extends StatelessWidget {
  const ViTimeline({super.key, required this.moc});

  final List<MocViDien> moc;
  static const double _cham = 9;
  static const double _cotCham = 20;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, m) in moc.indexed) ...[
          if (i != 0) const SizedBox(height: AppSpacing.itemGap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _cotCham,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: _cham,
                    height: _cham,
                    decoration: BoxDecoration(
                      color: m.daXong
                          ? AppColors.primaryColor
                          : AppColors.neutral,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.viec,
                      style: AppTextStyles.captionSm.copyWith(
                        color: m.daXong
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(m.thoiDiem, style: AppTextStyles.captionSm),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ViNoteBlock extends StatelessWidget {
  const ViNoteBlock({
    super.key,
    required this.nhan,
    required this.noiDung,
    this.moc,
    this.nhanNhat = false,
  });

  final String nhan;
  final String noiDung;
  final String? moc;
  final bool nhanNhat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                nhan,
                style: nhanNhat ? AppTextStyles.captionSm : AppTextStyles.h3,
              ),
            ),
            if (moc != null) ...[
              const SizedBox(width: AppSpacing.labelGap),
              Text(moc!, style: AppTextStyles.captionSm),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.labelGap),
        Text(
          noiDung,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class ViStatusBanner extends StatelessWidget {
  const ViStatusBanner({
    super.key,
    required this.icon,
    required this.tieuDe,
    required this.moTa,
    required this.mau,
  });

  final IconData icon;
  final String tieuDe;
  final String moTa;
  final Color mau;
  static const double _vong = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mau.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _vong,
            height: _vong,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: mau, shape: BoxShape.circle),
            child: Icon(icon, size: 14, color: AppColors.textWhite),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tieuDe, style: AppTextStyles.label.copyWith(color: mau)),
                const SizedBox(height: AppSpacing.textGap),
                Text(moTa, style: AppTextStyles.captionSm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViPhotoRow extends StatelessWidget {
  const ViPhotoRow({super.key, required this.anh});

  final List<String> anh;
  static const double _canh = 96;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _canh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: anh.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => showPhotoViewer(
            context,
            anh: [for (final u in anh) PhotoItem.mang(u)],
            viTri: i,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            child: CachedNetworkImage(
              imageUrl: anh[i],
              width: _canh,
              height: _canh,
              fit: BoxFit.cover,
              memCacheWidth: beRongCache(context, _canh),
              errorWidget: (_, _, _) => _oHong(),
              placeholder: (_, _) => _oHong(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _oHong() => Container(
    width: _canh,
    height: _canh,
    alignment: Alignment.center,
    color: AppColors.neutralLight,
    child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
  );
}

class ViSecondaryButton extends StatelessWidget {
  const ViSecondaryButton({super.key, required this.nhan, required this.onTap});

  final String nhan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cardMint,
          foregroundColor: AppColors.primaryColor,
        ),
        child: Text(nhan),
      ),
    );
  }
}
