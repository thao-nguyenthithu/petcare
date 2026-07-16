import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/features/auth/services/auth_error_mapper.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _matKhauKey = GlobalKey<FormFieldState<String>>();

  String? _serverError;

  @override
  void dispose() {
    _emailController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  Future<void> _dangNhap() async {
    setState(() => _serverError = null);
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(authProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _matKhauController.text,
          );
    } catch (e) {
      if (!mounted) return;
      _xuLyLoiDangNhap(e);
      return;
    }
    if (!mounted) return;
    _vaoTrangChu();
  }

  void _xuLyLoiDangNhap(Object e) {
    final l10n = context.l10n;
    switch (AuthApiService.codeFromError(e)) {
      case 'INVALID_CREDENTIALS':
        setState(() => _serverError = l10n.loiThongTinDangNhap);
        _matKhauKey.currentState?.validate();
        return;
      case 'EMAIL_NOT_VERIFIED':
        context.push(
          AppRoutes.verifyEmail,
          extra: _emailController.text.trim(),
        );
        return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mapAuthError(l10n, e))));
  }

  Future<void> _dangNhapGoogle() =>
      _dangNhapMangXaHoi(ref.read(authProvider.notifier).loginGoogle);

  Future<void> _dangNhapFacebook() =>
      _dangNhapMangXaHoi(ref.read(authProvider.notifier).loginFacebook);

  Future<void> _dangNhapMangXaHoi(Future<bool> Function() dangNhap) async {
    setState(() => _serverError = null);
    try {
      final thanhCong = await showAppLoading(context, dangNhap);
      if (!thanhCong) return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapAuthError(context.l10n, e))));
      return;
    }
    if (!mounted) return;
    _vaoTrangChu();
  }

  void _vaoTrangChu() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      SizedBox(
                        height: 116,
                        child: Stack(
                          children: [
                            const Positioned(
                              top: 12,
                              left: 0,
                              child: AppBackButton(),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 36),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: SvgPicture.asset(
                                      'assets/icons/paw_white.svg',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.dangNhap,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.chaoMungQuayLai,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 36),
                      AppTextField(
                        label: l10n.email,
                        hint: l10n.nhapEmail,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validators.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: l10n.matKhau,
                        hint: l10n.nhapMatKhau,
                        fieldKey: _matKhauKey,
                        controller: _matKhauController,
                        isPassword: true,
                        validator: (giaTri) =>
                            validators.password(giaTri) ?? _serverError,
                        onChanged: (_) {
                          if (_serverError != null) {
                            setState(() => _serverError = null);
                            _matKhauKey.currentState?.validate();
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.forgotPassword),
                          child: Text(
                            l10n.quenMatKhau,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(text: l10n.dangNhap, onTapAsync: _dangNhap),
                      const SizedBox(height: 36),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.neutral,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              l10n.hoac,
                              style: AppTextStyles.caption,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.neutral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Đăng nhập mạng xã hội
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _dangNhapGoogle,
                              icon: SvgPicture.asset(
                                'assets/icons/google.svg',
                                width: 20,
                                height: 20,
                              ),
                              label: Text(l10n.google),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _dangNhapFacebook,
                              icon: SvgPicture.asset(
                                'assets/icons/facebook.svg',
                                width: 20,
                                height: 20,
                              ),
                              label: Text(l10n.facebook),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
                      Center(
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: Text.rich(
                            TextSpan(
                              text: '${l10n.chuaCoTaiKhoan} ',
                              style: AppTextStyles.caption,
                              children: [
                                TextSpan(
                                  text: l10n.dangKyNgay,
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
