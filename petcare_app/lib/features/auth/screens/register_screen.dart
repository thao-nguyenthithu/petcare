import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoTenController = TextEditingController();
  final _emailController = TextEditingController();
  final _soDienThoaiController = TextEditingController();
  final _matKhauController = TextEditingController();
  final _xacNhanController = TextEditingController();
  final _xacNhanKey = GlobalKey<FormFieldState<String>>();

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
    if (!_formKey.currentState!.validate()) return;
    // TODO (backend): gọi API đăng ký
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.push(AppRoutes.verifyEmail, extra: _emailController.text.trim());
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
                    controller: _emailController,
                    height: 46,
                    keyboardType: TextInputType.emailAddress,
                    validator: validators.email,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: l10n.soDienThoai,
                    hint: l10n.nhapSoDienThoai,
                    isRequired: true,
                    controller: _soDienThoaiController,
                    height: 46,
                    keyboardType: TextInputType.phone,
                    validator: validators.phoneNumber,
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
