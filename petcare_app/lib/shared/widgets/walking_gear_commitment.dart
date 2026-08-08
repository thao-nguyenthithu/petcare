import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Cam kết dụng cụ của đơn dắt đi dạo, dùng chung hai vai
class WalkingGearCommitment extends ConsumerWidget {
  const WalkingGearCommitment({
    super.key,
    required this.soBe,
    required this.daCam,
    required this.onDoi,
    this.loi,
    this.tieuDe,
    this.nhan,
    this.moTa,
  });

  final int soBe;
  final bool daCam;
  final ValueChanged<bool> onDoi;
  final String? loi;
  final String? tieuDe;
  final String? nhan;
  final String? moTa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final phiHuy = ref.watch(cauHinhNghiepVuProvider).phiHuyMuonPhanTram;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe ?? l10n.dungCuBanCanChuanBi, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        InkWell(
          onTap: () => onDoi(!daCam),
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: AppCard(
            width: double.infinity,
            nen: AppColors.cardMint,
            vien: false,
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: daCam,
                    onChanged: (v) => onDoi(v ?? false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nhan ??
                            (soBe > 1
                                ? l10n.camKetRoMomDayXich('$soBe')
                                : l10n.camKetRoMomDayXichMotBe),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        moTa ?? l10n.moTaCamKetRoMom('$phiHuy'),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.balance_outlined,
              size: 17,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.dieu66LuatChanNuoi,
                style: AppTextStyles.captionSm,
              ),
            ),
          ],
        ),
        if (loi != null) ...[
          const SizedBox(height: 8),
          Text(
            loi!,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
          ),
        ],
      ],
    );
  }
}
