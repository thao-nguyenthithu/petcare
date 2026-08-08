import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/widgets/cancel_booking_sheet.dart';
import 'package:petcare_app/features/sitter/data/sitter_availability.dart';
import 'package:petcare_app/features/sitter/data/sitter_schedule.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/availability_fields.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/day_bookings_list.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/day_mode_option.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Sheet chỉnh giờ nhận đơn của 1 ngày
Future<DayAvailability?> showDayAvailabilitySheet(
  BuildContext context,
  DateTime ngay,
  DayAvailability hienTai,
) {
  return showModalBottomSheet<DayAvailability>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DayAvailabilitySheet(ngay: ngay, hienTai: hienTai),
  );
}

class _DayAvailabilitySheet extends ConsumerStatefulWidget {
  const _DayAvailabilitySheet({required this.ngay, required this.hienTai});

  final DateTime ngay;
  final DayAvailability hienTai;

  @override
  ConsumerState<_DayAvailabilitySheet> createState() =>
      _DayAvailabilitySheetState();
}

class _DayAvailabilitySheetState extends ConsumerState<_DayAvailabilitySheet> {
  late DayMode _mode = widget.hienTai.mode;
  late String _batDau;
  late String _ketThuc;
  late int _soCho = widget.hienTai.boardingLeft;

  @override
  void initState() {
    super.initState();
    // Ngày chưa đặt giờ riêng thì mở sẵn khung giờ mặc định để sửa cho nhanh
    final lich = ref.read(sitterScheduleProvider).value;
    _batDau = widget.hienTai.start ?? lich?.gioBatDau ?? gioMoMacDinh;
    _ketThuc = widget.hienTai.end ?? lich?.gioKetThuc ?? gioDongMacDinh;
  }

  // Ngày đã qua chỉ xem lại lịch
  bool get _chiXem => widget.ngay.isBefore(homNayVn());

  // Đơn đã nhận nằm ngoài khung giờ riêng đang đặt vẫn phải thực hiện
  int _soDonNgoaiKhung(List<ScheduleAppointment> don) => don
      .where(
        (d) =>
            d.status.conHieuLuc &&
            (d.startTime.compareTo(_batDau) < 0 ||
                d.endTime.compareTo(_ketThuc) > 0),
      )
      .length;

  void _luu() {
    if (_mode == DayMode.gioRieng && _ketThuc.compareTo(_batDau) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.gioKetThucPhaiSauGioBatDau)),
      );
      return;
    }
    Navigator.pop(
      context,
      DayAvailability(
        mode: _mode,
        start: _batDau,
        end: _ketThuc,
        boardingSlots: _mode == DayMode.nghi
            ? 0
            : widget.hienTai.boardingUsed + _soCho,
        boardingUsed: widget.hienTai.boardingUsed,
      ),
    );
  }

  Future<void> _huyDon(ScheduleAppointment don) async {
    final l10n = context.l10n;
    final lyDo = await showCancelBookingSheet(
      context,
      CancelBookingTarget(
        maDon: don.code,
        tenDichVu: don.serviceName,
        thuCung: moTaCacBe(l10n, don.pets),
        chuNuoi: don.ownerName,
        moTaThoiGian:
            '${thuNgan(l10n, widget.ngay)} ${ngayThang(widget.ngay)} · '
            '${don.startTime} – ${don.endTime}',
      ),
    );
    if (lyDo == null || !mounted) return;
    try {
      await ref
          .read(sitterScheduleProvider.notifier)
          .huyDon(don.id, lyDo.lyDo.ma, lyDo.moTa);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.daHuyDon)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.huyDonThatBai)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lich = ref.watch(sitterScheduleProvider).value;
    final donTrongNgay = lich?.lichCuaNgay(widget.ngay) ?? const [];
    final coDonDangChay = donTrongNgay.any((don) => don.dangDienRa);
    final soDonSapToi = donTrongNgay
        .where((don) => don.status == ScheduleApptStatus.sapToi)
        .length;
    final khoaNghi = coDonDangChay || soDonSapToi > 0;
    final soDonNgoaiKhung = _soDonNgoaiKhung(donTrongNgay);
    final dayHeThong = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.groupGap + dayHeThong,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nhanNgayCoNam(l10n, widget.ngay), style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(
              _chiXem ? l10n.ngayDaQuaChiXem : l10n.dieuChinhRiengChoNgay,
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            // Cho thấy ngày này đang vướng đơn nào trước khi chỉnh giờ/nghỉ
            if (donTrongNgay.isNotEmpty) ...[
              DayBookingsList(
                donList: donTrongNgay,
                onHuyDon: _huyDon,
                chiXem: _chiXem,
              ),
              const SizedBox(height: AppSpacing.stackGap),
            ] else if (_chiXem) ...[
              AppNoteBox(
                coNen: true,
                kieu: NoteKind.nhac,
                text: l10n.ngayDaQuaKhongCoDon,
              ),
              const SizedBox(height: AppSpacing.stackGap),
            ],
            // Ngày đã qua thì dừng ở phần xem
            if (!_chiXem) ...[
              // Nhóm dịch vụ tính theo giờ
              Text(
                '${l10n.datDiDao} · ${l10n.tamVaTia}',
                style: AppTextStyles.label,
              ),
              const SizedBox(height: AppSpacing.labelGap),
              RadioGroup<DayMode>(
                groupValue: _mode,
                onChanged: (m) => setState(() => _mode = m ?? DayMode.macDinh),
                child: Column(
                  children: [
                    DayModeOption(
                      mode: DayMode.macDinh,
                      dangChon: _mode == DayMode.macDinh,
                      tieuDe: l10n.theoGioMacDinh,
                      moTa: l10n.khungGio(
                        lich?.gioBatDau ?? _batDau,
                        lich?.gioKetThuc ?? _ketThuc,
                      ),
                      onTap: () => setState(() => _mode = DayMode.macDinh),
                    ),
                    const SizedBox(height: AppSpacing.labelGap),
                    DayModeOption(
                      mode: DayMode.gioRieng,
                      dangChon: _mode == DayMode.gioRieng,
                      tieuDe: l10n.datGioRieng,
                      onTap: () => setState(() => _mode = DayMode.gioRieng),
                      duoi: _mode == DayMode.gioRieng
                          ? Row(
                              children: [
                                Expanded(
                                  child: TimePickField(
                                    nhan: l10n.tuGio,
                                    gio: _batDau,
                                    onChon: (g) => setState(() {
                                      _batDau = g;
                                      _ketThuc = dayGioDong(g, _ketThuc);
                                    }),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.labelGap),
                                Expanded(
                                  child: TimePickField(
                                    nhan: l10n.denGio,
                                    gio: _ketThuc,
                                    laGioDong: true,
                                    sauGio: _batDau,
                                    onChon: (g) => setState(() => _ketThuc = g),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.labelGap),
                    // Đang có đơn chạy thì chịu, chỉ còn đơn sắp tới thì huỷ đi
                    DayModeOption(
                      mode: DayMode.nghi,
                      dangChon: _mode == DayMode.nghi,
                      tieuDe: l10n.nghi,
                      khoa: khoaNghi,
                      moTa: coDonDangChay
                          ? l10n.khongNghiViDangDienRa
                          : (soDonSapToi > 0
                                ? l10n.phaiHuyDonMoiNghi(soDonSapToi.toString())
                                : l10n.khongNhanDonTheoGio),
                      onTap: () => setState(() => _mode = DayMode.nghi),
                    ),
                  ],
                ),
              ),
              // Giờ riêng chỉ chặn đơn MỚI
              if (_mode == DayMode.gioRieng && donTrongNgay.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.itemGap),
                AppNoteBox(
                  coNen: true,
                  kieu: soDonNgoaiKhung > 0 ? NoteKind.canhBao : NoteKind.nhac,
                  text: soDonNgoaiKhung > 0
                      ? l10n.donNgoaiKhungGio(
                          soDonNgoaiKhung.toString(),
                          l10n.khungGio(_batDau, _ketThuc),
                        )
                      : l10n.gioRiengChiApDonMoi(
                          donTrongNgay.length.toString(),
                        ),
                ),
              ],
              const SizedBox(height: AppSpacing.stackGap),
              // Số chỗ trông giữ đặt được cho từng ngày
              Text(l10n.trongGiu, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.labelGap),
              SlotStepperField(
                soCho: _soCho,
                toiDa: lich?.soChoToiDaCuaNgay(widget.ngay) ?? 0,
                onDoi: (v) => setState(() => _soCho = v),
                nhan: l10n.conNhanCho,
              ),
              const SizedBox(height: AppSpacing.groupGap),
              AppButton(text: l10n.luu, onTap: _luu),
            ],
          ],
        ),
      ),
    );
  }
}
