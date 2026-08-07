import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _avatar = 44;

// Mục Gói dịch vụ từng bé ở màn chi tiết đơn tắm và cắt tỉa
class GroomingPetPackages extends StatelessWidget {
  const GroomingPetPackages({super.key, required this.muc});

  final List<GoiCuaBe> muc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.goiDichVuTungBe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final (i, m) in muc.indexed) ...[
          if (i != 0) const SizedBox(height: 14),
          _DongBe(muc: m),
        ],
      ],
    );
  }
}

class _DongBe extends StatelessWidget {
  const _DongBe({required this.muc});

  final GoiCuaBe muc;

  @override
  Widget build(BuildContext context) {
    final be = muc.be;
    return Row(
      children: [
        PetAvatar(imageUrl: be.avatar, name: be.name, size: _avatar),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(be.name, style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(
                petGiongCan(context, be),
                style: AppTextStyles.captionSm,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Hoá đơn ngay dưới đã có giá, nhắc lại là bắt đối chiếu hai chỗ
        Text(groomingPackageName(context, muc.goi), style: AppTextStyles.label),
      ],
    );
  }
}
