import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/mo_email_ho_tro.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';

// Màn Trợ giúp và hỗ trợ, hai vai dùng chung, chỉ đọc
class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  Future<void> _guiEmail(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final loi = await moEmailHoTro(context, ref);
    if (loi != null) {
      messenger.showSnackBar(SnackBar(content: Text(loi)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cauHinh = ref.watch(cauHinhNghiepVuProvider);
    final cauHoi = [
      (hoi: l10n.faqHuyDonHoi, dap: l10n.faqHuyDonDap('${cauHinh.phiHuyMuonPhanTram}')),
      (hoi: l10n.faqHoanTienHoi, dap: l10n.hoanTienVeTaiKhoan),
      (hoi: l10n.faqBaoSuCoHoi, dap: l10n.faqBaoSuCoDap('${cauHinh.gioGiuTien}')),
      (hoi: l10n.faqThanhToanHoi, dap: l10n.faqThanhToanDap),
      (hoi: l10n.faqThanhNguoiChamHoi, dap: l10n.faqThanhNguoiChamDap),
    ];
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.troGiupHoTro),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.stackGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          Text(l10n.cauHoiThuongGap, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.itemGap),
          for (final muc in cauHoi)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(
                bottom: AppSpacing.stackGap,
              ),
              shape: const Border(),
              title: Text(muc.hoi, style: AppTextStyles.label),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(muc.dap, style: AppTextStyles.captionSm),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.blockGap),
          Text(l10n.lienHeDoiHoTro, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.itemGap),
          AppCard(
            nen: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.moTaLienHeHoTro, style: AppTextStyles.captionSm),
                if (cauHinh.emailHoTro case final email?) ...[
                  const SizedBox(height: AppSpacing.itemGap),
                  Row(
                    children: [
                      const Icon(
                        Icons.mail_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(email, style: AppTextStyles.label),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.stackGap),
                AppButton(
                  text: l10n.guiEmailChoHoTro,
                  height: 50,
                  onTap: () => _guiEmail(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
