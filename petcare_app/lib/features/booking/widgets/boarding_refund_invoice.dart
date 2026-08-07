import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/widgets/cancel_policy_link.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

// Hoá đơn hoàn tiền của kỳ trông giữ kết thúc sớm
class BoardingRefundInvoice extends StatelessWidget {
  const BoardingRefundInvoice({
    super.key,
    required this.daTra,
    required this.dongTru,
    required this.tienHoan,
  });

  final int daTra;
  final List<DongHoaDon> dongTru;
  final int tienHoan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hoaDonHoanTien, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        _Hang(nhan: l10n.daThanhToan, chu: '${dinhDangTien(daTra)}đ'),
        for (final d in dongTru) ...[
          const SizedBox(height: 12),
          _Hang(
            nhan: d.nhan,
            chu: '-${dinhDangTien(d.tien)}đ',
            mauChu: AppColors.accent,
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(l10n.hoanVeVnpayNhan, style: AppTextStyles.h3),
            ),
            const SizedBox(width: 12),
            Text(
              '${dinhDangTien(tienHoan)}đ',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 17,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.hoanTienVeTaiKhoan,
                style: AppTextStyles.captionSm,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CancelPolicyLink(nhan: l10n.chinhSachHuyVaDonTraBe),
      ],
    );
  }
}

class _Hang extends StatelessWidget {
  const _Hang({required this.nhan, required this.chu, this.mauChu});

  final String nhan;
  final String chu;
  final Color? mauChu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
        const SizedBox(width: 12),
        Text(chu, style: AppTextStyles.label.copyWith(color: mauChu)),
      ],
    );
  }
}
