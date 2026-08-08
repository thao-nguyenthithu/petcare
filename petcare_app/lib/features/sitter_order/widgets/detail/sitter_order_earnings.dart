import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/cancel_policy_link.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

// Khối tiền: giá đơn, phí nền tảng và số thực nhận
class SitterOrderEarnings extends StatelessWidget {
  const SitterOrderEarnings({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tieuDe = don.daHoanThanh
        ? l10n.thuNhapTuDonNay
        : don.daChotKetThucSom
        ? l10n.banNhanDuocDaTinhLai
        : l10n.banNhanDuoc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final d in don.dongTien) _Dong(nhan: d.nhan, tien: d.tien),
        _Dong(
          nhan: l10n.phiNenTangPhanTram('${don.phanTramPhiNenTang}'),
          tien: -don.phiNenTang,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Text(l10n.thucNhan, style: AppTextStyles.h3)),
            const SizedBox(width: 12),
            Text(
              '${dinhDangTien(don.thucNhan)}đ',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
        if (!don.daHoanThanh) ...[
          const SizedBox(height: 16),
          // Trang riêng vì hệ quả nói theo phía người chăm
          const CancelPolicyLink(duongDan: AppRoutes.sitterCancelPolicy),
        ],
      ],
    );
  }
}

// Một dòng tiền, nhãn trái và số phải
class _Dong extends StatelessWidget {
  const _Dong({required this.nhan, required this.tien});

  final String nhan;
  final int tien;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
          const SizedBox(width: 12),
          Text('${dinhDangTien(tien)}đ', style: AppTextStyles.label),
        ],
      ),
    );
  }
}
