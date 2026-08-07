import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/features/booking/providers/payment_provider.dart';
import 'package:petcare_app/features/booking/widgets/payment_result_card.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

class _HoiHuyDialog extends StatelessWidget {
  const _HoiHuyDialog({required this.args});

  final PaymentResultArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = args.draft;
    final gio = draft.gio?.nhan ?? '';
    final ngay = draft.ngay == null ? '' : ngayThang(draft.ngay!);
    final donVi = switch (draft.loai) {
      ServiceType.boarding => l10n.soDemNhan('${draft.soDem}'),
      ServiceType.walking => l10n.nPhut('${draft.phutMotLuot ?? 0}'),
      ServiceType.grooming => l10n.nPhut('${draft.phutGrooming}'),
    };
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.chacMuonHuyDonNay, style: AppTextStyles.h3),
            const SizedBox(height: 14),
            AppCard(
              width: double.infinity,
              nen: AppColors.background,
              vien: false,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moTaDichVuDraft(context, draft),
                    style: AppTextStyles.label,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${l10n.nguoiCham} ${draft.sitter.fullName}',
                    style: AppTextStyles.captionSm,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    moTaThoiGianDraft(context, draft),
                    style: AppTextStyles.captionSm,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$donVi · ${l10n.soBe('${draft.pets.length}')} · '
                    '${dinhDangTien(draft.tongTien)}đ',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.khungGioSeNhaNgay(gio, ngay),
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: l10n.thuLaiThanhToan,
              height: 48,
              onTap: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  l10n.thoatKhongDatNua,
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentResultButtons extends ConsumerWidget {
  const PaymentResultButtons({
    super.key,
    required this.args,
    required this.con,
  });

  final PaymentResultArgs args;
  final Duration con;

  Future<void> _hoiHuy(BuildContext context, WidgetRef ref) async {
    final chon = await showDialog<bool>(
      context: context,
      builder: (_) => _HoiHuyDialog(args: args),
    );
    if (chon == null || !context.mounted) return;
    if (chon) {
      await _boGiuCho(context, ref);
    } else {
      _thuLai(context);
    }
  }

  void _thuLai(BuildContext context) {
    context.pushReplacement(AppRoutes.bookingProcessing, extra: args);
  }

  Future<void> _boGiuCho(BuildContext context, WidgetRef ref) async {
    final id = args.don?.id;
    if (id != null) {
      final draft = args.draft;
      try {
        await ref.read(paymentProvider.notifier).boGiuCho(id, draft.sitter.id, [
          for (final be in draft.pets) be.id,
        ]);
      } catch (_) {}
    }
    if (!context.mounted) return;
    _boLuongDatLich(context);
  }

  void _boLuongDatLich(BuildContext context) {
    for (var i = 0; i < 4 && context.canPop(); i++) {
      context.pop();
    }
  }

  // Đơn vừa tạo nên mở thẳng chi tiết; màn chi tiết tự tải theo id
  void _moChiTietDon(BuildContext context) {
    final id = args.don?.id;
    if (id == null) {
      baoDangPhatTrien(context);
      return;
    }
    context.push(AppRoutes.bookingDetail, extra: id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (!args.thanhCong) {
      final hetGio = con == Duration.zero;
      return Column(
        children: [
          if (hetGio)
            AppButton(
              text: l10n.chonGioKhac,
              color: AppColors.accent,
              onTap: () {
                context.pop();
                if (context.canPop()) context.pop();
              },
            )
          else
            AppButton(
              text: l10n.thuLaiThanhToan,
              color: AppColors.accent,
              onTap: () => _thuLai(context),
            ),
          const SizedBox(height: 6),
          TextButton(
            // Hết giờ thì khung đã nhả, không còn gì để mất nên thoát thẳng
            onPressed: () =>
                hetGio ? _boLuongDatLich(context) : _hoiHuy(context, ref),
            child: Text(
              l10n.huy,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        AppButton(
          text: l10n.xemChiTietDon,
          color: AppColors.surface,
          mauChu: AppColors.primaryColor,
          onTap: () => _moChiTietDon(context),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text(
            l10n.veTrangChu,
            style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
          ),
        ),
      ],
    );
  }
}
