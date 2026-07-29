import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/widgets/cancel_booking_sheet.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_availability.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_schedule.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/availability_fields.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/day_bookings_list.dart';
import 'package:petcare_app/features/sitter/widgets/schedule/day_mode_option.dart';
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

class _DayAvailabilitySheet extends StatefulWidget {
  const _DayAvailabilitySheet({required this.ngay, required this.hienTai});

  final DateTime ngay;
  final DayAvailability hienTai;

  @override
  State<_DayAvailabilitySheet> createState() => _DayAvailabilitySheetState();
}

class _DayAvailabilitySheetState extends State<_DayAvailabilitySheet> {
  late DayMode _mode = widget.hienTai.mode;
  late String _batDau =
      widget.hienTai.start ?? MockSitterAvailability.gioBatDau;
  late String _ketThuc =
      widget.hienTai.end ?? MockSitterAvailability.gioKetThuc;
  late int _soCho = widget.hienTai.boardingSlots;
  late List<ScheduleAppointment> _donTrongNgay =
      MockSitterScheduleData.lichCuaNgay(widget.ngay);

  // Ngày đã qua chỉ xem lại lịch
  bool get _chiXem => widget.ngay.isBefore(homNayVn());

  // Đơn ĐANG chạy thì ngày này không nghỉ được bằng cách nào
  bool get _coDonDangChay => _donTrongNgay.any((don) => don.dangDienRa);
  int get _soDonSapToi => _donTrongNgay
      .where((don) => don.status == ScheduleApptStatus.sapToi)
      .length;
  bool get _khoaNghi => _coDonDangChay || _soDonSapToi > 0;

  // Đơn đã nhận nằm ngoài khung giờ riêng đang đặt vẫn phải thực hiện
  int get _soDonNgoaiKhung => _donTrongNgay
      .where(
        (don) =>
            don.status.conHieuLuc &&
            (don.startTime.compareTo(_batDau) < 0 ||
                don.endTime.compareTo(_ketThuc) > 0),
      )
      .length;

  // Huỷ một đơn ngay trong sheet: xác nhận lý do rồi bỏ khỏi lịch
  Future<void> _huyDon(ScheduleAppointment don) async {
    final l10n = context.l10n;
    final lyDo = await showCancelBookingSheet(
      context,
      CancelBookingTarget(
        maDon: don.id,
        tenDichVu: don.serviceName,
        thuCung: don.tenThuCung,
        chuNuoi: don.ownerName,
        moTaThoiGian:
            '${thuNgan(l10n, widget.ngay)} ${ngayThang(widget.ngay)} · '
            '${don.startTime} – ${don.endTime}',
      ),
    );
    if (lyDo == null || !mounted) return;
    setState(() {
      MockSitterScheduleData.huyDon(don.id);
      _donTrongNgay = MockSitterScheduleData.lichCuaNgay(widget.ngay);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.daHuyDon)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
            if (_donTrongNgay.isNotEmpty) ...[
              DayBookingsList(
                ngay: widget.ngay,
                donList: _donTrongNgay,
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
                style: AppTextStyles.label.copyWith(fontSize: 13),
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
                        MockSitterAvailability.gioBatDau,
                        MockSitterAvailability.gioKetThuc,
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
                                    onChon: (g) => setState(() => _batDau = g),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.labelGap),
                                Expanded(
                                  child: TimePickField(
                                    nhan: l10n.denGio,
                                    gio: _ketThuc,
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
                      khoa: _khoaNghi,
                      moTa: _coDonDangChay
                          ? l10n.khongNghiViDangDienRa
                          : (_soDonSapToi > 0
                                ? l10n.phaiHuyDonMoiNghi(
                                    _soDonSapToi.toString(),
                                  )
                                : l10n.khongNhanDonTheoGio),
                      onTap: () => setState(() => _mode = DayMode.nghi),
                    ),
                  ],
                ),
              ),
              // Giờ riêng chỉ chặn đơn MỚI
              if (_mode == DayMode.gioRieng && _donTrongNgay.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.itemGap),
                AppNoteBox(
                  coNen: true,
                  kieu: _soDonNgoaiKhung > 0 ? NoteKind.canhBao : NoteKind.nhac,
                  text: _soDonNgoaiKhung > 0
                      ? l10n.donNgoaiKhungGio(
                          _soDonNgoaiKhung.toString(),
                          l10n.khungGio(_batDau, _ketThuc),
                        )
                      : l10n.gioRiengChiApDonMoi(
                          _donTrongNgay.length.toString(),
                        ),
                ),
              ],
              const SizedBox(height: AppSpacing.stackGap),
              // Số chỗ trông giữ đặt được cho từng ngày
              Text(
                l10n.trongGiu,
                style: AppTextStyles.label.copyWith(fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.labelGap),
              SlotStepperField(
                soCho: _soCho,
                toiDa: MockSitterAvailability.soChoToiDa,
                onDoi: (v) => setState(() => _soCho = v),
                nhan: l10n.conNhanCho,
              ),
              const SizedBox(height: AppSpacing.groupGap),
              AppButton(
                text: l10n.luu,
                onTap: () => Navigator.pop(
                  context,
                  DayAvailability(
                    mode: _mode,
                    start: _batDau,
                    end: _ketThuc,
                    boardingSlots: _mode == DayMode.nghi ? 0 : _soCho,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
