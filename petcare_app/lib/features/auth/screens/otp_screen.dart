import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/auth/widgets/otp_input.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  static const int _thoiGianCho = 30;
  int _secondsLeft = _thoiGianCho;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    _secondsLeft = _thoiGianCho;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _guiLaiMa() async {
    // TODO (backend): gọi API gửi lại mã OTP
    await showAppLoading(
      context,
      () => Future.delayed(const Duration(seconds: 1)),
    );
    if (!mounted) return;
    setState(_startCountdown);
  }

  void _baoThieuMa() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.vuiLongNhapDu6So)));
  }

  Future<void> _xacNhan() async {
    // TODO (backend): gọi API kiểm tra mã OTP
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    context.push(AppRoutes.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final duMa = _otpController.text.length >= 6;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                const SizedBox(height: 56),
                Text(
                  l10n.xacMinhOtp,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.nhapMa6SoCuaBan,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 56),
                OtpInput(
                  controller: _otpController,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 34),
                Center(
                  child: _secondsLeft > 0
                      ? Text(
                          '${l10n.khongNhanDuocMa} '
                          '${l10n.guiLaiSauGiay('$_secondsLeft')}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption,
                        )
                      : GestureDetector(
                          onTap: _guiLaiMa,
                          child: Text(
                            l10n.guiLaiMa,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 60),
                AppButton(
                  text: l10n.xacNhan,
                  height: 56,
                  onTap: duMa ? null : _baoThieuMa,
                  onTapAsync: duMa ? _xacNhan : null,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
