import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/storage/locale_storage.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

const List<Shadow> _bongChu = [
  Shadow(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    offset: Offset(0, 4),
    blurRadius: 4,
  ),
];

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _toiThieu = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _moManDau();
  }

  Future<void> _moManDau() async {
    final dich = _manTiepTheo();
    await Future.delayed(_toiThieu);
    final duongDan = await dich;
    if (!mounted) return;
    context.go(duongDan);
  }

  // Chưa chọn ngôn ngữ lần nào là máy mới cài nên đi từ đầu
  Future<String> _manTiepTheo() async {
    try {
      if (await TokenStorageService().hasToken()) return AppRoutes.home;
      final ngonNgu = await const LocaleStorage().readLanguageCode();
      return ngonNgu == null ? AppRoutes.language : AppRoutes.login;
    } catch (e) {
      debugPrint('Không đọc được phiên đã lưu: $e');
      return AppRoutes.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/illustrations/background_splash.svg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                const Spacer(flex: 34),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.all(Radius.circular(26)),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        offset: Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SvgPicture.asset('assets/icons/paw.svg'),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Smart Pet Care',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 30,
                    color: AppColors.textWhite,
                    shadows: _bongChu,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.khauHieuUngDung,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textWhite,
                    shadows: _bongChu,
                  ),
                ),
                const Spacer(flex: 30),
                const SpinKitThreeBounce(
                  color: AppColors.surface,
                  size: 16,
                  duration: Duration(milliseconds: 3000),
                ),
                const Spacer(flex: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
