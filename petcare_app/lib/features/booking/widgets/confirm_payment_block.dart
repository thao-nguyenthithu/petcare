import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/cancel_policy_link.dart';

// Một phương thức duy nhất nên không có radio để chọn
class ConfirmPaymentBlock extends ConsumerWidget {
  const ConfirmPaymentBlock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cauHinh = ref.watch(cauHinhNghiepVuProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.thanhToan, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutral),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                cauHinh.batVnpay
                    ? l10n.traNgayBangVnpay
                    : l10n.traNgayBangCongThuNghiem,
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.moTaTraNgayVnpay('${cauHinh.gioGiuTien}'),
                style: AppTextStyles.captionSm,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const CancelPolicyLink(),
        const SizedBox(height: 12),
      ],
    );
  }
}
