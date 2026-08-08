import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/widgets/cancel_policy_link.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

class BookingInvoice extends StatelessWidget {
  const BookingInvoice({
    super.key,
    required this.dong,
    required this.tong,
    required this.daNhanDon,
    this.hienChinhSachHuy = false,
    this.nhanChinhSachHuy,
    this.mocHuy,
  });

  final String? nhanChinhSachHuy;
  final String? mocHuy;
  final List<DongHoaDon> dong;
  final int tong;
  final bool hienChinhSachHuy;
  final bool daNhanDon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hoaDon, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final d in dong)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: Text(d.nhan, style: AppTextStyles.captionSm)),
                const SizedBox(width: 12),
                Text('${dinhDangTien(d.tien)}đ', style: AppTextStyles.label),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(child: Text(l10n.daThanhToan, style: AppTextStyles.h3)),
            const SizedBox(width: 12),
            Text('${dinhDangTien(tong)}đ', style: AppTextStyles.h2),
          ],
        ),
        const SizedBox(height: 16),
        _DongGhiChu(
          icon: Icons.account_balance_wallet_outlined,
          text: daNhanDon ? l10n.daTraQuaVnpay : l10n.daTraQuaVnpayChuaNhan,
        ),
        if (hienChinhSachHuy) ...[
          if (mocHuy case final moc?) ...[
            const SizedBox(height: 12),
            _DongGhiChu(icon: Icons.event_busy_outlined, text: moc),
          ],
          const SizedBox(height: 12),
          CancelPolicyLink(nhan: nhanChinhSachHuy),
        ],
      ],
    );
  }
}

class _DongGhiChu extends StatelessWidget {
  const _DongGhiChu({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.captionSm)),
      ],
    );
  }
}
