import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_booking_filter.dart';
import 'package:petcare_app/shared/widgets/app_segmented_tabs.dart';
import 'package:petcare_app/shared/widgets/month_calendar.dart';
import 'package:petcare_app/shared/widgets/sheet_drag_handle.dart';

// Chọn kỳ theo ngày, tháng hoặc năm, chặn trong khoảng có đơn
Future<KyThongKe?> moSheetChonKy(
  BuildContext context, {
  required KyThongKe ky,
  required Set<DateTime> ngayCoDon,
  required int namDau,
  required int namCuoi,
}) {
  FocusScope.of(context).unfocus();
  return showModalBottomSheet<KyThongKe>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    builder: (_) => _SheetChonKy(
      ky: ky,
      ngayCoDon: ngayCoDon,
      namDau: namDau,
      namCuoi: namCuoi,
    ),
  );
}

class _SheetChonKy extends StatefulWidget {
  const _SheetChonKy({
    required this.ky,
    required this.ngayCoDon,
    required this.namDau,
    required this.namCuoi,
  });

  final KyThongKe ky;

  // Ngày có đơn để lịch chấm sẵn, biết chỗ nào có việc
  final Set<DateTime> ngayCoDon;

  final int namDau;
  final int namCuoi;

  @override
  State<_SheetChonKy> createState() => _SheetChonKyState();
}

class _SheetChonKyState extends State<_SheetChonKy> {
  static const List<LoaiKy> _nac = [LoaiKy.ngay, LoaiKy.thang, LoaiKy.nam];

  late LoaiKy _loai = _nac.contains(widget.ky.loai)
      ? widget.ky.loai
      : LoaiKy.thang;
  late DateTime _moc = widget.ky.mocThuc;

  bool _coDon(DateTime ngay) => widget.ngayCoDon.any((d) => cungNgay(d, ngay));

  bool _trongKhoang(DateTime ngay) =>
      ngay.year >= widget.namDau && ngay.year <= widget.namCuoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.blockGap,
        AppSpacing.labelGap,
        AppSpacing.blockGap,
        0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetDragHandle(),
          const SizedBox(height: AppSpacing.blockGap),
          Text(l10n.chonKy, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.stackGap),
          AppSegmentedTabs(
            labels: [l10n.theoNgay, l10n.theoThang, l10n.theoNam],
            selectedIndex: _nac.indexOf(_loai),
            onChanged: (i) => setState(() => _loai = _nac[i]),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          switch (_loai) {
            // Ngày ngoài khoảng có đơn thì hiện mờ
            LoaiKy.ngay => MonthCalendar(
              choPhep: _trongKhoang,
              laNgayKin: (_) => false,
              nutHomNay: true,
              coCham: _coDon,
              chon: _moc,
              onChon: (ngay) => setState(() => _moc = ngay),
            ),
            LoaiKy.thang => _LuoiThang(
              moc: _moc,
              namDau: widget.namDau,
              namCuoi: widget.namCuoi,
              onChon: (thang) => setState(() => _moc = thang),
            ),
            _ => _LuoiNam(
              moc: _moc,
              namDau: widget.namDau,
              namCuoi: widget.namCuoi,
              onChon: (nam) => setState(() => _moc = nam),
            ),
          },
          const SizedBox(height: AppSpacing.groupGap),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(KyThongKe(_loai, _moc)),
                  child: Text(l10n.xem),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lưới 12 tháng, đổi năm bằng hai mũi tên hai đầu
class _LuoiThang extends StatefulWidget {
  const _LuoiThang({
    required this.moc,
    required this.namDau,
    required this.namCuoi,
    required this.onChon,
  });

  final DateTime moc;
  final int namDau;
  final int namCuoi;
  final ValueChanged<DateTime> onChon;

  @override
  State<_LuoiThang> createState() => _LuoiThangState();
}

class _LuoiThangState extends State<_LuoiThang> {
  late int _nam = widget.moc.year;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _HangNam(
          nam: _nam,
          onLui: _nam > widget.namDau ? () => setState(() => _nam--) : null,
          onToi: _nam < widget.namCuoi ? () => setState(() => _nam++) : null,
        ),
        const SizedBox(height: AppSpacing.itemGap),
        _LuoiO(
          soO: 12,
          nhan: (i) => l10n.thangSo('${i + 1}'),
          chonO: (i) => widget.moc.year == _nam && widget.moc.month == i + 1,
          onChon: (i) => widget.onChon(DateTime(_nam, i + 1)),
        ),
      ],
    );
  }
}

class _LuoiNam extends StatelessWidget {
  const _LuoiNam({
    required this.moc,
    required this.namDau,
    required this.namCuoi,
    required this.onChon,
  });

  final DateTime moc;
  final int namDau;
  final int namCuoi;
  final ValueChanged<DateTime> onChon;

  @override
  Widget build(BuildContext context) {
    return _LuoiO(
      soO: namCuoi - namDau + 1,
      nhan: (i) => '${namCuoi - i}',
      chonO: (i) => moc.year == namCuoi - i,
      onChon: (i) => onChon(DateTime(namCuoi - i)),
    );
  }
}

class _HangNam extends StatelessWidget {
  const _HangNam({required this.nam, this.onLui, this.onToi});

  final int nam;
  final VoidCallback? onLui;
  final VoidCallback? onToi;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onLui,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Text(context.l10n.namSo('$nam'), style: AppTextStyles.label),
        IconButton(
          onPressed: onToi,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _LuoiO extends StatelessWidget {
  const _LuoiO({
    required this.soO,
    required this.nhan,
    required this.chonO,
    required this.onChon,
  });

  final int soO;
  final String Function(int i) nhan;
  final bool Function(int i) chonO;
  final ValueChanged<int> onChon;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: soO,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.labelGap,
        crossAxisSpacing: AppSpacing.labelGap,
        childAspectRatio: 2.8,
      ),
      itemBuilder: (context, i) {
        final chon = chonO(i);
        return Material(
          color: chon ? AppColors.primaryColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          child: InkWell(
            onTap: () => onChon(i),
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.radius14),
                border: Border.all(
                  color: chon ? AppColors.primaryColor : AppColors.neutralLight,
                ),
              ),
              child: Text(
                nhan(i),
                style: AppTextStyles.label.copyWith(
                  color: chon ? AppColors.textWhite : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
