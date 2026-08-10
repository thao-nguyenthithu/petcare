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
import 'package:petcare_app/features/auth/services/auth_error_mapper.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Máy chủ luôn trả cùng một câu bất kể email có tài khoản hay không (bộ luật mục 12)
  Future<void> _guiMa() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    try {
      await ref.read(authProvider.notifier).forgotPassword(email);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapAuthError(context.l10n, e))));
      return;
    }
    if (!mounted) return;
    context.push(AppRoutes.otp, extra: email);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: AppBackButton(),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.cardMint,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/icon_forgot_password.svg',
                          width: 49,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    l10n.quenMatKhau,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.nhapEmailDaDangKy,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: l10n.email,
                    hint: l10n.nhapEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: validators.email,
                  ),
                  const SizedBox(height: 44),
                  AppButton(
                    text: l10n.guiMaXacMinh,
                    height: 56,
                    onTapAsync: _guiMa,
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        l10n.quayLaiDangNhap,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
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
    );
  }
}
