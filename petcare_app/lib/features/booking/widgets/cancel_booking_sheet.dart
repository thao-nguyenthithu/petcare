import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

enum KhaNangHuy { duoc, dangDienRa, daXuatPhat }

KhaNangHuy kiemTraHuy({required bool dangDienRa, required bool daXuatPhat}) {
  if (dangDienRa) return KhaNangHuy.dangDienRa;
  return daXuatPhat ? KhaNangHuy.daXuatPhat : KhaNangHuy.duoc;
}

class CancelBookingTarget {
  const CancelBookingTarget({
    required this.maDon,
    required this.tenDichVu,
    required this.thuCung,
    required this.chuNuoi,
    required this.moTaThoiGian,
  });

  final String maDon;
  final String tenDichVu;
  final String thuCung;
  final String chuNuoi;
  final String moTaThoiGian;
}

enum LyDoHuyDon { omDotXuat, banViecGap, trungLich, khac }

extension LyDoHuyDonX on LyDoHuyDon {
  String get ma => switch (this) {
    LyDoHuyDon.omDotXuat => 'OM_DOT_XUAT',
    LyDoHuyDon.banViecGap => 'BAN_VIEC_GAP',
    LyDoHuyDon.trungLich => 'TRUNG_LICH',
    LyDoHuyDon.khac => 'KHAC',
  };

  String nhan(AppLocalizations l10n) => switch (this) {
    LyDoHuyDon.omDotXuat => l10n.lyDoOmDotXuat,
    LyDoHuyDon.banViecGap => l10n.lyDoBanViecGap,
    LyDoHuyDon.trungLich => l10n.lyDoTrungLich,
    LyDoHuyDon.khac => l10n.lyDoKhac,
  };
}

typedef LyDoHuy = ({LyDoHuyDon lyDo, String moTa});

Future<LyDoHuy?> showCancelBookingSheet(
  BuildContext context,
  CancelBookingTarget don,
) {
  return showModalBottomSheet<LyDoHuy>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CancelBookingSheet(don: don),
  );
}

class _CancelBookingSheet extends StatefulWidget {
  const _CancelBookingSheet({required this.don});

  final CancelBookingTarget don;

  @override
  State<_CancelBookingSheet> createState() => _CancelBookingSheetState();
}

class _CancelBookingSheetState extends State<_CancelBookingSheet> {
  final TextEditingController _moTa = TextEditingController();
  LyDoHuyDon? _lyDo;

  bool get _laLyDoKhac => _lyDo == LyDoHuyDon.khac;

  @override
  void dispose() {
    _moTa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    final duocHuy =
        _lyDo != null && (!_laLyDoKhac || _moTa.text.trim().isNotEmpty);
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
            Text(l10n.huyDonTitle, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(l10n.huyDonMoTa, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.stackGap),
            _TomTatDon(don: widget.don),
            const SizedBox(height: AppSpacing.stackGap),
            Text(l10n.lyDoHuy, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.labelGap),
            Wrap(
              spacing: AppSpacing.labelGap,
              runSpacing: AppSpacing.labelGap,
              children: [
                for (final ly in LyDoHuyDon.values)
                  AppFilterChip(
                    label: ly.nhan(l10n),
                    selected: _lyDo == ly,
                    onTap: () => setState(() => _lyDo = ly),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.itemGap),
            AppTextField(
              label: _laLyDoKhac ? l10n.moTaHuyBatBuoc : l10n.moTaHuyTuyChon,
              hint: l10n.moTaHuyHint,
              controller: _moTa,
              isRequired: _laLyDoKhac,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.stackGap),
            Container(
              padding: const EdgeInsets.all(AppSpacing.itemGap),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Expanded(
                    child: Text(
                      l10n.canhBaoHuyDon,
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: l10n.huyDon,
              color: AppColors.accent,
              enabled: duocHuy,
              onTap: () => Navigator.pop(context, (
                lyDo: _lyDo!,
                moTa: _moTa.text.trim(),
              )),
            ),
            const SizedBox(height: AppSpacing.labelGap),
            AppButton(
              text: l10n.giuDon,
              flat: true,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TomTatDon extends StatelessWidget {
  const _TomTatDon({required this.don});

  final CancelBookingTarget don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      nen: AppColors.cardMint,
      vien: false,
      padding: const EdgeInsets.all(AppSpacing.itemGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${don.tenDichVu} · ${don.thuCung}',
                  style: AppTextStyles.label,
                ),
              ),
              Text(
                l10n.maDonNgan(don.maDon),
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.textGap),
          _Dong(icon: Icons.schedule, chu: don.moTaThoiGian),
          const SizedBox(height: 2),
          _Dong(icon: Icons.person_outline, chu: don.chuNuoi),
        ],
      ),
    );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({required this.icon, required this.chu});

  final IconData icon;
  final String chu;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryColor),
        const SizedBox(width: AppSpacing.textGap),
        Expanded(
          child: Text(
            chu,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
