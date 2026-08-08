import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/features/booking/providers/booking_create_provider.dart';
import 'package:petcare_app/features/booking/services/booking_error_mapper.dart';
import 'package:petcare_app/features/booking/widgets/booking_bottom_bar.dart';
import 'package:petcare_app/shared/widgets/confirm_detail_rows.dart';
import 'package:petcare_app/features/booking/widgets/confirm_payment_block.dart';
import 'package:petcare_app/features/booking/widgets/confirm_price_details.dart';
import 'package:petcare_app/features/booking/widgets/confirm_sitter_card.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/data/booking_args.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Trang xác nhận và thanh toán, dùng chung ba dịch vụ
class BookingConfirmScreen extends ConsumerStatefulWidget {
  const BookingConfirmScreen({super.key, required this.draft});

  final BookingDraft draft;

  @override
  ConsumerState<BookingConfirmScreen> createState() =>
      _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends ConsumerState<BookingConfirmScreen> {
  late BookingDraft _draft = widget.draft;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (daPop, _) {
        if (daPop) return;
        context.pop<YeuCauSua>((muc: null, draft: _draft));
      },
      child: AppScreen(
        backgroundColor: AppColors.surface,
        header: Column(
          children: [
            AppScreenHeader(title: l10n.xacNhanVaThanhToan),
            const AppDongKe(),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          children: [
            FlatSection(child: ConfirmSitterCard(sitter: _draft.sitter)),
            const FlatDivider(),
            FlatSection(child: ConfirmDetailRows(dong: _dongChiTiet(context))),
            const FlatDivider(),
            FlatSection(
              child: ConfirmPriceDetails(
                dong: _dongGia(context),
                tong: _draft.tongTien,
                ghiChu: _draft.loai == ServiceType.grooming
                    ? l10n.ghiChuGiaGroomingTungBe
                    : null,
              ),
            ),
            const FlatDivider(),
            const FlatSection(child: ConfirmPaymentBlock()),
          ],
        ),
        bottomBar: BookingBottomBar(
          nhan: l10n.tongThanhToan,
          moTa: _moTaDon(context),
          tongTien: _draft.tongTien,
          choPhep: true,
          nhanNut: l10n.thanhToan,
          onTiepTuc: _thanhToan,
        ),
      ),
    );
  }

  Future<void> _thanhToan() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final don = await showAppLoading(
        context,
        () => ref.read(bookingCreateProvider.notifier).taoDon(_draft),
      );
      if (!mounted) return;
      context.pushReplacement(
        AppRoutes.bookingProcessing,
        extra: PaymentResultArgs(
          draft: _draft,
          thanhCong: false,
          don: don,
          thoiDiem: nowVn(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(moTaLoiDatLich(context, e))),
      );
    }
  }

  void _suaNgayGio(BuildContext context) =>
      context.pop<YeuCauSua>((muc: null, draft: _draft));

  void _suaDatLich(BuildContext context, MucSuaDon muc) =>
      context.pop<YeuCauSua>((muc: muc, draft: _draft));

  Future<void> _suaDiaChi(BuildContext context) async {
    final daLuu = ref.read(savedAddressesProvider).asData?.value ?? const [];
    if (daLuu.isEmpty) {
      context.push(AppRoutes.addAddress);
      return;
    }
    final chon = await context.push<SavedAddress>(
      AppRoutes.bookingPickupAddress,
      extra: BookingArgs(sitter: _draft.sitter, loai: _draft.loai),
    );
    if (chon == null || !mounted) return;
    setState(() => _draft = _draft.copyWith(diaChiChon: chon));
  }

  List<DongChiTiet> _dongChiTiet(BuildContext context) {
    final l10n = context.l10n;
    final beChon = [for (final be in _draft.pets) petTenGiongCan(context, be)];
    final ghiChu = _draft.ghiChu.trim();
    final DongChiTiet dongThuCung = (
      icon: Icons.pets_outlined,
      nhan: l10n.thuCung,
      giaTri: beChon,
      phu: null,
      onSua: () => _suaDatLich(context, MucSuaDon.thuCung),
      duoiXanh: null,
    );
    final DongChiTiet dongGhiChu = (
      icon: Icons.notes_rounded,
      nhan: l10n.ghiChuCuaDon,
      giaTri: [ghiChu.isEmpty ? l10n.khongCoNoiDung : ghiChu],
      phu: null,
      onSua: () => _suaDatLich(context, MucSuaDon.ghiChu),
      duoiXanh: null,
    );

    switch (_draft.loai) {
      case ServiceType.walking:
        return [
          (
            icon: Icons.calendar_today_outlined,
            nhan: l10n.thoiGian,
            giaTri: [_nhanThoiGianWalking(context)],
            phu: null,
            onSua: () => _suaNgayGio(context),
            duoiXanh: null,
          ),
          (
            icon: Icons.location_on_outlined,
            nhan: l10n.diemDon,
            giaTri: [_draft.diaChi ?? l10n.chuaCapNhat],
            phu: null,
            onSua: () => _suaDiaChi(context),
            duoiXanh: null,
          ),
          dongThuCung,
          dongGhiChu,
        ];
      case ServiceType.boarding:
        return [
          (
            icon: Icons.calendar_today_outlined,
            nhan: l10n.lichGiu,
            giaTri: _nhanLichGiu(context),
            phu: null,
            onSua: () => _suaNgayGio(context),
            duoiXanh: _draft.soDem > 0
                ? l10n.soDemNhan('${_draft.soDem}')
                : null,
          ),
          dongThuCung,
          (
            icon: Icons.location_on_outlined,
            nhan: l10n.trongTai,
            giaTri: _nhaNcc(context),
            phu: l10n.ghiChuDiaChiSauKhiNhan,
            onSua: null,
            duoiXanh: null,
          ),
          dongGhiChu,
        ];
      case ServiceType.grooming:
        return [
          (
            icon: Icons.calendar_today_outlined,
            nhan: l10n.gioHenLabel,
            giaTri: _nhanGioHen(context),
            phu: null,
            onSua: () => _suaNgayGio(context),
            duoiXanh: null,
          ),
          (
            icon: Icons.home_outlined,
            nhan: l10n.lamTai,
            giaTri: [_draft.diaChi ?? l10n.chuaCapNhat],
            phu: null,
            onSua: () => _suaDiaChi(context),
            duoiXanh: null,
          ),
          dongThuCung,
          dongGhiChu,
        ];
    }
  }

  String _nhanThoiGianWalking(BuildContext context) {
    final l10n = context.l10n;
    final gio = _draft.gio;
    final ngay = _draft.ngay;
    if (gio == null || ngay == null) return l10n.chuaCapNhat;
    final phut = _draft.phutMotLuot ?? 0;
    return '${_nhanNgay(context, ngay)} · '
        '${l10n.khungGio(gio.nhan, gioKetThuc(gio, phut))}';
  }

  List<String> _nhanLichGiu(BuildContext context) {
    final l10n = context.l10n;
    final nhan = _draft.ngay;
    final tra = _draft.ngayTra;
    if (nhan == null ||
        tra == null ||
        _draft.gio == null ||
        _draft.gioTra == null) {
      return [l10n.chuaCapNhat];
    }
    return [
      l10n.nhanBeNgayGio(_nhanNgay(context, nhan), _draft.gio!.nhan),
      l10n.traBeNgayGio(_nhanNgay(context, tra), _draft.gioTra!.nhan),
    ];
  }

  List<String> _nhanGioHen(BuildContext context) {
    final l10n = context.l10n;
    final gio = _draft.gio;
    final ngay = _draft.ngay;
    if (gio == null || ngay == null) return [l10n.chuaCapNhat];
    return [
      l10n.ngayLucGio(_nhanNgay(context, ngay), gio.nhan),
      l10n.duKienXongKhoang(gioKetThuc(gio, _draft.phutGrooming)),
    ];
  }

  List<String> _nhaNcc(BuildContext context) {
    final l10n = context.l10n;
    final ten = _draft.sitter.fullName;
    // Server đã rút về "Phường, Tỉnh"; app KHÔNG cắt lại chuỗi địa chỉ
    final khuVuc = _draft.sitter.serviceArea?.khuVuc;
    final km = _draft.sitter.distanceKm;
    return [
      km == null
          ? l10n.nhaCuaNcc(ten)
          : '${l10n.nhaCuaNcc(ten)} · ${l10n.cachBan(l10n.soKm(soLeKm(km)))}',
      if (khuVuc != null && khuVuc.isNotEmpty) khuVuc,
    ];
  }

  List<DongGiaChiTiet> _dongGia(BuildContext context) {
    final l10n = context.l10n;
    final services = _draft.sitter.services;
    final soBe = _draft.pets.length;
    switch (_draft.loai) {
      case ServiceType.walking:
        final config = services?.walking;
        final phut = _draft.phutMotLuot ?? 0;
        final giaGoi = config?.priceByDuration[phut] ?? 0;
        final phuPhi = config?.additionalPetFee ?? 0;
        return [
          (
            nhan:
                '${l10n.datDiDao} · ${l10n.nPhut('$phut')} · '
                '${l10n.soBe('1')}',
            phu: null,
            tien: giaGoi,
            chu: null,
          ),
          if (soBe > 1)
            (
              nhan: l10n.dongPhuPhiThemNBe('${soBe - 1}', dinhDangTien(phuPhi)),
              phu: null,
              tien: phuPhi * (soBe - 1),
              chu: null,
            ),
        ];
      case ServiceType.boarding:
        final config = services?.boarding;
        final giaDem = config?.pricePerDay ?? 0;
        final phuPhi = config?.additionalPetFee ?? 0;
        final dem = _draft.soDem;
        return [
          (
            nhan:
                '${l10n.trongGiu} · ${l10n.soDemNhan('$dem')} · '
                '${l10n.beDau}',
            phu: null,
            tien: giaDem * dem,
            chu: null,
          ),
          if (soBe > 1)
            (
              nhan: l10n.dongPhuPhiThemNBeMoiDem(
                '${soBe - 1}',
                dinhDangTien(phuPhi),
                '$dem',
              ),
              phu: null,
              tien: phuPhi * (soBe - 1) * dem,
              chu: null,
            ),
          (
            nhan: l10n.phiGiuThemNhan,
            phu: _phuPhiGiuThem(context),
            tien: _draft.phiGiuThemDon,
            chu: null,
          ),
        ];
      case ServiceType.grooming:
        final config = services?.grooming;
        return [
          for (final be in _draft.pets)
            (
              nhan: _nhanDongGrooming(context, be.name, be.id),
              phu: _phuThoiLuongGrooming(context, be.id, be.weightKg),
              tien: _giaCuaBe(be.id, be.weightKg, config),
              chu: null,
            ),
        ];
    }
  }

  String _nhanDongGrooming(BuildContext context, String ten, String id) {
    final goi = _draft.goiTheoBe[id];
    return goi == null ? ten : '$ten · ${groomingPackageName(context, goi)}';
  }

  String? _phuThoiLuongGrooming(BuildContext context, String id, double can) {
    final config = _draft.sitter.services?.grooming;
    final goi = _draft.goiTheoBe[id];
    final muc = mucCanCua(can);
    if (config == null || goi == null || muc == null) return null;
    final phut = config.phutCua(goi, muc);
    return phut == null ? null : context.l10n.thoiLuongNPhut('$phut');
  }

  int _giaCuaBe(String id, double can, GroomingConfig? config) {
    final goi = _draft.goiTheoBe[id];
    final muc = mucCanCua(can);
    if (config == null || goi == null || muc == null) return 0;
    return config.priceByPackage[goi]?[muc] ?? 0;
  }

  String _phuPhiGiuThem(BuildContext context) {
    final l10n = context.l10n;
    final lech = moTaGioPhut(l10n, _draft.phutGiuThemDon);
    return _draft.phiGiuThemDon == 0
        ? l10n.moTaPhiGiuThemKhongCo(lech)
        : l10n.moTaPhiGiuThemCo(lech);
  }

  String _moTaDon(BuildContext context) {
    final l10n = context.l10n;
    final soBe = l10n.soBe('${_draft.pets.length}');
    return switch (_draft.loai) {
      ServiceType.walking =>
        '${l10n.datDiDao} · ${l10n.nPhut('${_draft.phutMotLuot ?? 0}')} · $soBe',
      ServiceType.boarding =>
        '${l10n.trongGiu} · ${l10n.soDemNhan('${_draft.soDem}')} · $soBe',
      ServiceType.grooming => '${l10n.tamVaCatTia} · $soBe',
    };
  }

  String _nhanNgay(BuildContext context, DateTime ngay) {
    final l10n = context.l10n;
    return '${thuDaiTheoSo(l10n, ngay.weekday)}, ${ngayThang(ngay)}';
  }
}
