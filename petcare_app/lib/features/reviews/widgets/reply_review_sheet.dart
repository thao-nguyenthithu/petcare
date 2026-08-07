import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/review_stars.dart';

const int _soKyTuToiDa = 500;
Future<String?> moSheetVietPhanHoi(
  BuildContext context, {
  required SitterReview review,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius20),
      ),
    ),
    builder: (_) => _VietPhanHoiSheet(review: review),
  );
}

class _VietPhanHoiSheet extends StatefulWidget {
  const _VietPhanHoiSheet({required this.review});

  final SitterReview review;

  @override
  State<_VietPhanHoiSheet> createState() => _VietPhanHoiSheetState();
}

class _VietPhanHoiSheetState extends State<_VietPhanHoiSheet> {
  final _noiDung = TextEditingController();

  @override
  void initState() {
    super.initState();
    _noiDung.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noiDung.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = widget.review;
    final chu = _noiDung.text.trim();
    final phu = [
      r.service,
      if (r.pets.length > 1) l10n.soBe('${r.pets.length}'),
      r.time,
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.stackGap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _NutDong(onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: AppSpacing.itemGap),
                  Text(l10n.vietPhanHoi, style: AppTextStyles.h3),
                ],
              ),
              const SizedBox(height: AppSpacing.blockGap),
              Text(r.name, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.textGap),
              ReviewStars(so: r.stars),
              const SizedBox(height: AppSpacing.textGap),
              Text(phu, style: AppTextStyles.captionSm),
              const SizedBox(height: AppSpacing.itemGap),
              Text(
                r.text,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.stackGap),
              const AppDongKe(),
              const SizedBox(height: AppSpacing.stackGap),
              Text(l10n.phanHoiCuaBan, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.itemGap),
              TextField(
                controller: _noiDung,
                maxLines: 4,
                maxLength: _soKyTuToiDa,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: l10n.hintVietPhanHoi,
                  hintStyle: AppTextStyles.captionSm,
                  counterText: l10n.soKyTuTren(
                    '${_noiDung.text.characters.length}',
                    '$_soKyTuToiDa',
                  ),
                  counterStyle: AppTextStyles.captionSm,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.radius14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              AppButton(
                text: l10n.guiPhanHoi,
                // Phản hồi rỗng thì không có gì để gửi
                enabled: chu.isNotEmpty,
                onTap: () => Navigator.of(context).pop(chu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutDong extends StatelessWidget {
  const _NutDong({required this.onTap});

  static const double _co = 36;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardMint,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: _co,
          height: _co,
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
