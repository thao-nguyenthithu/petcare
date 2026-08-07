import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/features/booking/widgets/booking_bottom_bar.dart';
import 'package:petcare_app/features/booking/widgets/booking_header.dart';
import 'package:petcare_app/shared/widgets/booking_pet_notes.dart';
import 'package:petcare_app/features/booking/widgets/booking_pet_picker.dart';
import 'package:petcare_app/features/booking/widgets/booking_place_note.dart';
import 'package:petcare_app/features/booking/widgets/booking_price_summary.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/cuon_toi.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/booking_args.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const int _demTamTinh = 1;

// Trang đặt lịch Trông giữ tại nhà người chăm
class BookingBoardingScreen extends ConsumerStatefulWidget {
  const BookingBoardingScreen({super.key, required this.args});

  final BookingArgs args;

  @override
  ConsumerState<BookingBoardingScreen> createState() =>
      _BookingBoardingScreenState();
}

class _BookingBoardingScreenState extends ConsumerState<BookingBoardingScreen> {
  final _ghiChu = TextEditingController();
  final _beDaChon = <String>{};
  final _khoaChonBe = GlobalKey();
  final _khoaGhiChu = GlobalKey();
  SavedAddress? _diaChi;
  BookingDraft? _ngayGioDaChon;
  BoardingConfig get _config => widget.args.sitter.services!.boarding;

  @override
  void dispose() {
    _ghiChu.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sitter = widget.args.sitter;
    final services = sitter.services!;
    final pets = ref.watch(myPetsProvider).asData?.value ?? const <Pet>[];
    final diaChiDaLuu =
        ref.watch(savedAddressesProvider).asData?.value ?? const [];
    final diaChi = _diaChi ?? _macDinh(diaChiDaLuu);
    final thieuDiaChi = diaChi == null;

    final toiDa = _config.maxPets ?? 1;
    final daDu = _beDaChon.length >= toiDa;
    final danhSach = <BeChon>[
      for (final be in pets)
        (
          be: be,
          chon: _beDaChon.contains(be.id),
          lyDoMo:
              _lyDoMo(context, be, services) ??
              (daDu && !_beDaChon.contains(be.id)
                  ? l10n.daDuSoBe('$toiDa')
                  : null),
        ),
    ];
    final beChon = pets.where((p) => _beDaChon.contains(p.id)).toList();
    final thieuBe = pets.isNotEmpty && beChon.isEmpty;
    final giaNgay = _config.pricePerDay;
    final xong = beChon.isNotEmpty && giaNgay != null && !thieuDiaChi;

    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          BookingHeader(
            tieuDe: l10n.datLich,
            tenNcc: sitter.fullName,
            tenDichVu: l10n.trongGiuTaiNhaNguoiCham,
            avatarUrl: sitter.avatarUrl,
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          FlatSection(
            key: _khoaChonBe,
            child: BookingPetPicker(
              danhSach: danhSach,
              onDoiChon: _doiChon,
              onThemBe: () => context.push(AppRoutes.addPet),
              ghiChu: pets.isEmpty ? null : _ghiChuSoBe(context),
              loi: thieuBe ? l10n.chonItNhatMotBe : null,
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: BookingPetNotes(
              pets: beChon,
              onSuaHoSo: (be) => context.push(AppRoutes.addPet, extra: be),
            ),
          ),
          const FlatDivider(),
          FlatSection(
            key: _khoaGhiChu,
            child: BookingPlaceNote(
              tieuDe: l10n.diaDiemVaGhiChuDon,
              icon: Icons.location_on_outlined,
              nhan: l10n.banMangBeDiTu,
              giaTri: diaChi?.diaChiDayDu,
              nhanHanhDong: thieuDiaChi ? l10n.them : l10n.doi,
              onHanhDong: () => _chonDiaChi(context, diaChiDaLuu),
              ghiChu: _ghiChu,
              loi: thieuDiaChi ? l10n.themDiaChiDeTiepTuc : null,
              dongPhu: (
                icon: Icons.home_outlined,
                nhan: l10n.trongTai,
                giaTri: _nhaNcc(context),
                duoi: sitter.serviceArea?.khuVuc,
              ),
              ghiChuDongPhu: l10n.ghiChuDiaChiSauKhiNhan,
            ),
          ),
          if (giaNgay != null && beChon.isNotEmpty) ...[
            const FlatDivider(),
            FlatSection(
              child: BookingPriceSummary(
                dong: _dongTien(context, giaNgay, beChon.length),
                ghiChu: l10n.ghiChuPhuPhiNccTuDat,
              ),
            ),
          ],
        ],
      ),
      bottomBar: BookingBottomBar(
        tongTien: xong ? _tong(giaNgay, beChon.length) : null,
        choPhep: xong,
        onTiepTuc: () =>
            _tiepTuc(beChon, _tong(giaNgay!, beChon.length), diaChi),
      ),
    );
  }

  void _doiChon(Pet be) {
    setState(() {
      if (_beDaChon.contains(be.id)) {
        _beDaChon.remove(be.id);
        return;
      }
      if (_beDaChon.length >= (_config.maxPets ?? 1)) return;
      _beDaChon.add(be.id);
    });
  }

  String _nhaNcc(BuildContext context) {
    final l10n = context.l10n;
    final sitter = widget.args.sitter;
    final nhan = l10n.nhaCuaNcc(sitter.fullName);
    final khoangCach = sitter.distanceKm;
    if (khoangCach == null) return nhan;
    return '$nhan · ${l10n.cachBan(l10n.soKm(soLeKm(khoangCach)))}';
  }

  Future<void> _chonDiaChi(
    BuildContext context,
    List<SavedAddress> daLuu,
  ) async {
    if (daLuu.isEmpty) {
      context.push(AppRoutes.addAddress);
      return;
    }
    final chon = await context.push<SavedAddress>(
      AppRoutes.bookingPickupAddress,
      extra: widget.args,
    );
    if (chon != null) setState(() => _diaChi = chon);
  }

  SavedAddress? _macDinh(List<SavedAddress> daLuu) {
    if (daLuu.isEmpty) return null;
    for (final d in daLuu) {
      if (d.isDefault) return d;
    }
    return daLuu.first;
  }

  String _ghiChuSoBe(BuildContext context) {
    final l10n = context.l10n;
    final toiDa = _config.maxPets ?? 1;
    if (toiDa <= 1 || _config.additionalPetFee == null) {
      return l10n.nhanToiDaNBeMoiDon('$toiDa');
    }
    return '${l10n.nhanToiDaNBeMoiDon('$toiDa')} '
        '${l10n.beThuHaiTroDiPhuPhi(dinhDangTien(_config.additionalPetFee!))}';
  }

  int _tong(int giaNgay, int soBe) =>
      (giaNgay + (_config.additionalPetFee ?? 0) * (soBe - 1)) * _demTamTinh;

  List<DongTien> _dongTien(BuildContext context, int giaNgay, int soBe) {
    final l10n = context.l10n;
    final phuPhi = _config.additionalPetFee ?? 0;
    return [
      (
        nhan: l10n.dongBeDauMoiDem(dinhDangTien(giaNgay), '$_demTamTinh'),
        tien: giaNgay * _demTamTinh,
      ),
      if (soBe > 1)
        (
          nhan: l10n.dongPhuPhiThemNBeMoiDem(
            '${soBe - 1}',
            dinhDangTien(phuPhi),
            '$_demTamTinh',
          ),
          tien: phuPhi * (soBe - 1) * _demTamTinh,
        ),
    ];
  }

  Future<void> _tiepTuc(
    List<Pet> beChon,
    int tong,
    SavedAddress? diaChi,
  ) async {
    final nho = _ngayGioDaChon;
    final kq = await context.push<YeuCauSua>(
      AppRoutes.bookingDateTime,
      extra: BookingDraft(
        sitter: widget.args.sitter,
        loai: ServiceType.boarding,
        pets: beChon,
        tamTinh: tong,
        giaMotDem: tong,
        diaChiChon: diaChi,
        ghiChu: _ghiChu.text.trim(),
        ngay: nho?.ngay,
        gio: nho?.gio,
        ngayTra: nho?.ngayTra,
        gioTra: nho?.gioTra,
      ),
    );
    if (kq == null || !mounted) return;
    _quayLai(kq);
  }

  void _quayLai(YeuCauSua kq) {
    setState(() {
      _ngayGioDaChon = kq.draft;
      _diaChi = kq.draft.diaChiChon ?? _diaChi;
    });
    switch (kq.muc) {
      case MucSuaDon.thuCung:
        cuonToi(_khoaChonBe);
      case MucSuaDon.ghiChu:
        cuonToi(_khoaGhiChu);
      case null:
        break;
    }
  }
}

// Lý do một bé không chọn được
String? _lyDoMo(BuildContext context, Pet be, SitterServices s) {
  final l10n = context.l10n;
  final ly = lyDoBeKhongChon(be, s, ServiceType.boarding);
  return switch (ly) {
    null => null,
    LyDoBeKhongChon.khongHopLoai => l10n.chiNhanLoai(
      petKindLabel(context, loaiNhanCua(s, ServiceType.boarding)).toLowerCase(),
    ),
    LyDoBeKhongChon.vuotCan => l10n.nangSoKg(canNangGon(be.weightKg)),
  };
}
