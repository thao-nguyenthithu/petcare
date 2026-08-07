import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

Future<bool?> showSitterSwitchSheet(
  BuildContext context, {
  TomTatDonNcc? tomTat,
}) {
  final l10n = context.l10n;
  final coViec = tomTat?.coViecDangCho ?? false;
  return _showSwitchSheet(
    context,
    title: l10n.chuyenSangCheDoNguoiCungCap,
    infoTitle: coViec ? l10n.dangChoOCheDoNCC : null,
    infoSubtitle: coViec ? _dongTomTat(l10n, tomTat!) : null,
    cancelLabel: l10n.oLaiCheDoChuNuoi,
  );
}

String _dongTomTat(AppLocalizations l10n, TomTatDonNcc tomTat) {
  final ve = <String>[
    if (tomTat.soDonCho > 0) l10n.soDonChoXacNhanNcc('${tomTat.soDonCho}'),
    if (tomTat.batDauKe != null)
      l10n.donKeBatDauLuc(_moc(l10n, tomTat.batDauKe!)),
  ];
  return ve.join(' · ');
}

String _moc(AppLocalizations l10n, DateTime d) =>
    cungNgay(d, homNayVn()) ? gioPhut(d) : nhanThoiDiemNgan(l10n, d);

Future<bool?> showOwnerSwitchSheet(BuildContext context) {
  final l10n = context.l10n;
  return _showSwitchSheet(
    context,
    title: l10n.chuyenSangCheDoChuNuoi,
    infoTitle: l10n.vanNhanDonOCheDoNCC,
    infoSubtitle: l10n.chuyenCheDoKhongNgungNhanDon,
    cancelLabel: l10n.oLaiCheDoNguoiCungCap,
  );
}

// Khung sheet chuyển chế độ dùng chung
Future<bool?> _showSwitchSheet(
  BuildContext context, {
  required String title,
  required String? infoTitle,
  required String? infoSubtitle,
  required String cancelLabel,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.cardMint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h3,
                ),
              ],
            ),
          ),
          if (infoTitle != null && infoSubtitle != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(infoTitle, style: AppTextStyles.label),
                        const SizedBox(height: 3),
                        Text(infoSubtitle, style: AppTextStyles.captionSm),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          AppButton(
            text: l10n.chuyenCheDo,
            onTap: () => Navigator.pop(sheetContext, true),
          ),
          const SizedBox(height: 6),
          AppButton(
            text: cancelLabel,
            flat: true,
            color: AppColors.textSecondary,
            onTap: () => Navigator.pop(sheetContext, false),
          ),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}
