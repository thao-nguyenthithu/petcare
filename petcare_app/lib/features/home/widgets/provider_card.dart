import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/utils/diem_so.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';

// Card người chăm ở hàng cuộn ngang tại Home
class ProviderCard extends StatelessWidget {
  const ProviderCard({super.key, required this.data, this.onTap});

  static const double rong = 164;
  final SitterResult data;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final danhGia = '${soDiem(data.rating)} (${data.soDanhGia})';
    final dongDanhGia = data.khoangCachKm == null
        ? danhGia
        : '$danhGia · ${l10n.soKm(soLeKm(data.khoangCachKm!))}';
    return SizedBox(
      width: rong,
      child: Material(
        color: AppColors.surface,
        elevation: 3,
        shadowColor: AppColors.shadow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Anh(url: data.avatarUrl),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          if (data.tinCay)
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: AppStatusBadge(
                                  label: l10n.nhanTinCay,
                                  background: AppColors.cardMint,
                                  textColor: AppColors.primaryColor,
                                  leading: const Icon(
                                    Icons.verified_user_outlined,
                                    size: 11,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          TextSpan(text: data.name),
                        ],
                      ),
                      style: AppTextStyles.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            dongDanhGia,
                            style: AppTextStyles.captionSm,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (data.gia != null)
                      Text(
                        l10n.tuGiaTien(dinhDangTien(data.gia!)),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Anh extends StatelessWidget {
  const _Anh({required this.url});

  static const double _cao = 110;
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const _AnhTrong(cao: _cao);
    return CachedNetworkImage(
      imageUrl: url!,
      height: _cao,
      width: double.infinity,
      fit: BoxFit.cover,
      // Hạ đúng bề ngang thật của ô (rule-flutter mục 5)
      memCacheWidth: beRongCache(context, ProviderCard.rong),
      placeholder: (_, _) => const _AnhTrong(cao: _cao),
      errorWidget: (_, _, _) => const _AnhTrong(cao: _cao),
    );
  }
}

class _AnhTrong extends StatelessWidget {
  const _AnhTrong({required this.cao});

  final double cao;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cao,
      width: double.infinity,
      color: AppColors.cardMint,
      child: const Icon(Icons.pets, color: AppColors.primaryColor),
    );
  }
}
