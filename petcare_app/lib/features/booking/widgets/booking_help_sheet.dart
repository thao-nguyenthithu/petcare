import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/utils/mo_email_ho_tro.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/dispute_booking_facts.dart';

// Chủ đề giữ MÃ để ghép vào tiêu đề email, không giữ câu
const List<String> _maChuDe = [
  'thanhToanHoanTien',
  'nguoiChamKhongToi',
  'chatLuongDichVu',
  'beGapVanDe',
  'khac',
];

String _nhanChuDe(AppLocalizations l10n, String ma) => switch (ma) {
  'thanhToanHoanTien' => l10n.cdThanhToanHoanTien,
  'nguoiChamKhongToi' => l10n.cdNguoiChamKhongToi,
  'chatLuongDichVu' => l10n.cdChatLuongDichVu,
  'beGapVanDe' => l10n.cdBeGapVanDe,
  _ => l10n.scKhac,
};

// Sheet Trợ giúp cho đơn này, mở từ nút Liên hệ hỗ trợ
Future<void> showBookingHelpSheet(
  BuildContext context,
  OwnerBookingDetail don,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _BookingHelpSheet(don: don),
  );
}

class _BookingHelpSheet extends ConsumerStatefulWidget {
  const _BookingHelpSheet({required this.don});

  final OwnerBookingDetail don;

  @override
  ConsumerState<_BookingHelpSheet> createState() => _BookingHelpSheetState();
}

class _BookingHelpSheetState extends ConsumerState<_BookingHelpSheet> {
  String? _chuDe;

  Future<void> _guiEmail() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final chuDe = _chuDe == null ? '' : ' - ${_nhanChuDe(l10n, _chuDe!)}';
    final loi = await moEmailHoTro(
      context,
      ref,
      chuDe: l10n.tieuDeEmailHoTroDon(widget.don.maDon) + chuDe,
    );
    if (loi != null) {
      messenger.showSnackBar(SnackBar(content: Text(loi)));
      return;
    }
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = widget.don;
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.groupGap + mq.viewPadding.bottom + mq.viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.troGiupChoDonNay, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.stackGap),
            DisputeBookingFacts(
              tenDichVu: don.tenDichVu,
              maDon: don.maDon,
              tenBe: [for (final be in don.pets) be.name],
              nhanDoiPhuong: l10n.nguoiCham,
              tenDoiPhuong: don.tenNcc,
              thoiGian: don.moTaThoiGian,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            Text(l10n.banCanHoTroViecGi, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.labelGap),
            Wrap(
              spacing: AppSpacing.labelGap,
              runSpacing: AppSpacing.labelGap,
              children: [
                for (final ma in _maChuDe)
                  AppFilterChip(
                    label: _nhanChuDe(l10n, ma),
                    selected: _chuDe == ma,
                    onTap: () => setState(() => _chuDe = ma),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.stackGap),
            Text(l10n.slaHoTro, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: l10n.guiEmailChoHoTro,
              height: 50,
              onTap: _guiEmail,
            ),
          ],
        ),
      ),
    );
  }
}
