import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/shared/data/sitter_slots.dart';
import 'package:petcare_app/features/booking/providers/sitter_slots_provider.dart';
import 'package:petcare_app/features/booking/widgets/boarding_night_rules.dart';
import 'package:petcare_app/features/booking/widgets/boarding_range_summary.dart';
import 'package:petcare_app/features/booking/widgets/boarding_stay_time.dart';
import 'package:petcare_app/features/booking/widgets/booking_bottom_bar.dart';
import 'package:petcare_app/shared/widgets/calendar_legend.dart';
import 'package:petcare_app/features/booking/widgets/booking_header.dart';
import 'package:petcare_app/shared/widgets/month_calendar.dart';
import 'package:petcare_app/features/booking/widgets/grooming_appointment_time.dart';
import 'package:petcare_app/features/booking/widgets/walking_start_time.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

const int _thoiLuongMacDinh = 60;

class BookingDateTimeScreen extends ConsumerStatefulWidget {
  const BookingDateTimeScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  ConsumerState<BookingDateTimeScreen> createState() =>
      _BookingDateTimeScreenState();
}

class _BookingDateTimeScreenState extends ConsumerState<BookingDateTimeScreen> {
  late BookingDraft _goc = widget.draft;

  DateTime? _ngay;
  KhungGio? _gio;
  DateTime? _ngayTra;
  KhungGio? _gioTra;

  bool get _laTrongGiu => widget.draft.loai == ServiceType.boarding;

  @override
  void initState() {
    super.initState();
    _ngay = widget.draft.ngay;
    _gio = widget.draft.gio;
    _ngayTra = widget.draft.ngayTra;
    _gioTra = widget.draft.gioTra;
  }

  BookingDraft get _draft => _goc.datNgayGio(
    ngay: _ngay,
    gio: _gio,
    ngayTra: _ngayTra,
    gioTra: _gioTra,
  );

  int get _thoiLuong => switch (widget.draft.loai) {
    ServiceType.walking => widget.draft.phutMotLuot ?? _thoiLuongMacDinh,
    ServiceType.grooming => _dongThoiLuong().fold(0, (t, d) => t + d.phut),
    ServiceType.boarding => 0,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;
    final bayGio = nowVn();
    final khoa = khoaLichTrong(draft.sitter.id, [
      for (final be in draft.pets) be.id,
    ]);
    final lich = ref.watch(sitterSlotsProvider(khoa));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (daPop, _) {
        if (daPop) return;
        context.pop<YeuCauSua>((muc: null, draft: _draft));
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BookingHeader(
                tieuDe: draft.loai == ServiceType.grooming
                    ? l10n.chonNgayVaGioHen
                    : l10n.chonNgayVaGio,
                tenNcc: draft.sitter.fullName,
                tenDichVu: serviceTypeNameDai(context, draft.loai),
                avatarUrl: draft.sitter.avatarUrl,
              ),
              const AppDongKe(),
              Expanded(
                child: lich.when(
                  loading: () => const AppSkeletonList(soThe: 3, caoThe: 100),
                  error: (_, _) => AppNetworkError(
                    message: l10n.loiTaiLichTrong,
                    onRetry: () => ref.invalidate(sitterSlotsProvider(khoa)),
                  ),
                  data: (slots) => _than(context, bayGio, slots),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BookingBottomBar(
          nhan: _laTrongGiu && _draft.soDem > 0
              ? '${l10n.tamTinh} · ${l10n.soDemNhan('${_draft.soDem}')}'
              : null,
          tongTien: _draft.duNgayGio ? _draft.tongTien : null,
          choPhep: _draft.duNgayGio && lich.hasValue,
          onTiepTuc: _sangXacNhan,
        ),
      ),
    );
  }

  bool? _conChoCaKhoang(SitterSlots slots) {
    final dau = _ngay;
    final cuoi = _ngayTra;
    if (dau == null || cuoi == null) return null;
    final kin = kinTheoDanhSach(slots.ngayKinDon(widget.draft.loai));
    for (var d = dau; !d.isAfter(cuoi); d = d.add(const Duration(days: 1))) {
      if (kin(d)) return false;
    }
    return true;
  }

  Widget _than(BuildContext context, DateTime bayGio, SitterSlots slots) {
    final l10n = context.l10n;
    final kinDon = slots.ngayKinDon(widget.draft.loai);
    final khongDat = slots.ngayKhongDat(widget.draft.loai);
    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        FlatSection(
          child: MonthCalendar(
            chon: _laTrongGiu ? null : _ngay,
            dau: _laTrongGiu ? _ngay : null,
            cuoi: _laTrongGiu ? _ngayTra : null,
            laNgayKin: kinTheoDanhSach(kinDon),
            choPhep: (d) => ngayChonDuoc(d, bayGio, khongDat),
            onChon: (d) => _chonNgay(d, bayGio, khongDat, slots),
          ),
        ),
        const SizedBox(height: 16),
        FlatSection(
          child: CalendarLegend(chonDuoc: true, chonKhoang: _laTrongGiu),
        ),
        const SizedBox(height: 12),
        FlatSection(
          child: AppNoteBox(
            text: _laTrongGiu
                ? '${l10n.ghiChuDatTruocToiDaNNgay('$maxAdvanceDays')}\n'
                      '${l10n.ghiChuChonKhoangNgay}'
                : l10n.ghiChuDatTruocToiDaNNgay('$maxAdvanceDays'),
          ),
        ),
        const FlatDivider(),
        ..._phanChonGio(context, bayGio, slots),
      ],
    );
  }

  Future<void> _sangXacNhan() async {
    final kq = await context.push<YeuCauSua>(
      AppRoutes.bookingConfirm,
      extra: _draft,
    );
    if (kq == null || !mounted) return;
    setState(() => _goc = kq.draft);
    if (kq.muc != null) context.pop<YeuCauSua>(kq);
  }

  List<Widget> _phanChonGio(
    BuildContext context,
    DateTime bayGio,
    SitterSlots slots,
  ) {
    final draft = widget.draft;
    final tenNcc = draft.sitter.fullName;
    switch (draft.loai) {
      case ServiceType.walking:
        return [
          FlatSection(
            child: WalkingStartTime(
              tenNcc: tenNcc,
              nhanNgay: _ngay == null ? null : _nhanNgay(context, _ngay!),
              khung: _khungCua(_ngay, bayGio, _thoiLuong, slots),
              chon: _gio,
              thoiLuongPhut: _thoiLuong,
              onChon: (k) => setState(() => _gio = k),
            ),
          ),
        ];
      case ServiceType.grooming:
        return [
          FlatSection(
            child: GroomingAppointmentTime(
              tenNcc: tenNcc,
              nhanNgay: _ngay == null ? null : _nhanNgay(context, _ngay!),
              khung: _khungCua(_ngay, bayGio, _thoiLuong, slots),
              chon: _gio,
              dong: _dongThoiLuong(),
              onChon: (k) => setState(() => _gio = k),
            ),
          ),
        ];
      case ServiceType.boarding:
        return [
          FlatSection(
            child: BoardingRangeSummary(
              tenNcc: tenNcc,
              nhanDau: _ngay == null ? null : _nhanNgay(context, _ngay!),
              nhanCuoi: _ngayTra == null ? null : _nhanNgay(context, _ngayTra!),
              soDem: _draft.soDem,
              conChoCaKhoang: _conChoCaKhoang(slots),
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: BoardingStayTime(
              tenNcc: tenNcc,
              khungDen: _khungCua(
                _ngay,
                bayGio,
                0,
                slots,
                chiem: KieuChiem.toiCuoiNgay,
              ),
              khungVe: _khungCua(
                _ngayTra,
                bayGio,
                0,
                slots,
                chiem: KieuChiem.tuDauNgay,
              ),
              gioDen: _gio,
              gioVe: _gioTra,
              nhanNgayDen: _ngay == null ? null : _nhanNgay(context, _ngay!),
              nhanNgayVe: _ngayTra == null
                  ? null
                  : _nhanNgay(context, _ngayTra!),
              onChonGioDen: (k) => setState(() => _gio = k),
              onChonGioVe: (k) => setState(() => _gioTra = k),
            ),
          ),
          const FlatDivider(),
          FlatSection(child: BoardingNightRules(ketLuan: _ketLuanGiuThem())),
        ];
    }
  }

  void _chonNgay(
    DateTime d,
    DateTime bayGio,
    List<DateTime> ngayKin,
    SitterSlots slots,
  ) {
    if (!_laTrongGiu) {
      setState(() {
        _ngay = d;
        _gio = null;
      });
      return;
    }
    final dau = _ngay;
    final batDauLai =
        dau == null ||
        _ngayTra != null ||
        !d.isAfter(chiNgay(dau)) ||
        !_khoangLienMach(dau, d, bayGio, ngayKin, slots);
    setState(() {
      if (batDauLai) {
        _ngay = d;
        _ngayTra = null;
        _gio = null;
        _gioTra = null;
        return;
      }
      _ngayTra = d;
      _gioTra = null;
    });
  }

  bool _khoangLienMach(
    DateTime dau,
    DateTime cuoi,
    DateTime bayGio,
    List<DateTime> ngayKin,
    SitterSlots slots,
  ) {
    for (
      var d = chiNgay(dau);
      !d.isAfter(chiNgay(cuoi));
      d = d.add(const Duration(days: 1))
    ) {
      if (!ngayChonDuoc(d, bayGio, ngayKin)) return false;
      final giua = d.isAfter(chiNgay(dau)) && d.isBefore(chiNgay(cuoi));
      if (giua && (slots.cuaNgay(d)?.banCuaBe.isNotEmpty ?? false)) {
        return false;
      }
    }
    return true;
  }

  List<KhungGio> _khungCua(
    DateTime? ngay,
    DateTime bayGio,
    int thoiLuong,
    SitterSlots slots, {
    KieuChiem chiem = KieuChiem.theoThoiLuong,
  }) {
    if (ngay == null) return const [];
    final trongNgay = slots.cuaNgay(ngay);
    return sinhKhungGio(
      ngay: ngay,
      bayGio: bayGio,
      phutMo: trongNgay?.phutMo ?? slots.phutMoMacDinh,
      phutDong: trongNgay?.phutDong ?? slots.phutDongMacDinh,
      thoiLuongPhut: thoiLuong,
      ban: _laTrongGiu ? const [] : (trongNgay?.ban ?? const []),
      banCuaBe: trongNgay?.banCuaBe ?? const [],
      chiem: chiem,
    );
  }

  String _ketLuanGiuThem() {
    final l10n = context.l10n;
    final den = _gio;
    final ve = _gioTra;
    if (den == null || ve == null) return l10n.chuaChonGioGiuThem;
    final lech = moTaGioPhut(l10n, _draft.phutGiuThemDon);
    final phi = _draft.phiGiuThemDon;
    if (phi == 0) {
      return l10n.moTaGiuThemKhongPhatSinh(den.nhan, ve.nhan, lech);
    }
    return l10n.moTaGiuThemCoPhatSinh(
      den.nhan,
      ve.nhan,
      lech,
      dinhDangTien(phi),
    );
  }

  List<DongThoiLuong> _dongThoiLuong() {
    final draft = widget.draft;
    final config = draft.sitter.services?.grooming;
    if (config == null) return const [];
    final ds = <DongThoiLuong>[];
    for (final be in draft.pets) {
      final goi = draft.goiTheoBe[be.id];
      final muc = mucCanCua(be.weightKg);
      if (goi == null || muc == null) continue;
      final phut = config.phutCua(goi, muc);
      if (phut == null) continue;
      ds.add((
        nhan:
            '${be.name} · ${groomingPackageName(context, goi)} · '
            '${context.l10n.nangSoKg(canNangGon(be.weightKg))}',
        phut: phut,
      ));
    }
    return ds;
  }

  String _nhanNgay(BuildContext context, DateTime ngay) {
    final l10n = context.l10n;
    final ngayGon = ngayThang(ngay);
    if (cungNgay(ngay, nowVn())) return '${l10n.homNay} $ngayGon';
    return '${thuDaiTheoSo(l10n, ngay.weekday)} $ngayGon';
  }
}
