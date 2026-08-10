import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class HandoverNoticeBox extends StatelessWidget {
  const HandoverNoticeBox({super.key, required this.chinh, this.phu});

  final String chinh;
  final String? phu;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      nen: AppColors.cardMint,
      vien: false,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chinh,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                if (phu case final p? when p.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    p,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
