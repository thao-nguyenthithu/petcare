import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/data/grooming_tasks.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _avatar = 44;

class SitterGroomingPackages extends StatelessWidget {
  const SitterGroomingPackages({super.key, required this.goiTungBe});

  final List<GoiGroomingCuaBe> goiTungBe;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.goiDichVuTungBe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final (i, goi) in goiTungBe.indexed) ...[
          if (i != 0) const SizedBox(height: 14),
          Row(
            children: [
              PetAvatar(
                imageUrl: goi.be.avatar,
                name: goi.be.name,
                size: _avatar,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goi.be.name, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      petGiongCan(context, goi.be),
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                groomingPackageName(context, goi.goi),
                style: AppTextStyles.label,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Hạng mục ở màn chi tiết, chỉ đọc và không có ô tick
class GroomingTaskList extends StatelessWidget {
  const GroomingTaskList({super.key, required this.goiTungBe, this.onMoManLam});

  final List<GoiGroomingCuaBe> goiTungBe;
  final VoidCallback? onMoManLam;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tong = goiTungBe.fold(0, (t, goi) => t + goi.hangMuc.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.hangMucCuaDonSo('$tong'), style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final (i, goi) in goiTungBe.indexed) ...[
          if (i != 0) const SizedBox(height: 12),
          Text(
            l10n.beGiongNPhut(
              goi.be.name,
              petLoaiGiong(context, goi.be),
              '${goi.phut}',
            ),
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 3),
          Text(
            dongHangMucGrooming(context, goi.hangMuc),
            style: AppTextStyles.captionSm,
          ),
        ],
        if (onMoManLam case final mo?) ...[
          const SizedBox(height: 14),
          InkWell(
            onTap: mo,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    l10n.moManDangLam,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Hạng mục cần làm ở màn tác nghiệp, có avatar và dòng tô xanh
class GroomingTasksToDo extends StatelessWidget {
  const GroomingTasksToDo({
    super.key,
    required this.goiTungBe,
    this.tieuDe,
    this.coAvatar = true,
  });

  final List<GoiGroomingCuaBe> goiTungBe;
  final String? tieuDe;
  final bool coAvatar;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tieuDe case final t?) ...[
          Text(t, style: AppTextStyles.h3),
          const SizedBox(height: 14),
        ],
        for (final (i, goi) in goiTungBe.indexed) ...[
          if (i != 0) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coAvatar)
                PetAvatar(
                  imageUrl: goi.be.avatar,
                  name: goi.be.name,
                  size: _avatar,
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.check_circle,
                    size: 20,
                    color: AppColors.primaryColor,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.beGiongNPhut(
                        goi.be.name,
                        petLoaiGiong(context, goi.be),
                        '${goi.phut}',
                      ),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dongHangMucGrooming(context, goi.hangMuc),
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
