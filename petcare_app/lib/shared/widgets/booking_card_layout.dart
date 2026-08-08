import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Số đo riêng của card đơn
const double _duongKinhAvatar = 46;
const double _duongKinhAvatarBe = 26;
const double _cham = 6;

class BookingCardLayout extends StatelessWidget {
  const BookingCardLayout({
    super.key,
    required this.tenDoiTac,
    required this.dichVu,
    required this.thoiLuong,
    required this.dongThoiGian,
    required this.maDon,
    required this.pets,
    required this.dongBe,
    required this.tien,
    required this.mauTien,
    this.anhDoiTac,
    this.badge,
    this.onTap,
  });

  final String tenDoiTac;
  final String? anhDoiTac;
  final Widget? badge;
  final LoaiDichVu dichVu;
  final String thoiLuong;
  final String dongThoiGian;
  final String maDon;

  final List<PetBrief> pets;
  final String dongBe;
  final String tien;
  final Color mauTien;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    name: tenDoiTac,
                    imageUrl: anhDoiTac,
                    size: _duongKinhAvatar,
                  ),
                  const SizedBox(width: AppSpacing.itemGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                tenDoiTac,
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (badge case final b?) ...[
                              const SizedBox(width: AppSpacing.labelGap),
                              b,
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: _cham,
                              height: _cham,
                              decoration: BoxDecoration(
                                color: dichVu.mauCham,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.textGap),
                            Flexible(
                              child: Text(
                                dichVu.ten(context.l10n),
                                style: AppTextStyles.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.textGap),
                            Text(thoiLuong, style: AppTextStyles.captionSm),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dongThoiGian,
                                style: AppTextStyles.captionSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.labelGap),
                            Text('#$maDon', style: AppTextStyles.captionSm),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              const AppDongKe(),
              const SizedBox(height: 11),
              Row(
                children: [
                  PetAvatarStack(
                    pets: pets,
                    size: _duongKinhAvatarBe,
                    toiDa: 2,
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Expanded(
                    child: Text(
                      dongBe,
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Text(
                    tien,
                    style: AppTextStyles.button.copyWith(color: mauTien),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
