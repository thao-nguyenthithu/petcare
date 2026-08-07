import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_breeds.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/pets/services/pet_error_mapper.dart';
import 'package:petcare_app/features/pets/screens/pet_health_screen.dart';
import 'package:petcare_app/features/pets/widgets/delete_photo_sheet.dart';
import 'package:petcare_app/features/pets/widgets/pet_basic_info_section.dart';
import 'package:petcare_app/features/pets/widgets/pet_care_note_section.dart';
import 'package:petcare_app/features/pets/widgets/pet_photos_section.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/step_progress_bar.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/choice_sheet.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const _tuoiToiDa = 30;
const _canNangToiDa = 100;

// Form thông tin bé, bước 1 trong 2
class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key, this.petSua});

  final Pet? petSua;

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _giongController = TextEditingController();
  final _ngaySinhController = TextEditingController();
  final _canNangController = TextEditingController();
  final _luuYController = TextEditingController();

  final _anh = <PetPhoto>[];
  PetSpecies _loai = PetSpecies.dog;
  PetGender _gioiTinh = PetGender.male;
  DateTime? _ngaySinh;

  bool _dirty = false;
  bool _autoValidate = false;
  String? _maGiong;

  bool get _dangSua => widget.petSua != null;

  @override
  void initState() {
    super.initState();
    if (widget.petSua case final pet?) {
      _tenController.text = pet.name;
      _loai = pet.species;
      _maGiong = pet.breed;
      _canNangController.text = canNangGon(pet.weightKg);
      _gioiTinh = pet.gender;
      _ngaySinh = pet.birthDate;
      if (pet.birthDate case final ngay?) {
        _ngaySinhController.text = ngayThangNam(ngay);
      }
      _luuYController.text = pet.luuYChamSoc ?? '';
      _anh.addAll([
        for (final a in pet.anh)
          PetPhoto(id: a.id, url: a.url, addedAt: a.ngayThem ?? nowVn()),
      ]);
    }
    for (final c in [
      _tenController,
      _giongController,
      _canNangController,
      _luuYController,
    ]) {
      c.addListener(_markDirty);
    }
  }

  // Đổi ngôn ngữ thì tên giống trong ô phải đổi theo mã đang giữ
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_maGiong case final ma?) _giongController.text = tenGiong(context, ma);
  }

  @override
  void dispose() {
    _tenController.dispose();
    _giongController.dispose();
    _ngaySinhController.dispose();
    _canNangController.dispose();
    _luuYController.dispose();
    super.dispose();
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

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _themAnh() async {
    final conCho = maxPetPhotos - _anh.length;
    final chon = await chonNhieuAnh(conCho);
    if (!mounted) return;
    if (chon.quaNang > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.loiNhieuAnhQuaNang('${chon.quaNang}', '$mbAnhToiDa'),
          ),
        ),
      );
    }
    if (chon.anh.isEmpty) return;
    final bayGio = nowVn();
    setState(() {
      _dirty = true;
      _anh.addAll(
        chon.anh.map((bytes) => PetPhoto(bytes: bytes, addedAt: bayGio)),
      );
    });
    if (chon.du) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.daDuSoAnhToiDa('$maxPetPhotos'))),
      );
    }
  }

  Future<void> _xemAnh(int viTri) async {
    final l10n = context.l10n;
    final ten = _tenController.text.trim();
    await showPhotoViewer(
      context,
      anh: [for (final a in _anh) a.item],
      viTri: viTri,
      phuDe: ten.isEmpty ? l10n.anhCuaBe : l10n.anhCuaBeTen(ten),
      hanhDong: [
        PhotoViewerAction(
          icon: Icons.star_outline,
          label: l10n.datLamDaiDien,
          // Ảnh đầu là đại diện
          tatKhi: (i) => i == 0,
          onTap: (i) async {
            final anh = _anh[i];
            if (widget.petSua case final pet? when anh.daTaiLen) {
              final ok = await _goi(
                () => ref
                    .read(myPetsProvider.notifier)
                    .datAnhDaiDien(pet.id, anh.id!),
              );
              if (ok == null) return false;
            }
            setState(() {
              _dirty = true;
              _anh.insert(0, _anh.removeAt(i));
            });
            return true;
          },
        ),
        PhotoViewerAction(
          icon: Icons.delete_outline,
          label: l10n.xoaAnh,
          nguyHiem: true,
          onTap: (i) async {
            final dongY = await showDeletePhotoSheet(
              context,
              anh: _anh[i],
              viTri: i,
              tong: _anh.length,
              laDaiDien: i == 0,
            );
            if (!dongY) return false;
            final anh = _anh[i];
            if (widget.petSua case final pet? when anh.daTaiLen) {
              final ok = await _goi(
                () =>
                    ref.read(myPetsProvider.notifier).xoaAnh(pet.id, [anh.id!]),
              );
              if (ok == null) return false;
            }
            setState(() {
              _dirty = true;
              _anh.removeAt(i);
            });
            return true;
          },
        ),
      ],
    );
  }

  Future<void> _chonGiong() async {
    final danhSach = giongTheoLoai(_loai);
    final chon = await showChoiceSheet<PetBreed>(
      context: context,
      items: danhSach,
      labelOf: (giong) => tenGiong(context, giong.ma),
      selected: danhSach.where((g) => g.ma == _maGiong).firstOrNull,
    );
    if (chon == null || !mounted) return;
    setState(() {
      _dirty = true;
      _maGiong = chon.ma;
      _giongController.text = tenGiong(context, chon.ma);
    });
  }

  Future<void> _chonNgaySinh() async {
    final homNay = nowVn();
    final chon = await showDatePicker(
      context: context,
      initialDate: _ngaySinh ?? homNay,
      firstDate: DateTime(homNay.year - _tuoiToiDa),
      lastDate: homNay,
    );
    if (chon == null) return;
    setState(() {
      _dirty = true;
      _ngaySinh = chon;
      _ngaySinhController.text = ngayThangNam(chon);
    });
  }

  // Đổi loài thì giống cũ không còn hợp, phải chọn lại
  void _doiLoai(PetSpecies loai) {
    if (loai == _loai) return;
    setState(() {
      _dirty = true;
      _loai = loai;
      _maGiong = null;
      _giongController.clear();
    });
  }

  String? _vBatBuoc(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.khongDuocDeTrong : null;

  String? _vCanNang(String? v) {
    final so = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    if (so == null || so <= 0) return context.l10n.khongDuocDeTrong;
    if (so > _canNangToiDa) {
      return context.l10n.loiCanNangVuotTran('$_canNangToiDa');
    }
    return null;
  }

  void _tiepTuc() {
    if (!_autoValidate) setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? true)) return;
    context.push(
      AppRoutes.addPetHealth,
      extra: PetHealthArgs(
        buoc1: Pet(
          id: widget.petSua?.id ?? '',
          name: _tenController.text.trim(),
          species: _loai,
          breed: _maGiong ?? maGiongKhac,
          weightKg:
              double.tryParse(
                _canNangController.text.trim().replaceAll(',', '.'),
              ) ??
              0,
          gender: _gioiTinh,
          birthDate: _ngaySinh,
          luuYChamSoc: _luuYController.text.trim().isEmpty
              ? null
              : _luuYController.text.trim(),
        ),
        anhMoi: [for (final a in _anh) ?a.bytes],
        petSua: widget.petSua,
      ),
    );
  }

  Future<void> _onBack() async {
    if (!_dirty) {
      context.pop();
      return;
    }
    final l10n = context.l10n;
    final thoat = await showConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: l10n.thoatKhongLuuTitle,
      message: l10n.thoatKhongLuuMoTa,
      confirmLabel: l10n.thoatKhongLuu,
      danger: true,
    );
    if (thoat && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: AppScreen(
        header: Column(
          children: [
            AppScreenHeader(
              title: _dangSua ? l10n.suaHoSoBe : l10n.themThuCung,
              subtitle: l10n.buocTrenTong('1', '2'),
              onBack: _onBack,
            ),
            const StepProgressBar(
              buoc: 1,
              tong: 2,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.itemGap,
              ),
            ),
            const AppDongKe(),
          ],
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: _autoValidate
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.blockGap,
            ),
            children: [
              PetPhotosSection(anh: _anh, onThem: _themAnh, onXemAnh: _xemAnh),
              const AppDongKe(dem: true),
              PetBasicInfoSection(
                tenController: _tenController,
                giongController: _giongController,
                ngaySinhController: _ngaySinhController,
                canNangController: _canNangController,
                loai: _loai,
                gioiTinh: _gioiTinh,
                onDoiLoai: _doiLoai,
                onDoiGioiTinh: (gioi) => setState(() {
                  _dirty = true;
                  _gioiTinh = gioi;
                }),
                onChonGiong: _chonGiong,
                onChonNgaySinh: _chonNgaySinh,
                validatorTen: _vBatBuoc,
                validatorCanNang: _vCanNang,
              ),
              const AppDongKe(dem: true),
              PetCareNoteSection(controller: _luuYController),
            ],
          ),
        ),
        bottomBar: BottomActionBar(
          child: AppButton(text: l10n.tiepTuc, onTap: _tiepTuc),
        ),
      ),
    );
  }
}
