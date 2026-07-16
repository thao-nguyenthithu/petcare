import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/features/auth/services/auth_error_mapper.dart';
import 'package:petcare_app/features/auth/widgets/otp_input.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  String? _otpError;
  Timer? _timer;
  static const int _thoiGianCho = 30;
  int _secondsLeft = _thoiGianCho;
  Timer? _lockTimer;
  int _lockSecondsLeft = 0;
  bool get _daKhoa => _lockSecondsLeft > 0;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lockTimer?.cancel();
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

  String _formatTime(int seconds) =>
      '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  Future<void> _guiLaiMa() async {
    try {
      await showAppLoading(
        context,
        () => ref.read(authProvider.notifier).forgotPassword(widget.email),
      );
    } catch (e) {
      if (!mounted) return;
      _baoLoi(e);
      return;
    }
    if (!mounted) return;
    setState(_startCountdown);
  }

  void _baoLoi(Object e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mapAuthError(context.l10n, e))));
  }

  void _baoThieuMa() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.vuiLongNhapDu6So)));
  }

  Future<void> _xacNhan() async {
    final String resetToken;
    try {
      resetToken = await ref
          .read(authProvider.notifier)
          .verifyResetOtp(email: widget.email, otp: _otpController.text);
    } catch (e) {
      if (!mounted) return;
      _xuLyLoi(e);
      return;
    }
    if (!mounted) return;
    context.push(AppRoutes.resetPassword, extra: resetToken);
  }

  void _xuLyLoi(Object e) {
    final code = AuthApiService.codeFromError(e);
    if (code == 'OTP_LOCKED') {
      final giay = AuthApiService.metaInt(e, 'seconds') ?? 300;
      final soLan = AuthApiService.metaInt(e, 'attempts') ?? 5;
      _startLockCountdown(giay, context.l10n.loiNhapSaiQuaSoLan(soLan));
      return;
    }
    if (code != null && code.startsWith('OTP_')) {
      setState(() => _otpError = mapAuthError(context.l10n, e));
      return;
    }
    _baoLoi(e);
  }

  void _startLockCountdown(int seconds, String lyDo) {
    _lockTimer?.cancel();
    setState(() {
      _otpError = lyDo;
      _lockSecondsLeft = seconds;
    });
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _lockSecondsLeft--;
        if (_lockSecondsLeft <= 0) {
          timer.cancel();
          _otpError = null;
        }
      });
    });
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
                  hasError: _otpError != null || _daKhoa,
                  onChanged: (_) => setState(() {
                    if (!_daKhoa) _otpError = null;
                  }),
                ),
                if (_otpError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _otpError!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 34),
                Center(
                  child: _daKhoa
                      ? Text(
                          l10n.vuiLongThuLaiSau(_formatTime(_lockSecondsLeft)),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                          ),
                        )
                      : _secondsLeft > 0
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
                  enabled: !_daKhoa,
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
