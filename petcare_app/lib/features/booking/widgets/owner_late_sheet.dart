import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';

// Chủ nuôi trông giữ chậm chân hơn người chăm đi làm nên mức trễ thưa hơn
const List<int> _mucBaoMuon = [15, 30, 60];

// Chủ nuôi đơn trông giữ báo tới muộn, chọn số phút so với giờ hẹn
Future<void> showOwnerLateSheet(
  BuildContext context,
  WidgetRef ref,
  OwnerBookingDetail don,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final phut = await showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              don.dangDiDonBe || don.laNgayCuoiKy
                  ? sheetContext.l10n.toiToiDonMuon
                  : sheetContext.l10n.toiMangBeToiMuon,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppSpacing.textGap),
            Text(
              sheetContext.l10n.baoMuonChuNuoiMoTa,
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            for (final phut in _mucBaoMuon) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext, phut),
                  child: Text(sheetContext.l10n.nPhutNhan('$phut')),
                ),
              ),
              const SizedBox(height: AppSpacing.labelGap),
            ],
          ],
        ),
      ),
    ),
  );
  if (phut == null || !context.mounted) return;
  try {
    await BookingsApiService().baoMuon(don.id, phut: phut);
    ref.refreshBookingData();
    messenger.showSnackBar(SnackBar(content: Text(l10n.daBaoChoNguoiCham)));
  } catch (loi) {
    messenger.showSnackBar(
      SnackBar(content: Text(messageFromError(loi) ?? l10n.loiKetNoiMayChu)),
    );
  }
}
