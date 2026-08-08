import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';

// Đường kính ô ngày
const double _oNgay = 38;
// Chiều cao một ô trong lưới
const double _caoO = 48;
const double _caoOCoCham = 56;
const double _boDai = 24;

// Lịch tháng dùng chung cho mọi màn có lịc
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.choPhep,
    required this.laNgayKin,
    this.onChon,
    this.chon,
    this.dau,
    this.cuoi,
    this.coCham,
    this.chamMoiNgay = false,
    this.nutHomNay = false,
    this.onDoiThang,
  });
  final bool Function(DateTime ngay) choPhep;
  final bool Function(DateTime ngay) laNgayKin;
  final void Function(DateTime ngay)? onChon;
  final DateTime? chon;
  final DateTime? dau;
  final DateTime? cuoi;
  final bool Function(DateTime ngay)? coCham;
  final bool chamMoiNgay;
  final bool nutHomNay;
  final ValueChanged<DateTime>? onDoiThang;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

bool Function(DateTime) kinTheoDanhSach(List<DateTime> ds) =>
    (d) => ds.any((k) => cungNgay(k, d));

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _thang;

  @override
  void initState() {
    super.initState();
    final moc = widget.chon ?? widget.dau ?? nowVn();
    _thang = DateTime(moc.year, moc.month);
  }

  bool get _laThangNay {
    final now = nowVn();
    return _thang.year == now.year && _thang.month == now.month;
  }

  void _doiThang(DateTime moi) {
    setState(() => _thang = moi);
    widget.onDoiThang?.call(moi);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final soNgay = DateTime(_thang.year, _thang.month + 1, 0).day;
    final trong = DateTime(_thang.year, _thang.month, 1).weekday - 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _NutThang(
              icon: Icons.chevron_left,
              onTap: () => _doiThang(DateTime(_thang.year, _thang.month - 1)),
            ),
            Expanded(
              child: Text(
                l10n.thangNam('${_thang.month}', '${_thang.year}'),
                textAlign: TextAlign.center,
                style: AppTextStyles.label,
              ),
            ),
            _NutThang(
              icon: Icons.chevron_right,
              onTap: () => _doiThang(DateTime(_thang.year, _thang.month + 1)),
            ),
            if (widget.nutHomNay)
              InkWell(
                onTap: _laThangNay
                    ? null
                    : () {
                        final now = nowVn();
                        _doiThang(DateTime(now.year, now.month));
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Text(
                    l10n.homNay,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var thu = 1; thu <= 7; thu++)
              Expanded(
                child: Text(
                  thuNganTheoSo(l10n, thu),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSm.copyWith(
                    color: thu == 7
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var hang = 0; hang < ((trong + soNgay + 6) ~/ 7); hang++)
          Row(
            children: [
              for (var cot = 0; cot < 7; cot++)
                Expanded(child: _oTrongHang(hang, cot, trong, soNgay)),
            ],
          ),
      ],
    );
  }

  Widget _oTrongHang(int hang, int cot, int trong, int soNgay) {
    final coCham = widget.coCham;
    final caoO = coCham == null ? _caoO : _caoOCoCham;
    final thuTu = hang * 7 + cot - trong + 1;
    if (thuTu < 1 || thuTu > soNgay) return SizedBox(height: caoO);
    final ngay = DateTime(_thang.year, _thang.month, thuTu);
    final dau = widget.dau;
    final cuoi = widget.cuoi;
    final chon = widget.chon;
    final laDau = dau != null && cungNgay(dau, ngay);
    final laCuoi = cuoi != null && cungNgay(cuoi, ngay);
    final onChon = widget.onChon;
    final choPhep = widget.choPhep(ngay);
    final chamDuoc = onChon != null && (choPhep || widget.chamMoiNgay);
    return _ONgay(
      ngay: ngay,
      dangChon: laDau || laCuoi || (chon != null && cungNgay(chon, ngay)),
      giuaKhoang:
          dau != null &&
          cuoi != null &&
          ngay.isAfter(chiNgay(dau)) &&
          ngay.isBefore(chiNgay(cuoi)),
      dauDai: laDau && cuoi != null,
      cuoiDai: laCuoi && dau != null,
      laHomNay: cungNgay(ngay, nowVn()),
      kin: widget.laNgayKin(ngay),
      choPhep: choPhep,
      cham: coCham?.call(ngay),
      onTap: chamDuoc ? () => onChon(ngay) : null,
    );
  }
}

class _ONgay extends StatelessWidget {
  const _ONgay({
    required this.ngay,
    required this.dangChon,
    required this.giuaKhoang,
    required this.dauDai,
    required this.cuoiDai,
    required this.laHomNay,
    required this.kin,
    required this.choPhep,
    required this.onTap,
    required this.cham,
  });

  final DateTime ngay;
  final bool dangChon;
  final bool giuaKhoang;
  final bool dauDai;
  final bool cuoiDai;
  final bool laHomNay;
  final bool kin;
  final bool choPhep;
  final VoidCallback? onTap;
  final bool? cham;

  @override
  Widget build(BuildContext context) {
    final Color? nen = dangChon
        ? AppColors.primaryColor
        : kin
        ? AppColors.neutral
        : null;
    final laVienHomNay = laHomNay && !dangChon;
    final mauChu = dangChon
        ? AppColors.textWhite
        : giuaKhoang || laVienHomNay
        ? AppColors.primaryColor
        : kin
        ? AppColors.textSecondary
        : !choPhep
        ? AppColors.neutral
        : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: giuaKhoang || dauDai || cuoiDai ? AppColors.cardMint : null,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(dauDai ? _boDai : 0),
            right: Radius.circular(cuoiDai ? _boDai : 0),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onTap,
                child: Container(
                  width: _oNgay,
                  height: _oNgay,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: nen,
                    shape: BoxShape.circle,
                    border: laVienHomNay
                        ? Border.all(color: AppColors.primaryColor, width: 1.6)
                        : null,
                  ),
                  child: Text(
                    '${ngay.day}',
                    style: AppTextStyles.label.copyWith(color: mauChu),
                  ),
                ),
              ),
              if (cham != null) ...[
                const SizedBox(height: 3),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: cham! ? AppColors.accent : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NutThang extends StatelessWidget {
  const _NutThang({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 22, color: AppColors.textPrimary),
      ),
    );
  }
}
