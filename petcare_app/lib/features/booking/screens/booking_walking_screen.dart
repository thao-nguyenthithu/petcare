import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/booking_check.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/features/booking/widgets/booking_bottom_bar.dart';
import 'package:petcare_app/features/booking/widgets/booking_header.dart';
import 'package:petcare_app/shared/widgets/booking_pet_notes.dart';
import 'package:petcare_app/features/booking/widgets/booking_pet_picker.dart';
import 'package:petcare_app/features/booking/widgets/booking_place_note.dart';
import 'package:petcare_app/features/booking/widgets/booking_price_summary.dart';
import 'package:petcare_app/features/booking/widgets/walking_duration_picker.dart';
import 'package:petcare_app/shared/widgets/walking_gear_commitment.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/cuon_toi.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/data/booking_args.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Trang đặt lịch Dắt đi dạo
class BookingWalkingScreen extends ConsumerStatefulWidget {
  const BookingWalkingScreen({super.key, required this.args});

  final BookingArgs args;

  @override
  ConsumerState<BookingWalkingScreen> createState() =>
      _BookingWalkingScreenState();
}

class _BookingWalkingScreenState extends ConsumerState<BookingWalkingScreen> {
  final _ghiChu = TextEditingController();
  final _beDaChon = <String>{};
  final _khoaChonBe = GlobalKey();
  final _khoaGhiChu = GlobalKey();
  int? _phut;
  SavedAddress? _diaChi;
  bool _daCamDungCu = false;

  BookingDraft? _ngayGioDaChon;

  WalkingConfig get _config => widget.args.sitter.services!.walking;

  int get _tranSoBe =>
      soBeToiDaCua(widget.args.sitter.services!, ServiceType.walking) ??
      soBeToiDaDonDat;

  @override
  void initState() {
    super.initState();
    final coGia = walkingDurations
        .where((p) => _config.priceByDuration[p] != null)
        .toList();
    if (coGia.length == 1) _phut = coGia.first;
  }

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

    final toiDa = _tranSoBe;
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
    final thieuDiaChi = diaChi == null;
    final giaGoi = _phut == null ? null : _config.priceByDuration[_phut!];
    final duThongTin = beChon.isNotEmpty && giaGoi != null && !thieuDiaChi;
    final xong = duThongTin && _daCamDungCu;
    final tong = duThongTin ? _tong(giaGoi, beChon.length) : null;

    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          BookingHeader(
            tieuDe: l10n.datLich,
            tenNcc: sitter.fullName,
            tenDichVu: serviceTypeName(context, ServiceType.walking),
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
            child: WalkingDurationPicker(
              tenNcc: sitter.fullName,
              config: _config,
              chon: _phut,
              onChon: (p) => setState(() => _phut = p),
            ),
          ),
          const FlatDivider(),
          FlatSection(
            key: _khoaGhiChu,
            child: BookingPlaceNote(
              tieuDe: l10n.diemDonVaGhiChuDon,
              icon: Icons.location_on_outlined,
              nhan: l10n.diemDon,
              giaTri: diaChi?.diaChiDayDu,
              nhanHanhDong: thieuDiaChi ? l10n.them : l10n.doi,
              onHanhDong: () => _chonDiaChi(context, diaChiDaLuu),
              ghiChu: _ghiChu,
              loi: thieuDiaChi ? l10n.themDiaChiDeTiepTuc : null,
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: WalkingGearCommitment(
              soBe: beChon.length,
              daCam: _daCamDungCu,
              onDoi: (v) => setState(() => _daCamDungCu = v),
              loi: duThongTin && !_daCamDungCu
                  ? l10n.camKetDungCuDeTiepTuc
                  : null,
            ),
          ),
          if (giaGoi != null && beChon.isNotEmpty) ...[
            const FlatDivider(),
            FlatSection(
              child: BookingPriceSummary(
                dong: _dongTien(context, giaGoi, beChon.length),
                ghiChu: l10n.ghiChuPhuPhiNccTuDat,
              ),
            ),
          ],
        ],
      ),
      bottomBar: BookingBottomBar(
        tongTien: tong,
        choPhep: xong,
        onTiepTuc: () => _tiepTuc(beChon, diaChi, tong),
      ),
    );
  }

  void _doiChon(Pet be) {
    setState(() {
      if (_beDaChon.contains(be.id)) {
        _beDaChon.remove(be.id);
        return;
      }
      if (_beDaChon.length >= _tranSoBe) return;
      _beDaChon.add(be.id);
    });
  }

  SavedAddress? _macDinh(List<SavedAddress> ds) {
    if (ds.isEmpty) return null;
    return ds.firstWhere((e) => e.isDefault, orElse: () => ds.first);
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

  String _ghiChuSoBe(BuildContext context) {
    final l10n = context.l10n;
    final toiDa = _tranSoBe;
    if (toiDa <= 1 || _config.additionalPetFee == null) {
      return l10n.nhanToiDaNBeMoiLuot('$toiDa');
    }
    return '${l10n.nhanToiDaNBeMoiLuot('$toiDa')} '
        '${l10n.beThuHaiTroDiPhuPhi(dinhDangTien(_config.additionalPetFee!))}';
  }

  int _tong(int giaGoi, int soBe) =>
      giaGoi + (_config.additionalPetFee ?? 0) * (soBe - 1);

  List<DongTien> _dongTien(BuildContext context, int giaGoi, int soBe) {
    final l10n = context.l10n;
    final phuPhi = _config.additionalPetFee ?? 0;
    return [
      (
        nhan: l10n.dongBeDauGoi(dinhDangTien(giaGoi), l10n.nPhut('$_phut')),
        tien: giaGoi,
      ),
      if (soBe > 1)
        (
          nhan: l10n.dongPhuPhiThemNBe('${soBe - 1}', dinhDangTien(phuPhi)),
          tien: phuPhi * (soBe - 1),
        ),
    ];
  }

  Future<void> _tiepTuc(
    List<Pet> beChon,
    SavedAddress? diaChi,
    int? tong,
  ) async {
    final nho = _ngayGioDaChon;
    final kq = await context.push<YeuCauSua>(
      AppRoutes.bookingDateTime,
      extra: BookingDraft(
        sitter: widget.args.sitter,
        loai: ServiceType.walking,
        pets: beChon,
        tamTinh: tong!,
        phutMotLuot: _phut,
        camKetDungCu: _daCamDungCu,
        diaChiChon: diaChi,
        ghiChu: _ghiChu.text.trim(),
        ngay: nho?.ngay,
        gio: nho?.gio,
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

String? _lyDoMo(BuildContext context, Pet be, SitterServices s) {
  final l10n = context.l10n;
  final ly = lyDoBeKhongChon(be, s, ServiceType.walking);
  return switch (ly) {
    null => null,
    LyDoBeKhongChon.khongHopLoai => l10n.chiNhanLoai(
      petKindLabel(context, loaiNhanCua(s, ServiceType.walking)).toLowerCase(),
    ),
    LyDoBeKhongChon.vuotCan => l10n.nangSoKg(canNangGon(be.weightKg)),
  };
}
