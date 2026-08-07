import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/schedule_text_link.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';

// Điều kiện lọc lịch của ngày đang chọn
class ScheduleFilter {
  const ScheduleFilter({this.trangThai = const {}, this.loaiDichVu = const {}});

  final Set<ScheduleApptStatus> trangThai;
  final Set<ServiceType> loaiDichVu;

  bool get coLoc => trangThai.isNotEmpty || loaiDichVu.isNotEmpty;

  bool khop(ScheduleAppointment appt) =>
      (trangThai.isEmpty || trangThai.contains(appt.status)) &&
      (loaiDichVu.isEmpty || loaiDichVu.contains(appt.serviceType));
}

String nhanTrangThai(AppLocalizations l10n, ScheduleApptStatus tt) =>
    switch (tt) {
      ScheduleApptStatus.sapToi => l10n.sapToi,
      ScheduleApptStatus.dangDienRa => l10n.dangDienRa,
      ScheduleApptStatus.choXacNhan => l10n.trangThaiChoXacNhan,
      ScheduleApptStatus.hoanThanh => l10n.hoanThanh,
    };

Future<ScheduleFilter?> showScheduleFilterSheet(
  BuildContext context,
  ScheduleFilter hienTai,
) {
  return showModalBottomSheet<ScheduleFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _ScheduleFilterSheet(hienTai: hienTai),
  );
}

class _ScheduleFilterSheet extends StatefulWidget {
  const _ScheduleFilterSheet({required this.hienTai});

  final ScheduleFilter hienTai;

  @override
  State<_ScheduleFilterSheet> createState() => _ScheduleFilterSheetState();
}

class _ScheduleFilterSheetState extends State<_ScheduleFilterSheet> {
  late final Set<ScheduleApptStatus> _trangThai = {...widget.hienTai.trangThai};
  late final Set<ServiceType> _loai = {...widget.hienTai.loaiDichVu};

  void _doiChon<T>(Set<T> tap, T gia) => setState(() {
    tap.contains(gia) ? tap.remove(gia) : tap.add(gia);
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dayHeThong = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        AppSpacing.stackGap,
        AppSpacing.screenPaddingWide,
        AppSpacing.groupGap + dayHeThong,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.boLoc, style: AppTextStyles.h3)),
              ScheduleTextLink(
                nhan: l10n.datLai,
                onTap: () => setState(() {
                  _trangThai.clear();
                  _loai.clear();
                }),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.labelGap),
          _NhomChip(
            tieuDe: l10n.trangThai,
            nhanTatCa: l10n.tatCa,
            chonTatCa: _trangThai.isEmpty,
            onTatCa: () => setState(_trangThai.clear),
            chips: [
              for (final tt in ScheduleApptStatus.values)
                (
                  nhanTrangThai(l10n, tt),
                  _trangThai.contains(tt),
                  () => _doiChon(_trangThai, tt),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _NhomChip(
            tieuDe: l10n.loaiDichVu,
            nhanTatCa: l10n.tatCa,
            chonTatCa: _loai.isEmpty,
            onTatCa: () => setState(_loai.clear),
            chips: [
              for (final loai in ServiceType.values)
                (
                  serviceTypeNameDai(context, loai),
                  _loai.contains(loai),
                  () => _doiChon(_loai, loai),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.groupGap),
          AppButton(
            text: l10n.apDung,
            onTap: () => Navigator.pop(
              context,
              ScheduleFilter(
                trangThai: {..._trangThai},
                loaiDichVu: {..._loai},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Một nhóm lọc
class _NhomChip extends StatelessWidget {
  const _NhomChip({
    required this.tieuDe,
    required this.nhanTatCa,
    required this.chonTatCa,
    required this.onTatCa,
    required this.chips,
  });

  final String tieuDe;
  final String nhanTatCa;
  final bool chonTatCa;
  final VoidCallback onTatCa;
  final List<(String, bool, VoidCallback)> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.labelGap),
        Wrap(
          spacing: AppSpacing.labelGap,
          runSpacing: AppSpacing.labelGap,
          children: [
            AppFilterChip(
              label: nhanTatCa,
              selected: chonTatCa,
              onTap: onTatCa,
            ),
            for (final (label, chon, onTap) in chips)
              AppFilterChip(label: label, selected: chon, onTap: onTap),
          ],
        ),
      ],
    );
  }
}
