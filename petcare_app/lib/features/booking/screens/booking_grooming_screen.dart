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
import 'package:petcare_app/features/booking/widgets/grooming_package_picker.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/cuon_toi.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/data/booking_args.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Trang đặt lịch Tắm và cắt tỉa tại nhà
class BookingGroomingScreen extends ConsumerStatefulWidget {
  const BookingGroomingScreen({super.key, required this.args});

  final BookingArgs args;

  @override
  ConsumerState<BookingGroomingScreen> createState() =>
      _BookingGroomingScreenState();
}

class _BookingGroomingScreenState extends ConsumerState<BookingGroomingScreen> {
  final _ghiChu = TextEditingController();
  final _beDaChon = <String>{};
  final _goiTheoBe = <String, GroomingPackage>{};
  final _khoaChonBe = GlobalKey();
  final _khoaGhiChu = GlobalKey();
  SavedAddress? _diaChi;

  BookingDraft? _ngayGioDaChon;

  GroomingConfig get _config => widget.args.sitter.services!.grooming;

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
    final thieuDiaChi = diaChi == null;
    final duGoi =
        beChon.isNotEmpty && beChon.every((b) => _giaCuaBe(b) != null);
    final tongPhut = beChon.fold<int>(0, (t, b) => t + (_phutCuaBe(b) ?? 0));
    final vuotThoiLuong = tongPhut > phutToiDaDonGrooming;
    final xong = duGoi && !thieuDiaChi && !vuotThoiLuong;
    final tong = duGoi
        ? beChon.fold(0, (t, b) => t + (_giaCuaBe(b) ?? 0))
        : null;

    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          BookingHeader(
            tieuDe: l10n.datLich,
            tenNcc: sitter.fullName,
            tenDichVu: l10n.tamVaCatTiaTaiNha,
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
              ghiChu: pets.isEmpty ? null : l10n.nhanToiDaNBeMoiLuot('$toiDa'),
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
          if (beChon.isNotEmpty) ...[
            const FlatDivider(),
            FlatSection(
              child: GroomingPackagePicker(
                pets: beChon,
                config: _config,
                goiTheoBe: _goiTheoBe,
                onChon: (be, goi) => setState(() => _goiTheoBe[be.id] = goi),
              ),
            ),
            if (vuotThoiLuong)
              FlatSection(
                child: AppNoteBox(
                  kieu: NoteKind.canhBao,
                  text: l10n.loiVuotTongThoiLuongGrooming(
                    '${tongPhut ~/ 60}',
                    '${phutToiDaDonGrooming ~/ 60}',
                  ),
                ),
              ),
          ],
          const FlatDivider(),
          FlatSection(
            key: _khoaGhiChu,
            child: BookingPlaceNote(
              tieuDe: l10n.diaDiemVaGhiChuDon,
              icon: Icons.home_outlined,
              nhan: l10n.lamTai,
              giaTri: diaChi?.diaChiDayDu,
              nhanHanhDong: thieuDiaChi ? l10n.them : l10n.doi,
              onHanhDong: () => _chonDiaChi(context, diaChiDaLuu),
              ghiChu: _ghiChu,
              loi: thieuDiaChi ? l10n.themDiaChiDeTiepTuc : null,
            ),
          ),
          if (duGoi) ...[
            const FlatDivider(),
            FlatSection(
              child: BookingPriceSummary(
                dong: [
                  for (final be in beChon)
                    (
                      nhan:
                          '${be.name} · '
                          '${groomingPackageName(context, _goiTheoBe[be.id]!)}',
                      tien: _giaCuaBe(be)!,
                    ),
                ],
                ghiChu: l10n.ghiChuGiaGroomingTungBe,
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
        _goiTheoBe.remove(be.id);
        return;
      }
      if (_beDaChon.length >= (_config.maxPets ?? 1)) return;
      _beDaChon.add(be.id);
    });
  }

  int? _phutCuaBe(Pet be) {
    final goi = _goiTheoBe[be.id];
    final muc = mucCanCua(be.weightKg);
    if (goi == null || muc == null) return null;
    return _config.phutCua(goi, muc);
  }

  int? _giaCuaBe(Pet be) {
    final goi = _goiTheoBe[be.id];
    final muc = mucCanCua(be.weightKg);
    if (goi == null || muc == null) return null;
    return _config.priceByPackage[goi]?[muc];
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
        loai: ServiceType.grooming,
        pets: beChon,
        tamTinh: tong!,
        goiTheoBe: Map.of(_goiTheoBe),
        phutGrooming: beChon.fold<int>(0, (t, b) => t + (_phutCuaBe(b) ?? 0)),
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
  final ly = lyDoBeKhongChon(be, s, ServiceType.grooming);
  return switch (ly) {
    null => null,
    LyDoBeKhongChon.khongHopLoai => l10n.chiNhanLoai(
      petKindLabel(context, loaiNhanCua(s, ServiceType.grooming)).toLowerCase(),
    ),
    LyDoBeKhongChon.vuotCan => l10n.nangSoKg(canNangGon(be.weightKg)),
  };
}
