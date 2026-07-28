import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_earnings.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

// Một dòng giao dịch ở màn Thu nhập
class EarningsTransactionRow extends StatelessWidget {
  const EarningsTransactionRow({super.key, required this.tx, this.onTap});

  final EarningsTransaction tx;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final noiDung = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          PetAvatar(imageUrl: tx.petAvatar, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTextStyles.label.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  tx.ownerInfo,
                  style: AppTextStyles.captionSm,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      tx.dateTime,
                      style: AppTextStyles.captionSm.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _MethodChip(method: tx.method),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${dinhDangTien(tx.amount)}đ',
                style: AppTextStyles.label.copyWith(
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              // Giá gốc
              Text(
                l10n.giaDon(dinhDangTien(tx.gross)),
                style: AppTextStyles.captionSm.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (onTap == null) return noiDung;
    return InkWell(onTap: onTap, child: noiDung);
  }
}

// Chip nhỏ báo phương thức thanh toán
class _MethodChip extends StatelessWidget {
  const _MethodChip({required this.method});

  final PaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final laCash = method == PaymentMethod.cash;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.neutralLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            laCash
                ? Icons.payments_outlined
                : Icons.account_balance_wallet_outlined,
            size: 11,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 3),
          Text(
            laCash ? l10n.tienMat : l10n.online,
            style: AppTextStyles.captionSm.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
