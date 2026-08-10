import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail_api.dart';
import 'package:petcare_app/features/booking/screens/review_screen.dart';
import 'package:petcare_app/features/reviews/widgets/review_item.dart';
import 'package:petcare_app/shared/data/bai_danh_gia_cua_toi.dart';

// Chạm một sao là sang màn đánh giá với số sao đó điền sẵn
class RatingInviteBlock extends StatelessWidget {
  const RatingInviteBlock({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (don.baiDanhGia case final bai?) return _BaiDaViet(don: don, bai: bai);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.banThayNccChamNBeTheNao(don.tenNcc, '${don.pets.length}'),
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 14),
        StarPicker(
          sao: 0,
          size: 34,
          onChon: (sao) => context.push(
            AppRoutes.bookingReview,
            extra: (don: donDeDanhGia(don), sao: sao),
          ),
        ),
        const SizedBox(height: 10),
        Text(l10n.chamDeChamSao, style: AppTextStyles.captionSm),
      ],
    );
  }
}

// Đã đánh giá thì hiện lại đúng bài đã viết, không mời chấm sao lần nữa
class _BaiDaViet extends StatelessWidget {
  const _BaiDaViet({required this.don, required this.bai});

  final OwnerBookingDetail don;
  final BaiDanhGiaApi bai;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ReviewItem(
      review: baiCuaToiThanhReview(don, bai, l10n),
      tienTo: l10n.banDanhGia,
      nhanPhanHoi: l10n.nguoiChamPhanHoi(don.tenNcc),
    );
  }
}

// Ghi chú người chăm để lại khi báo hoàn thành, kèm dòng xác nhận check-in
class SitterFinishNote extends StatelessWidget {
  const SitterFinishNote({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gioCheckIn = don.xacMinh.isEmpty ? '' : don.xacMinh.first.gio;
    final noiDung = don.ghiChuNcc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (noiDung != null) ...[
          Row(
            children: [
              const Icon(
                Icons.notes_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.ghiChuCuaNcc(don.tenNcc),
                style: AppTextStyles.captionSm,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('"$noiDung"', style: AppTextStyles.label),
        ],
        if (gioCheckIn.isNotEmpty) ...[
          if (noiDung != null) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                size: 16,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.checkInDaXacMinhDayDu(gioCheckIn),
                  style: AppTextStyles.captionSm.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
