import 'package:flutter/material.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn Minh chứng, phải có ảnh Sau mới kết thúc được
class SitterEvidenceScreen extends StatefulWidget {
  const SitterEvidenceScreen({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  State<SitterEvidenceScreen> createState() => _SitterEvidenceScreenState();
}

class _SitterEvidenceScreenState extends State<SitterEvidenceScreen> {
  int _tab = 1;
  final _counts = [2, 2, 0, 0];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      '${l10n.anhTruoc} · ${_counts[0]}',
      '${l10n.anhTrong} · ${_counts[1]}',
      '${l10n.anhSau} · ${_counts[2]}',
      l10n.suCo,
    ];
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.minhChungDichVu),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _Chip(
                label: tabs[i],
                selected: i == _tab,
                onTap: () => setState(() => _tab = i),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          Row(
            children: const [
              Expanded(child: _PhotoTile()),
              SizedBox(width: AppSpacing.itemGap),
              Expanded(child: _PhotoTile()),
              SizedBox(width: AppSpacing.itemGap),
              Expanded(child: _AddTile()),
            ],
          ),
          const SizedBox(height: AppSpacing.blockGap),
          AppButton(
            text: l10n.chupAnh,
            icon: Icons.photo_camera_outlined,
            onTap: () => baoDangPhatTrien(context),
          ),
          const SizedBox(height: 8),
          AppButton(
            text: l10n.chonTuThuVien,
            icon: Icons.photo_library_outlined,
            outlined: true,
            color: AppColors.primaryColor,
            onTap: () => baoDangPhatTrien(context),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _NoteBanner(text: l10n.minhChungGhiChu),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryColor : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primaryColor : AppColors.neutralLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? AppColors.textWhite : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AppCard(
        nen: AppColors.cardMint,
        vien: false,
        padding: EdgeInsets.zero,
        child: const Icon(Icons.image_outlined, color: AppColors.primaryColor),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTap: () => baoDangPhatTrien(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutral),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, color: AppColors.primaryColor),
              const SizedBox(height: 4),
              Text(context.l10n.themAnh, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteBanner extends StatelessWidget {
  const _NoteBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.captionSm)),
        ],
      ),
    );
  }
}
