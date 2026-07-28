import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_availability.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/availability_fields.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/green_title_header.dart';

// Màn đặt khung giờ làm việc mặc định của NCC
class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  String _batDau = MockSitterAvailability.gioBatDau;
  String _ketThuc = MockSitterAvailability.gioKetThuc;
  late final Set<int> _ngay = {...MockSitterAvailability.ngayLamViec};

  // Phải chọn ít nhất một ngày
  String? get _loi {
    final l10n = context.l10n;
    if (_ngay.isEmpty) return l10n.chuaChonNgayLamViec;
    final tu = gioTuChuoi(_batDau);
    final den = gioTuChuoi(_ketThuc);
    final sauHon =
        den.hour > tu.hour || (den.hour == tu.hour && den.minute > tu.minute);
    return sauHon ? null : l10n.gioKetThucPhaiSauGioBatDau;
  }

  void _luu() {
    MockSitterAvailability.gioBatDau = _batDau;
    MockSitterAvailability.gioKetThuc = _ketThuc;
    MockSitterAvailability.ngayLamViec = {..._ngay};
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.daLuu)));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loi = _loi;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          GreenTitleHeader(
            title: l10n.gioLamViec,
            subtitle: l10n.gioLamViecMoTa,
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.blockGap,
                AppSpacing.screenPadding,
                AppSpacing.screenEdgeGap,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TimePickField(
                        nhan: l10n.gioBatDauLabel,
                        gio: _batDau,
                        onChon: (g) => setState(() => _batDau = g),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.itemGap),
                    Expanded(
                      child: TimePickField(
                        nhan: l10n.gioKetThucLabel,
                        gio: _ketThuc,
                        onChon: (g) => setState(() => _ketThuc = g),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.groupGap),
                Text(l10n.ngayLamViec, style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.textGap),
                Text(l10n.ngayLamViecMoTa, style: AppTextStyles.captionSm),
                const SizedBox(height: AppSpacing.itemGap),
                _ChonNgayTuan(
                  daChon: _ngay,
                  onDoi: (thu) => setState(() {
                    _ngay.contains(thu) ? _ngay.remove(thu) : _ngay.add(thu);
                  }),
                ),
                if (loi != null) ...[
                  const SizedBox(height: AppSpacing.itemGap),
                  Text(
                    loi,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.groupGap),
                AppButton(text: l10n.luu, enabled: loi == null, onTap: _luu),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Hàng 7 ô chọn thứ làm việc trong tuần
class _ChonNgayTuan extends StatelessWidget {
  const _ChonNgayTuan({required this.daChon, required this.onDoi});

  final Set<int> daChon;
  final ValueChanged<int> onDoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final homNay = homNayVn();
    return Row(
      children: [
        for (var thu = DateTime.monday; thu <= DateTime.sunday; thu++) ...[
          Expanded(
            child: _ONgayTuan(
              nhan: thuNgan(
                l10n,
                homNay.add(Duration(days: thu - homNay.weekday)),
              ),
              chon: daChon.contains(thu),
              onTap: () => onDoi(thu),
            ),
          ),
          if (thu != DateTime.sunday) const SizedBox(width: AppSpacing.textGap),
        ],
      ],
    );
  }
}

class _ONgayTuan extends StatelessWidget {
  const _ONgayTuan({
    required this.nhan,
    required this.chon,
    required this.onTap,
  });

  final String nhan;
  final bool chon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: chon ? AppColors.primaryColor : AppColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: chon ? AppColors.primaryColor : AppColors.neutralLight,
            ),
          ),
          child: Text(
            nhan,
            style: AppTextStyles.label.copyWith(
              fontSize: 13,
              color: chon ? AppColors.textWhite : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
