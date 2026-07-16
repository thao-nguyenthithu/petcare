import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';
import 'package:petcare_app/features/auth/services/auth_error_mapper.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({super.key, required this.resetToken});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matKhauMoiController = TextEditingController();
  final _xacNhanController = TextEditingController();
  final _xacNhanKey = GlobalKey<FormFieldState<String>>();

  @override
  void dispose() {
    _matKhauMoiController.dispose();
    _xacNhanController.dispose();
    super.dispose();
  }

  Future<void> _datLai() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref
          .read(authProvider.notifier)
          .resetPassword(
            resetToken: widget.resetToken,
            newPassword: _matKhauMoiController.text,
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mapAuthError(context.l10n, e))));
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.datLaiMatKhauThanhCong)),
    );
    context.go(AppRoutes.login);
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
                  const SizedBox(height: 46),
                  Text(l10n.datLaiMatKhau, style: AppTextStyles.h1),
                  const SizedBox(height: 8),
                  Text(l10n.taoMatKhauMoi, style: AppTextStyles.caption),
                  const SizedBox(height: 32),
                  AppTextField(
                    label: l10n.matKhauMoi,
                    hint: l10n.toiThieu6KyTu,
                    controller: _matKhauMoiController,
                    isPassword: true,
                    validator: validators.password,
                    onChanged: (_) {
                      if (_xacNhanController.text.isNotEmpty) {
                        _xacNhanKey.currentState?.validate();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: l10n.xacNhanMatKhau,
                    hint: l10n.nhapLaiMatKhau,
                    fieldKey: _xacNhanKey,
                    controller: _xacNhanController,
                    isPassword: true,
                    validator: (giaTri) => validators.confirmPassword(
                      giaTri,
                      _matKhauMoiController.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.dungChuHoaThuongSo, style: AppTextStyles.caption),
                  const SizedBox(height: 36),
                  AppButton(
                    text: l10n.datLaiMatKhau,
                    height: 56,
                    onTapAsync: _datLai,
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
