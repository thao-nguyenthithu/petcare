import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/page_dots.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _denTrang(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Nội dung 3 trang
    final pages = [
      _OnboardingPageData(
        illustration: 'assets/illustrations/Ob_welcome.svg',
        titleLine1: l10n.chaoMungDen,
        titleLine2: l10n.tenUngDung,
        subtitle: l10n.thuCungVui,
        description: l10n.ketNoiNguoiChamSoc,
        showPaw: false,
      ),
      _OnboardingPageData(
        illustration: 'assets/illustrations/Ob_trustedCare.svg',
        titleLine1: l10n.chamSoc,
        titleLine2: l10n.tinCay,
        subtitle: l10n.minhBachAnhGps,
        description: l10n.nguoiCungCapXacMinh,
        showPaw: true,
      ),
      _OnboardingPageData(
        illustration: 'assets/illustrations/Ob_vaccin.svg',
        titleLine1: l10n.theoDoi,
        titleLine2: l10n.sucKhoe,
        subtitle: l10n.hoSoNhacLich,
        description: l10n.lichSuDichVu,
        showPaw: true,
      ),
    ];
    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hàng điều hướng trên
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        if (_currentPage > 0) {
                          _denTrang(_currentPage - 1);
                        } else {
                          context.pop();
                        }
                      },
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 24,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.login),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        l10n.boQua,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 15,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _OnboardingPage(data: pages[index]),
              ),
            ),
            // Dots báo trang hiện tại
            PageDots(count: pages.length, current: _currentPage),
            const Flexible(child: SizedBox(height: 88)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                height: 56,
                text: isLastPage ? l10n.batDauNgay : l10n.tiepTuc,
                onTap: () {
                  if (isLastPage) {
                    context.push(AppRoutes.login);
                  } else {
                    _denTrang(_currentPage + 1);
                  }
                },
              ),
            ),
            const Flexible(child: SizedBox(height: 64)),
          ],
        ),
      ),
    );
  }
}

// Dữ liệu 1 trang onboarding
class _OnboardingPageData {
  final String illustration;
  final String titleLine1;
  final String titleLine2;
  final String subtitle;
  final String description;
  final bool showPaw;

  const _OnboardingPageData({
    required this.illustration,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
    required this.description,
    required this.showPaw,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Flexible(child: SizedBox(height: 62)),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 280,
                padding: const EdgeInsets.fromLTRB(26, 58, 26, 0),
                decoration: BoxDecoration(
                  color: AppColors.cardMint,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(45, 138, 110, 0.12),
                      offset: Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.titleLine1, style: AppTextStyles.h1),
                    Text(
                      data.titleLine2,
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 170,
                      child: Text(data.subtitle, style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ),
              if (data.showPaw)
                Positioned(
                  top: 26,
                  right: 20,
                  child: SvgPicture.asset('assets/icons/paw.svg', width: 22),
                ),
              // Minh họa phủ nửa dưới card, tràn nhẹ ra ngoài viền
              Positioned(
                left: -41,
                right: -27,
                bottom: -20,
                child: SvgPicture.asset(
                  data.illustration,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const Flexible(child: SizedBox(height: 70)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data.description,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
