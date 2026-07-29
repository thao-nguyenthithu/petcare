import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/prevention_items.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Khối chọn hạng mục
class PreventionItemDropdown extends StatelessWidget {
  const PreventionItemDropdown({
    super.key,
    required this.nhan,
    required this.daChon,
    required this.dangMo,
    required this.danhMuc,
    required this.cao,
    required this.chon,
    required this.tinhTrang,
    required this.onMoDong,
    required this.onChon,
  });

  final String nhan;
  final bool daChon;
  final bool dangMo;
  final List<PreventionItem> danhMuc;
  final double cao;
  final PreventionItem? chon;
  final ({bool daCo, int soLan}) Function(PreventionItem) tinhTrang;
  final VoidCallback onMoDong;
  final ValueChanged<PreventionItem> onChon;

  @override
  Widget build(BuildContext context) {
    final bo = BorderRadius.circular(AppRadius.radius14);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: bo),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor, width: 1.5),
        borderRadius: bo,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onMoDong,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nhan,
                      style: daChon
                          ? AppTextStyles.label
                          : AppTextStyles.label.copyWith(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                    ),
                  ),
                  Icon(
                    dangMo ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (dangMo) ...[
            const AppDongKe(),
            SizedBox(
              height: cao,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: danhMuc.length,
                  separatorBuilder: (_, _) => const AppDongKe(),
                  itemBuilder: (_, i) {
                    final muc = danhMuc[i];
                    final tinh = tinhTrang(muc);
                    return _DongHangMuc(
                      muc: muc,
                      daCo: tinh.daCo,
                      soLanDaCo: tinh.soLan,
                      dangChon: muc == chon,
                      onTap: tinh.daCo ? null : () => onChon(muc),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Một dòng trong danh sách
class _DongHangMuc extends StatelessWidget {
  const _DongHangMuc({
    required this.muc,
    required this.daCo,
    required this.soLanDaCo,
    required this.dangChon,
    required this.onTap,
  });

  final PreventionItem muc;
  final bool daCo;
  final int soLanDaCo;
  final bool dangChon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ghiChu = !daCo
        ? ''
        : (soLanDaCo > 0 ? l10n.daCoSoLan('$soLanDaCo') : l10n.chuaGhiLan);
    return Material(
      color: daCo
          ? AppColors.background
          : (dangChon ? AppColors.cardMint : AppColors.surface),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.cardPadding,
            AppSpacing.itemGap,
            AppSpacing.groupGap,
            AppSpacing.itemGap,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  tenHangMuc(context, muc.ma),
                  style: daCo
                      ? AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        )
                      : AppTextStyles.label.copyWith(
                          color: dangChon
                              ? AppColors.primaryColor
                              : AppColors.textPrimary,
                        ),
                ),
              ),
              if (ghiChu.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.itemGap),
                Text(
                  ghiChu,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.captionSm,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
