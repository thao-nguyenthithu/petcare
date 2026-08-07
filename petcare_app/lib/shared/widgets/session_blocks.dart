import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class SessionVerifyRows extends StatelessWidget {
  const SessionVerifyRows({super.key, required this.muc});

  final List<MucXacMinh> muc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.xacMinhTruocKhiDat, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final (i, m) in muc.indexed) ...[
          if (i != 0) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${m.ten} · ${l10n.daXacMinh.toLowerCase()}',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.aiKiemAnhCheckIn(m.gio, '${m.doTinCay}'),
                      style: AppTextStyles.captionSm,
                    ),
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

// Mục Diễn biến; mốc có giờ rỗng là dòng nhóm ngày
class SessionTimeline extends StatelessWidget {
  const SessionTimeline({super.key, required this.moc});

  final List<MocDienBien> moc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.dienBien, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final (i, m) in moc.indexed) ...[
          if (i != 0) const SizedBox(height: 12),
          if (m.gio.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
              child: Text(
                m.viec,
                style: AppTextStyles.label.copyWith(
                  color: m.daXong
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 44,
                  child: Text(
                    m.gio,
                    style: AppTextStyles.label.copyWith(
                      color: m.daXong
                          ? AppColors.primaryColor
                          : AppColors.neutral,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: m.daXong
                        ? AppColors.primaryColor
                        : AppColors.neutral,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.viec,
                    style: AppTextStyles.captionSm.copyWith(
                      color: m.daXong ? AppColors.textPrimary : null,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}

// Mục Nhật ký ảnh
class SessionPhotoLog extends StatelessWidget {
  const SessionPhotoLog({
    super.key,
    required this.anh,
    required this.tong,
    this.onXemTatCa,
    this.tieuDe,
    this.nhanXemTatCa,
    this.soCot = 3,
    this.onThem,
    this.nhanAnh = const [],
  });

  final List<String> anh;
  final int tong;
  final List<String> nhanAnh;
  final VoidCallback? onXemTatCa;
  final String? tieuDe;
  final String? nhanXemTatCa;
  final int soCot;
  final VoidCallback? onThem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hien = anh.take(soCot).toList();
    final con = tong - hien.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tieuDe ?? l10n.nhatKyAnhSo('$tong'),
                style: AppTextStyles.h3,
              ),
            ),
            if (onXemTatCa case final xem?)
              InkWell(
                onTap: xem,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                  child: Row(
                    children: [
                      Text(
                        nhanXemTatCa ?? l10n.xemTatCa,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final (i, url) in hien.indexed) ...[
              if (i != 0) const SizedBox(width: 10),
              Expanded(
                child: _O(
                  url: url,
                  con: onThem == null && i == hien.length - 1 && con > 0
                      ? con
                      : 0,
                  nhan: i < nhanAnh.length ? nhanAnh[i] : null,
                  onTap: onXemTatCa,
                ),
              ),
            ],
            if (onThem case final them?) ...[
              if (hien.isNotEmpty) const SizedBox(width: 10),
              Expanded(child: _OChupThem(onTap: them)),
            ],
          ],
        ),
      ],
    );
  }
}

class _OChupThem extends StatelessWidget {
  const _OChupThem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: AppCard(
        nen: AppColors.background,
        padding: EdgeInsets.zero,
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.photo_camera_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(context.l10n.chupThem, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ),
    );
  }
}

class _O extends StatelessWidget {
  const _O({
    required this.url,
    required this.con,
    required this.onTap,
    this.nhan,
  });

  final String url;
  final int con;
  final VoidCallback? onTap;
  final String? nhan;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: AppColors.cardMint,
                child: url.isEmpty
                    ? const Icon(
                        Icons.pets,
                        color: AppColors.primaryColor,
                        size: 28,
                      )
                    : CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        memCacheWidth: beRongCache(
                          context,
                          MediaQuery.sizeOf(context).width / 3,
                        ),
                        placeholder: (_, _) =>
                            const ColoredBox(color: AppColors.cardMint),
                        errorWidget: (_, _, _) =>
                            const ColoredBox(color: AppColors.cardMint),
                      ),
              ),
              if (con > 0)
                Container(
                  color: AppColors.textPrimary.withValues(alpha: 0.45),
                  alignment: Alignment.center,
                  child: Text(
                    '+$con',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
              if (nhan case final n?)
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      n,
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef SoLieuPhien = ({String so, String nhan});

class SessionStats extends StatelessWidget {
  const SessionStats({super.key, required this.cot});

  final List<SoLieuPhien> cot;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          for (final (i, c) in cot.indexed) ...[
            if (i != 0) const _Vach(),
            _Cot(so: c.so, nhan: c.nhan),
          ],
        ],
      ),
    );
  }
}

class _Cot extends StatelessWidget {
  const _Cot({required this.so, required this.nhan});

  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            so,
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 3),
          Text(nhan, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}

class _Vach extends StatelessWidget {
  const _Vach();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: AppColors.neutralLight);
}
