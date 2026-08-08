import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/payment_session.dart';
import 'package:petcare_app/features/booking/providers/payment_provider.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';

// Cổng thanh toán giả lập, chỉ mở khi server chạy PAYMENT_GATEWAY=mock
class MockPaymentScreen extends ConsumerWidget {
  const MockPaymentScreen({super.key, required this.phien});

  final PaymentSession phien;

  int get _soTien {
    final so = Uri.parse(phien.payUrl).queryParameters['soTien'];
    return int.tryParse(so ?? '') ?? 0;
  }

  Future<void> _ban(BuildContext context, WidgetRef ref, bool thanhCong) async {
    await showAppLoading(
      context,
      () => ref
          .read(paymentProvider.notifier)
          .banCongGiaLap(
            txnRef: phien.txnRef,
            thanhCong: thanhCong,
            soTien: _soTien,
          ),
    );
    if (!context.mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.congThanhToanGiaLap,
                textAlign: TextAlign.center,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.moTaCongGiaLap,
                textAlign: TextAlign.center,
                style: AppTextStyles.captionSm,
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.radius14),
                  border: Border.all(color: AppColors.neutral),
                ),
                child: Column(
                  children: [
                    Text('${dinhDangTien(_soTien)}đ', style: AppTextStyles.h2),
                    const SizedBox(height: 6),
                    Text(
                      l10n.maGiaoDichNhan(phien.txnRef),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              AppButton(
                text: l10n.traTienThanhCong,
                onTap: () => _ban(context, ref, true),
              ),
              const SizedBox(height: 10),
              AppButton(
                text: l10n.traTienThatBai,
                color: AppColors.accent,
                onTap: () => _ban(context, ref, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
