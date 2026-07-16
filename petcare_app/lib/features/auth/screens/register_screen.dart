import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _xacNhanController = TextEditingController();
  final _xacNhanKey = GlobalKey<FormFieldState<String>>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _soDienThoaiKey = GlobalKey<FormFieldState<String>>();

  // Lỗi từ server gắn với từng ô, hiện ngay dưới ô đó qua validator
  String? _emailServerError;
  String? _soDienThoaiServerError;

  @override
  void dispose() {
    _hoTenController.dispose();
    _emailController.dispose();
    _soDienThoaiController.dispose();
    _matKhauController.dispose();
    _xacNhanController.dispose();
    super.dispose();
  }

  Future<void> _dangKy() async {
    setState(() {
      _emailServerError = null;
      _soDienThoaiServerError = null;
    });
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(authProvider.notifier)
          .register(
            fullName: _hoTenController.text.trim(),
            email: _emailController.text.trim(),
            phone: _soDienThoaiController.text.trim(),
            password: _matKhauController.text,
          );
    } catch (e) {
      if (!mounted) return;
      _xuLyLoi(e);
      return;
    }
    if (!mounted) return;
    context.push(AppRoutes.verifyEmail, extra: _emailController.text.trim());
  }

  void _xuLyLoi(Object e) {
    switch (AuthApiService.codeFromError(e)) {
      case 'EMAIL_ALREADY_USED':
        setState(() => _emailServerError = context.l10n.loiEmailDaSuDung);
        _emailKey.currentState?.validate();
        return;
      case 'PHONE_ALREADY_USED':
        setState(
          () => _soDienThoaiServerError = context.l10n.loiSoDienThoaiDaSuDung,
        );
        _soDienThoaiKey.currentState?.validate();
        return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mapAuthError(context.l10n, e))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final validators = Validators(l10n);
    return Scaffold(
      backgroundColor: AppColors.surface,
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
                  const SizedBox(height: 16),
                  Text(
                    l10n.dangKyTaiKhoan,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.thamGiaCongDong,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: l10n.hoVaTen,
                    hint: l10n.nhapHoVaTen,
                    isRequired: true,
                    controller: _hoTenController,
                    height: 46,
                    validator: validators.fullName,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.email,
                    hint: l10n.nhapEmail,
                    isRequired: true,
                    fieldKey: _emailKey,
                    controller: _emailController,
                    height: 46,
                    keyboardType: TextInputType.emailAddress,
                    validator: (giaTri) =>
                        validators.email(giaTri) ?? _emailServerError,
                    onChanged: (_) {
                      if (_emailServerError != null) {
                        setState(() => _emailServerError = null);
                        _emailKey.currentState?.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.soDienThoai,
                    hint: l10n.nhapSoDienThoai,
                    isRequired: true,
                    fieldKey: _soDienThoaiKey,
                    controller: _soDienThoaiController,
                    height: 46,
                    keyboardType: TextInputType.phone,
                    validator: (giaTri) =>
                        validators.phoneNumber(giaTri) ??
                        _soDienThoaiServerError,
                    onChanged: (_) {
                      if (_soDienThoaiServerError != null) {
                        setState(() => _soDienThoaiServerError = null);
                        _soDienThoaiKey.currentState?.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.matKhau,
                    hint: l10n.toiThieu6KyTu,
                    isRequired: true,
                    controller: _matKhauController,
                    height: 46,
                    isPassword: true,
                    validator: validators.password,
                    onChanged: (_) {
                      if (_xacNhanController.text.isNotEmpty) {
                        _xacNhanKey.currentState?.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.xacNhanMatKhau,
                    hint: l10n.nhapLaiMatKhau,
                    isRequired: true,
                    fieldKey: _xacNhanKey,
                    controller: _xacNhanController,
                    height: 46,
                    isPassword: true,
                    validator: (giaTri) => validators.confirmPassword(
                      giaTri,
                      _matKhauController.text,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(text: l10n.dangKy, onTapAsync: _dangKy),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Text.rich(
                        TextSpan(
                          text: '${l10n.daCoTaiKhoan} ',
                          style: AppTextStyles.caption,
                          children: [
                            TextSpan(
                              text: l10n.dangNhap,
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
    );
  }
}
