import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/ai_scan.dart';
import 'package:petcare_app/shared/utils/anh_cache.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Ô dọc 3:4 theo khung máy ảnh: ảnh to mà cover không phải cắt hai bên như ô vuông
const double _oAnhRong = 112;
const double _oAnhCao = 149;

// Một hàng kết quả của một bé, mỗi bé quét độc lập
class AiScanHangBe extends StatelessWidget {
  const AiScanHangBe({super.key, required this.slot, required this.dangQuet});

  final SlotQuet slot;
  final bool dangQuet;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 20, height: 21, child: _dau()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.beThuMay('${slot.slotIndex}'),
                style: AppTextStyles.label,
              ),
              if (!dangQuet && slot.reason.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(slot.reason, style: AppTextStyles.captionSm),
              ],
              if (slot.ghiChu case final ghiChu? when !dangQuet) ...[
                const SizedBox(height: 3),
                Text(
                  ghiChu,
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
              if (_dongPhu(l10n) case final phu?) ...[
                const SizedBox(height: 3),
                Text(phu, style: AppTextStyles.captionSm),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _dau() {
    if (dangQuet) {
      return const Padding(
        padding: EdgeInsets.only(top: 1),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (slot.xong) {
      return const Icon(
        Icons.check_circle,
        size: 20,
        color: AppColors.primaryColor,
      );
    }
    final thieuThat = slot.ketLuan == KetLuanQuet.khongDat;
    return Icon(
      thieuThat ? Icons.cancel : Icons.help_outline,
      size: 20,
      color: thieuThat ? AppColors.accent : AppColors.neutral,
    );
  }

  String? _dongPhu(AppLocalizations l10n) {
    if (dangQuet) return null;
    if (slot.daTuXacNhan) return l10n.banDaTuXacNhan;
    if (slot.loiHeThong) return null;
    if (!slot.xong) return l10n.conNLanChupLai('${slot.soLanConLai}');
    if (!slot.anhDuNet) return null;
    return l10n.doTinCayPhanTram('${slot.phanTramTinCay}');
  }
}

class AiScanDaiAnh extends StatelessWidget {
  const AiScanDaiAnh({super.key, required this.slots});

  final List<SlotQuet> slots;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: _oAnhCao,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: leMucPhang),
        itemCount: slots.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final slot = slots[i];
          final caDan = slot.slotIndex == slotCaDan;
          return SizedBox(
            width: _oAnhRong,
            height: _oAnhCao,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  child: _anh(context, slot),
                ),
                Positioned(
                  left: 7,
                  bottom: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textPrimary.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      caDan ? l10n.caDan : l10n.beThuMay('${slot.slotIndex}'),
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _anh(BuildContext context, SlotQuet slot) {
    final url = slot.anhUrl;
    if (url == null || url.isEmpty) {
      return const ColoredBox(
        color: AppColors.cardMint,
        child: Icon(Icons.pets, color: AppColors.primaryColor, size: 24),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: beRongCache(context, _oAnhRong),
      errorWidget: (_, _, _) => const ColoredBox(
        color: AppColors.cardMint,
        child: Icon(Icons.broken_image_outlined, color: AppColors.neutral),
      ),
    );
  }
}
