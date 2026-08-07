import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/month_calendar.dart';

// Khoảng ngày người tìm muốn gửi bé
class KhoangNgay {
  const KhoangNgay({this.tu, this.den});

  final DateTime? tu;
  final DateTime? den;

  bool get rong => tu == null || den == null;
  int get soNgay => rong ? 0 : den!.difference(tu!).inDays + 1;
  int get soDem => soNgay == 0 ? 0 : soNgay - 1;
}

// Bảng chọn khoảng ngày
Future<KhoangNgay?> showDateRangeSheet({
  required BuildContext context,
  required KhoangNgay banDau,
}) {
  return showModalBottomSheet<KhoangNgay>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DateRangeSheet(banDau: banDau),
  );
}

class _DateRangeSheet extends StatefulWidget {
  const _DateRangeSheet({required this.banDau});

  final KhoangNgay banDau;

  @override
  State<_DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<_DateRangeSheet> {
  static const int _soNgayMoToiDa = 60;

  late DateTime? _tu = widget.banDau.tu;
  late DateTime? _den = widget.banDau.den;

  DateTime get _homNay => homNayVn();
  DateTime get _ngayCuoi => _homNay.add(const Duration(days: _soNgayMoToiDa));

  bool _chonDuoc(DateTime ngay) =>
      !ngay.isBefore(_homNay) && !ngay.isAfter(_ngayCuoi);

  void _chon(DateTime ngay) {
    setState(() {
      if (_tu == null || _den != null || ngay.isBefore(_tu!)) {
        _tu = ngay;
        _den = null;
      } else {
        _den = ngay;
      }
    });
  }

  void _chonNhanh(DateTime tu, DateTime den) {
    setState(() {
      _tu = tu;
      _den = den;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final khoang = KhoangNgay(tu: _tu, den: _den);
    final cuoiTuan = _cuoiTuanNay();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingWide,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(l10n.chonKhoangNgay, style: AppTextStyles.h3),
              ),
              TextButton(
                onPressed: () => setState(() {
                  _tu = null;
                  _den = null;
                }),
                child: Text(
                  l10n.xoaNgay,
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingWide,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.moTaChonKhoangNgay,
              style: AppTextStyles.captionSm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingWide,
            ),
            children: [
              ActionChip(
                label: Text(l10n.homNay),
                onPressed: () => _chonNhanh(_homNay, _homNay),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              ActionChip(
                label: Text(l10n.ngayMai),
                onPressed: () {
                  final mai = _homNay.add(const Duration(days: 1));
                  _chonNhanh(mai, mai);
                },
              ),
              const SizedBox(width: AppSpacing.labelGap),
              ActionChip(
                label: Text(l10n.cuoiTuanNay),
                onPressed: () => _chonNhanh(cuoiTuan.$1, cuoiTuan.$2),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingWide,
            ),
            child: Column(
              children: [
                MonthCalendar(
                  dau: _tu,
                  cuoi: _den,
                  choPhep: _chonDuoc,
                  laNgayKin: (_) => false,
                  onChon: _chon,
                ),
                const SizedBox(height: AppSpacing.itemGap),
                Text(l10n.ghiChuNgayMoDat, style: AppTextStyles.captionSm),
                const SizedBox(height: AppSpacing.itemGap),
              ],
            ),
          ),
        ),
        const AppDongKe(),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingWide,
              AppSpacing.itemGap,
              AppSpacing.screenPaddingWide,
              AppSpacing.screenPadding,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    _CotNgay(nhan: l10n.tuNgay, ngay: _tu),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.itemGap,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    _CotNgay(nhan: l10n.denNgay, ngay: _den),
                    const Spacer(),
                    if (!khoang.rong)
                      Text(
                        l10n.soNgayDem(khoang.soNgay, khoang.soDem),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.itemGap),
                AppButton(
                  text: l10n.xemKetQua,
                  // Chọn dở một đầu thì chưa lọc được, chặn ở nút
                  enabled: !khoang.rong || (_tu == null && _den == null),
                  onTap: () => Navigator.pop(context, khoang),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  (DateTime, DateTime) _cuoiTuanNay() {
    final dau = dauTuan(_homNay);
    var bay = dau.add(const Duration(days: 5));
    if (bay.isBefore(_homNay)) bay = bay.add(const Duration(days: 7));
    return (bay, bay.add(const Duration(days: 1)));
  }
}

class _CotNgay extends StatelessWidget {
  const _CotNgay({required this.nhan, required this.ngay});

  final String nhan;
  final DateTime? ngay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nhan, style: AppTextStyles.captionSm),
        Text(
          ngay == null ? '--' : '${thuNgan(l10n, ngay!)} · ${ngayThang(ngay!)}',
          style: AppTextStyles.label,
        ),
      ],
    );
  }
}
