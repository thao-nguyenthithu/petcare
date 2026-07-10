import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/l10n/locale_provider.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/core/router/app_router.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              'assets/illustrations/background_top.svg',
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset('assets/icons/paw_white.svg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      context.l10n.tenUngDung,
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        const Text('Chọn ngôn ngữ', style: AppTextStyles.h2),
                        const SizedBox(height: 6),
                        const Text(
                          'Select your language',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 2 thẻ ngôn ngữ
                  _LanguageTile(
                    flag: 'assets/icons/vn.svg',
                    title: 'Tiếng Việt',
                    subtitle: 'Vietnamese',
                    selected: lang == 'vi',
                    onTap: () =>
                        ref.read(localeProvider.notifier).setLocale('vi'),
                  ),
                  const SizedBox(height: 16),
                  _LanguageTile(
                    flag: 'assets/icons/gb.svg',
                    title: 'English',
                    subtitle: 'Tiếng Anh',
                    selected: lang == 'en',
                    onTap: () =>
                        ref.read(localeProvider.notifier).setLocale('en'),
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.doiLaiTrongCaiDat,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                  // Nút Tiếp tục
                  AppButton(
                    text: context.l10n.tiepTuc,
                    onTap: () => context.push(AppRoutes.onboarding),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardMint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(
            color: selected ? AppColors.primaryColor : AppColors.neutral,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SvgPicture.asset(flag, width: 60),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.caption),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryColor : AppColors.surface,
                shape: BoxShape.circle,
                border: selected
                    ? null
                    : Border.all(color: AppColors.neutral, width: 2),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.textWhite,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
