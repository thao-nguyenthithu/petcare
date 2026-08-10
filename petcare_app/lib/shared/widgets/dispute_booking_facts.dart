import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const double _rongNhan = 96;

// Khối nhận diện đơn của các màn sự cố, hai vai dùng chung
class DisputeBookingFacts extends StatelessWidget {
  const DisputeBookingFacts({
    super.key,
    required this.tenDichVu,
    required this.maDon,
    required this.tenBe,
    required this.nhanDoiPhuong,
    required this.tenDoiPhuong,
    required this.thoiGian,
  });

  final String tenDichVu;
  final String maDon;
  final List<String> tenBe;
  final String nhanDoiPhuong;
  final String tenDoiPhuong;
  final String thoiGian;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      nen: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tenDichVu, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.itemGap),
          _Hang(nhan: l10n.maDonNhan, giaTri: maDon),
          _Hang(nhan: l10n.thuCung, giaTri: tenBe.join(', ')),
          _Hang(nhan: nhanDoiPhuong, giaTri: tenDoiPhuong),
          _Hang(nhan: l10n.thoiGian, giaTri: thoiGian, cuoi: true),
        ],
      ),
    );
  }
}

class _Hang extends StatelessWidget {
  const _Hang({required this.nhan, required this.giaTri, this.cuoi = false});

  final String nhan;
  final String giaTri;
  final bool cuoi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: cuoi ? 0 : AppSpacing.labelGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _rongNhan,
            child: Text(nhan, style: AppTextStyles.captionSm),
          ),
          Expanded(
            child: Text(
              giaTri.isEmpty ? '—' : giaTri,
              style: AppTextStyles.label,
            ),
          ),
        ],
      ),
    );
  }
}
