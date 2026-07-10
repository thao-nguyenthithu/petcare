import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _matKhauController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _matKhauController.dispose();
    super.dispose();
  }

  void _dangNhap() {
    if (_formKey.currentState!.validate()) {
      // TODO (backend): gọi API đăng nhập
    }
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
                        controller: _matKhauController,
                        isPassword: true,
                        validator: validators.password,
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // TODO (router): chuyển sang màn Quên mật khẩu (A0.9)
                          },
                          child: Text(
                            l10n.quenMatKhau,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppButton(text: l10n.dangNhap, onTap: _dangNhap),
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
                              // TODO (backend): đăng nhập Google
                              onPressed: () {},
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
                              // TODO (backend): đăng nhập Facebook
                              onPressed: () {},
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
                          onTap: () {},
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
