import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/pets/services/pet_error_mapper.dart';
import 'package:petcare_app/features/pets/screens/prevention_detail_screen.dart';
import 'package:petcare_app/features/pets/widgets/add_prevention_sheet.dart';
import 'package:petcare_app/features/pets/widgets/pet_documents_section.dart';
import 'package:petcare_app/features/pets/widgets/pet_general_health_section.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/step_progress_bar.dart';
import 'package:petcare_app/features/pets/widgets/prevention_section.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

// Tham số từ bước 1 sang bước 2
class PetHealthArgs {
  const PetHealthArgs({
    required this.buoc1,
    this.anhMoi = const [],
    this.petSua,
  });

  final Pet buoc1;
  final List<Uint8List> anhMoi;
  final Pet? petSua;
}

// Bước 2 trong 2 của luồng thêm thú cưng
class PetHealthScreen extends ConsumerStatefulWidget {
  const PetHealthScreen({super.key, required this.args});

  final PetHealthArgs args;

  String get tenBe => args.buoc1.name;
  PetSpecies get loaiBe => args.buoc1.species;
  Pet? get petSua => args.petSua;

  @override
  ConsumerState<PetHealthScreen> createState() => _PetHealthScreenState();
}

class _PetHealthScreenState extends ConsumerState<PetHealthScreen> {
  final _benhNenController = TextEditingController();
  final _thuocController = TextEditingController();

  // Mặc định theo trường hợp phổ biến nhất
  late bool _daTrietSan = widget.petSua?.daTrietSan ?? false;
  late bool _dangDieuTri = widget.petSua?.dangDieuTri ?? false;

  // Hạng mục của bé chưa lưu thì giữ tạm trong bộ nhớ tới lúc bấm Lưu
  late final List<PreventionRecord> _phongBenh = [...?widget.petSua?.phongBenh];
  String? get _petId => widget.petSua?.id;
  bool _dangLuu = false;

  @override
  void initState() {
    super.initState();
    if (widget.petSua case final pet?) {
      _benhNenController.text = pet.benhNen ?? '';
      _thuocController.text = pet.thuocDangDung ?? '';
    }
  }

  @override
  void dispose() {
    _benhNenController.dispose();
    _thuocController.dispose();
    super.dispose();
  }

  // Ảnh phiếu của mọi lần trong mọi hạng mục gom về mục Giấy tờ của bé
  List<PetDocument> get _giayTo => giayToCuaBe(_phongBenh);

  // Chọn hạng mục ở sheet
  Future<void> _themHangMuc() async {
    final chon = await showAddPreventionSheet(
      context,
      tenBe: widget.tenBe,
      loaiBe: widget.loaiBe,
      daCo: _phongBenh,
    );
    if (chon == null || !mounted) return;
    final muc = chon.muc;
    final hangMuc = PreventionRecord(
      id: '$idTamHangMuc${DateTime.now().microsecondsSinceEpoch}',
      ma: muc.ma,
      tenTuNhap: chon.tenTuNhap,
      hinhThuc: muc.hinhThuc,
      dinhKy: muc.dinhKy,
      chuKyDeXuat: muc.chuKyDeXuat,
      lanThucHien: const [],
    );
    if (_petId case final id?) {
      final moi = await _goi(
        () => ref.read(myPetsProvider.notifier).themHangMuc(id, hangMuc),
      );
      if (moi == null || !mounted) return;
      setState(() {
        _phongBenh
          ..clear()
          ..addAll(moi.phongBenh);
      });
      final vuaTao = moi.phongBenh.lastWhere(
        (e) => e.ma == hangMuc.ma,
        orElse: () => moi.phongBenh.last,
      );
      await _moChiTiet(vuaTao);
      return;
    }
    setState(() => _phongBenh.add(hangMuc));
    await _moChiTiet(hangMuc);
  }

  // Gọi API kèm bắt lỗi
  Future<T?> _goi<T>(Future<T> Function() viec) async {
    try {
      return await viec();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(moTaLoiThuCung(context, e))));
      }
      return null;
    }
  }

  // Mở chi tiết hạng mục
  Future<void> _moChiTiet(PreventionRecord hangMuc) async {
    final ketQua = await context.push<PreventionDetailResult>(
      AppRoutes.preventionDetail,
      extra: PreventionDetailArgs(
        hangMuc: hangMuc,
        tenBe: widget.tenBe,
        petId: _petId,
      ),
    );
    if (ketQua == null || !mounted) return;
    // Bé đã lưu thì màn chi tiết đã gọi API, chỉ cần lấy lại bản mới nhất
    if (_petId case final id?) {
      final be = ref.read(petTheoIdProvider(id));
      if (be != null) {
        setState(() {
          _phongBenh
            ..clear()
            ..addAll(be.phongBenh);
        });
      }
      return;
    }
    setState(() {
      final viTri = _phongBenh.indexWhere((m) => m.id == ketQua.hangMuc.id);
      if (viTri < 0) return;
      switch (ketQua.hanhDong) {
        case PreventionDetailAction.luu:
          _phongBenh[viTri] = ketQua.hangMuc;
        case PreventionDetailAction.xoa:
          _phongBenh.removeAt(viTri);
      }
    });
  }

  // Mở cả chồng ảnh của một hạng mục
  Future<void> _xemGiayTo(PetDocumentGroup nhom) => showPhotoViewer(
    context,
    anh: [for (final muc in nhom.anh) muc.anh],
    phuDe: preventionPhotoLabel(context, nhom.hangMuc),
  );

  // Lưu cả hồ sơ
  Future<void> _luuHoSo() async {
    if (_dangLuu) return;
    final router = GoRouter.of(context);
    setState(() => _dangLuu = true);
    final xong = await _thucHienLuu();
    if (!mounted) return;
    setState(() => _dangLuu = false);
    if (!xong) return;
    router.pop();
    if (router.canPop()) router.pop();
  }

  Future<bool> _thucHienLuu() async {
    final buoc1 = widget.args.buoc1;
    final hoSo = Pet(
      id: widget.petSua?.id ?? '',
      name: buoc1.name,
      species: buoc1.species,
      breed: buoc1.breed,
      weightKg: buoc1.weightKg,
      gender: buoc1.gender,
      birthDate: buoc1.birthDate,
      luuYChamSoc: buoc1.luuYChamSoc,
      daTrietSan: _daTrietSan,
      dangDieuTri: _dangDieuTri,
      benhNen: _chuoiHoacNull(_benhNenController),
      thuocDangDung: _chuoiHoacNull(_thuocController),
    );
    final daLuu = await _goi(
      () => ref
          .read(myPetsProvider.notifier)
          .luuHoSoDayDu(
            hoSo: hoSo,
            anhMoi: widget.args.anhMoi,
            hangMucTam: _phongBenh,
            dangSua: widget.petSua != null,
          ),
    );
    return daLuu != null;
  }

  String? _chuoiHoacNull(TextEditingController c) {
    final chu = c.text.trim();
    return chu.isEmpty ? null : chu;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.sucKhoeCuaBe(widget.tenBe),
              subtitle: l10n.buocTrenTong('2', '2'),
            ),
            const StepProgressBar(
              buoc: 2,
              tong: 2,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.itemGap,
              ),
            ),
            const AppDongKe(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.blockGap,
                ),
                children: [
                  AppNoteBox(text: l10n.ghiChuHoSoTiemChung),
                  const SizedBox(height: AppSpacing.blockGap),
                  PetGeneralHealthSection(
                    daTrietSan: _daTrietSan,
                    dangDieuTri: _dangDieuTri,
                    onDoiTrietSan: (v) => setState(() => _daTrietSan = v),
                    onDoiSucKhoe: (v) => setState(() => _dangDieuTri = v),
                    benhNenController: _benhNenController,
                    thuocController: _thuocController,
                  ),
                  const AppDongKe(dem: true),
                  PreventionSection(
                    phongBenh: _phongBenh,
                    onChonMui: _moChiTiet,
                    onThemMui: _themHangMuc,
                  ),
                  const AppDongKe(dem: true),
                  PetDocumentsSection(giayTo: _giayTo, onXemNhom: _xemGiayTo),
                ],
              ),
            ),
            BottomActionBar(
              child: AppButton(
                text: l10n.luuHoSoCuaBe(widget.tenBe),
                dangTai: _dangLuu,
                onTap: _luuHoSo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
