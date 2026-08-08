import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';

// Khoảng ngày nghỉ do NCC chặn
typedef KhoangNghi = ({DateTime tu, DateTime den, String? lyDo});

Future<KhoangNghi?> showBlockDaysOffSheet(BuildContext context) {
  return showModalBottomSheet<KhoangNghi>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _BlockDaysOffSheet(),
  );
}

class _BlockDaysOffSheet extends ConsumerStatefulWidget {
  const _BlockDaysOffSheet();

  @override
  ConsumerState<_BlockDaysOffSheet> createState() => _BlockDaysOffSheetState();
}

class _BlockDaysOffSheetState extends ConsumerState<_BlockDaysOffSheet> {
  DateTime _tu = homNayVn();
  DateTime _den = homNayVn().add(const Duration(days: 1));
  String? _lyDo;

  void _taiKhoangDangChon() {
    final cuoi = _den.difference(_tu).inDays > 59
        ? _tu.add(const Duration(days: 59))
        : _den;
    ref.read(sitterScheduleProvider.notifier).damBaoKhoang(_tu, cuoi);
  }

  Future<void> _chonNgay({required bool laTuNgay}) async {
    final homNay = homNayVn();
    // Ngày kết thúc mở lịch từ đúng ngày bắt đầu, khoảng ngược không chọn được
    final chon = await showDatePicker(
      context: context,
      initialDate: laTuNgay ? _tu : _den,
      firstDate: laTuNgay ? homNay : _tu,
      lastDate: DateTime(homNay.year + 1, homNay.month, homNay.day),
    );
    if (chon == null || !mounted) return;
    setState(() {
      if (laTuNgay) {
        _tu = chon;
        // Kéo ngày kết thúc theo để khoảng luôn hợp lệ.
        if (_den.isBefore(_tu)) _den = _tu;
      } else {
        _den = chon;
      }
    });
    _taiKhoangDangChon();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dayHeThong = MediaQuery.viewPaddingOf(context).bottom;
    final lich = ref.watch(sitterScheduleProvider).value;
    // Chỉ đơn CHƯA XONG mới chặn đặt nghỉ
    final ngayDangChay =
        lich?.ngayDangDienRaTrongKhoang(_tu, _den) ?? const <DateTime>[];
    final ngayConDon =
        lich?.ngayConDonTrongKhoang(_tu, _den) ?? const <DateTime>[];
    final soDonCon = lich?.soDonConTrongKhoang(_tu, _den) ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.groupGap + dayHeThong,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.chanNgayNghi, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.textGap),
          Text(l10n.chanNgayNghiMoTa, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.stackGap),
          _ONgay(
            nhan: l10n.tuNgay,
            giaTri: '${thuNgan(l10n, _tu)}, ${ngayThangNam(_tu)}',
            onTap: () => _chonNgay(laTuNgay: true),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _ONgay(
            nhan: l10n.denNgay,
            giaTri: '${thuNgan(l10n, _den)}, ${ngayThangNam(_den)}',
            onTap: () => _chonNgay(laTuNgay: false),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          Text(l10n.lyDoTuyChon, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.labelGap),
          Wrap(
            spacing: AppSpacing.labelGap,
            runSpacing: AppSpacing.labelGap,
            children: [
              for (final ly in [
                l10n.lyDoBanViecRieng,
                l10n.lyDoDiVang,
                l10n.lyDoKhac,
              ])
                AppFilterChip(
                  label: ly,
                  selected: _lyDo == ly,
                  // Chạm lại chip đang chọn để bỏ chọn
                  onTap: () => setState(() => _lyDo = _lyDo == ly ? null : ly),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          // Có đơn trong khoảng thì nói rõ bao nhiêu đơn, ngày nào
          if (ngayConDon.isEmpty)
            AppNoteBox(
              coNen: true,
              kieu: NoteKind.nhac,
              text: l10n.donDaNhanVanGiu,
            )
          else if (ngayDangChay.isNotEmpty)
            AppNoteBox(
              coNen: true,
              kieu: NoteKind.canhBao,
              text: l10n.khoangCoDonDangDienRa(
                ngayDangChay.map(ngayThang).join(', '),
              ),
            )
          else
            AppNoteBox(
              coNen: true,
              kieu: NoteKind.canhBao,
              text: l10n.phaiHuyDonKhoangMoiNghi(
                soDonCon.toString(),
                ngayConDon.map(ngayThang).join(', '),
              ),
            ),
          const SizedBox(height: AppSpacing.groupGap),
          // Còn đơn chưa xong trong khoảng thì chưa cho đặt nghỉ
          AppButton(
            text: l10n.xacNhanNghi,
            enabled: ngayConDon.isEmpty,
            onTap: () =>
                Navigator.pop(context, (tu: _tu, den: _den, lyDo: _lyDo)),
          ),
        ],
      ),
    );
  }
}

// Ô chọn một mốc ngày
class _ONgay extends StatelessWidget {
  const _ONgay({required this.nhan, required this.giaTri, required this.onTap});

  final String nhan;
  final String giaTri;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.itemGap,
            vertical: AppSpacing.stackGap,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Row(
            children: [
              Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
              Text(giaTri, style: AppTextStyles.label),
              const SizedBox(width: AppSpacing.labelGap),
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
