import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/pets/services/pet_error_mapper.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/features/pets/widgets/prevention_photo_row.dart';
import 'package:petcare_app/features/pets/widgets/prevention_reminder_field.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/locked_field.dart';
import 'package:petcare_app/shared/widgets/photo_source_sheet.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

// Tham số vào form: hạng mục đang khai
class PreventionDoseFormArgs {
  const PreventionDoseFormArgs({
    required this.tenBe,
    required this.hangMuc,
    this.lanSua,
    this.petId,
  });
  final String? petId;

  final String tenBe;
  final PreventionRecord hangMuc;
  final PreventionDose? lanSua;
}

const int _soNamLuiToiDa = 30;

// Form ghi lần thực hiện mới hoặc sửa lần đã có
class PreventionDoseFormScreen extends ConsumerStatefulWidget {
  const PreventionDoseFormScreen({super.key, required this.args});

  final PreventionDoseFormArgs args;

  @override
  ConsumerState<PreventionDoseFormScreen> createState() =>
      _PreventionDoseFormScreenState();
}

class _PreventionDoseFormScreenState
    extends ConsumerState<PreventionDoseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ngayThucHienController = TextEditingController();
  final _noiThucHienController = TextEditingController();
  final _soChuKyController = TextEditingController();

  DateTime? _ngayThucHien;

  // Có đặt nhắc lại hay không
  bool _coNhacLai = true;
  CycleUnit _donViChuKy = CycleUnit.thang;
  final _anh = <PhotoItem>[];

  bool _dirty = false;
  bool _autoValidate = false;
  bool _dangLuu = false;

  PreventionRecord get _hangMuc => widget.args.hangMuc;
  String? get _petId => widget.args.petId;
  PreventionDose? get _lanSua => widget.args.lanSua;
  bool get _dangSua => _lanSua != null;

  @override
  void initState() {
    super.initState();
    _datChuKy(_lanSua?.chuKy ?? _hangMuc.chuKyHienHanh);
    if (_lanSua case final lan?) {
      _ngayThucHien = lan.ngay;
      _ngayThucHienController.text = ngayThangNam(lan.ngay);
      _noiThucHienController.text = lan.noiThucHien ?? '';
      _anh.addAll(lan.anh);
    }
    _noiThucHienController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _ngayThucHienController.dispose();
    _noiThucHienController.dispose();
    _soChuKyController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  // Đổ chu kỳ vào ô nhập
  void _datChuKy(PreventionCycle? chuKy) {
    _coNhacLai = chuKy != null;
    if (chuKy == null) return;
    _soChuKyController.text = '${chuKy.so}';
    _donViChuKy = chuKy.donVi;
  }

  // Chu kỳ đang áp dụng
  PreventionCycle? get _chuKy {
    if (!_coNhacLai) return null;
    final so = int.tryParse(_soChuKyController.text.trim()) ?? 0;
    return so > 0 ? PreventionCycle(so, _donViChuKy) : null;
  }

  DateTime? get _ngayToiHan {
    final ngay = _ngayThucHien;
    final chuKy = _chuKy;
    if (ngay == null || chuKy == null) return null;
    return chuKy.apDung(ngay);
  }

  void _datNgay(DateTime ngay) {
    setState(() {
      _dirty = true;
      _ngayThucHien = ngay;
      _ngayThucHienController.text = ngayThangNam(ngay);
    });
  }

  Future<void> _chonNgayThucHien() async {
    final homNay = nowVn();
    final chon = await showDatePicker(
      context: context,
      initialDate: _ngayThucHien ?? homNay,
      firstDate: DateTime(homNay.year - _soNamLuiToiDa),
      lastDate: homNay,
    );
    if (chon == null) return;
    _datNgay(chon);
  }

  // Cho chụp thẳng phiếu vừa nhận hoặc lấy ảnh đã chụp sẵn trong máy
  Future<void> _themAnh() async {
    final conCho = maxPreventionPhotos - _anh.length;
    if (conCho <= 0) return;
    final nguon = await showPhotoSourceSheet(
      context,
      tieuDe: context.l10n.anhPhieuHoacHoaDon,
    );
    if (nguon == null || !mounted) return;
    final them = <Uint8List>[];
    var du = false;
    if (nguon == ImageSource.camera) {
      final anh = await chupMotAnh();
      if (anh != null) them.add(anh);
    } else {
      final chon = await chonNhieuAnh(conCho);
      them.addAll(chon.anh);
      du = chon.du;
    }
    if (!mounted || them.isEmpty) return;
    final bayGio = nowVn();
    setState(() {
      _dirty = true;
      _anh.addAll(them.map((b) => PhotoItem.bytes(b, ngayThem: bayGio)));
    });
    if (du) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.daDuSoAnhToiDa('$maxPreventionPhotos')),
        ),
      );
    }
  }

  Future<void> _xemAnh(int viTri) async {
    final l10n = context.l10n;
    await showPhotoViewer(
      context,
      anh: _anh,
      viTri: viTri,
      phuDe: preventionTitle(context, _hangMuc),
      hanhDong: [
        PhotoViewerAction(
          icon: Icons.delete_outline,
          label: l10n.xoaAnh,
          nguyHiem: true,
          onTap: (i) async {
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

  String? _vBatBuoc(String? v) =>
      (v == null || v.trim().isEmpty) ? context.l10n.khongDuocDeTrong : null;

  Future<void> _luu() async {
    if (_dangLuu) return;
    if (!_autoValidate) setState(() => _autoValidate = true);
    if (!(_formKey.currentState?.validate() ?? true)) return;
    final noi = _noiThucHienController.text.trim();
    final lan = PreventionDose(
      id:
          _lanSua?.id ??
          '$idTamHangMuc${DateTime.now().microsecondsSinceEpoch}',
      ngay: _ngayThucHien!,
      chuKy: _chuKy,
      noiThucHien: noi.isEmpty ? null : noi,
      anh: [..._anh],
    );
    // Bé đã có trên server thì ghi thẳng lên
    if (_petId case final id?) {
      final anhMoi = [for (final a in _anh) ?a.bytes];
      setState(() => _dangLuu = true);
      final ket = await _goiApi(id, lan, anhMoi);
      if (!mounted) return;
      setState(() => _dangLuu = false);
      if (ket == null) return;
      context.pop(ket);
      return;
    }
    context.pop(
      _hangMuc.copyWith(
        lanThucHien: _dangSua
            ? [
                for (final e in _hangMuc.lanThucHien)
                  if (e.id == lan.id) lan else e,
              ]
            : [..._hangMuc.lanThucHien, lan],
      ),
    );
  }

  // Ghi hoặc sửa lần trên server
  Future<PreventionRecord?> _goiApi(
    String petId,
    PreventionDose lan,
    List<Uint8List> anhMoi,
  ) async {
    try {
      return await ref
          .read(myPetsProvider.notifier)
          .ghiLanKemAnh(
            petId: petId,
            idHangMuc: _hangMuc.id,
            lan: lan,
            anhMoi: anhMoi,
            dangSua: _dangSua,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(moTaLoiThuCung(context, e))));
      }
      return null;
    }
  }

  // Xoá riêng lần đang sửa, hạng mục vẫn còn
  Future<void> _xoaLan() async {
    final l10n = context.l10n;
    final dongY = await showConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: l10n.xoaLanNay,
      message: l10n.xacNhanXoaLan,
      confirmLabel: l10n.xoa,
      danger: true,
    );
    if (!dongY || !mounted) return;
    if (_petId case final id?) {
      final be = await _goi(
        () => ref
            .read(myPetsProvider.notifier)
            .xoaLan(id, _hangMuc.id, _lanSua!.id),
      );
      if (be == null || !mounted) return;
      context.pop(be.phongBenh.firstWhere((e) => e.id == _hangMuc.id));
      return;
    }
    context.pop(
      _hangMuc.copyWith(
        lanThucHien: [
          for (final e in _hangMuc.lanThucHien)
            if (e.id != _lanSua!.id) e,
        ],
      ),
    );
  }

  // Gọi API kèm bắt lỗi, trả null nếu hỏng
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
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppScreenHeader(
                title: _dangSua ? l10n.suaLanGhi : l10n.themLanGhiMoi,
                subtitle: l10n.hangMucVaBe(
                  preventionTitle(context, _hangMuc),
                  widget.args.tenBe,
                ),
                onBack: _onBack,
              ),
              const AppDongKe(),
              Expanded(
                child: Form(
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
                      LockedField(
                        label: l10n.hangMuc,
                        value: tenCuaHangMuc(context, _hangMuc),
                      ),
                      const SizedBox(height: AppSpacing.labelGap),
                      Text(
                        l10n.ghiChuHangMucKhoa,
                        style: AppTextStyles.captionSm,
                      ),
                      const SizedBox(height: AppSpacing.stackGap),
                      AppTextField(
                        label: l10n.ngayThucHien,
                        hint: l10n.chonNgay,
                        controller: _ngayThucHienController,
                        isRequired: true,
                        readOnly: true,
                        onTap: _chonNgayThucHien,
                        validator: _vBatBuoc,
                        suffixIcon: Icons.chevron_right,
                        labelTrailing: _NutDatHomNay(
                          onTap: () => _datNgay(homNayVn()),
                        ),
                        height: AppTextField.caoGon,
                      ),
                      const SizedBox(height: AppSpacing.stackGap),
                      PreventionReminderField(
                        coNhacLai: _coNhacLai,
                        soChuKyController: _soChuKyController,
                        donVi: _donViChuKy,
                        chuKy: _chuKy,
                        ngayToiHan: _ngayToiHan,
                        onDoiCheDo: (bat) => setState(() {
                          _dirty = true;
                          _coNhacLai = bat;
                        }),
                        onDoiDonVi: (donVi) => setState(() {
                          _dirty = true;
                          _donViChuKy = donVi;
                        }),
                        onDoiSo: () => setState(() => _dirty = true),
                      ),
                      const AppDongKe(dem: true),
                      AppTextField(
                        label: l10n.noiThucHien,
                        hint: l10n.hintNoiTiem,
                        controller: _noiThucHienController,
                        height: AppTextField.caoGon,
                      ),
                      const SizedBox(height: AppSpacing.labelGap),
                      Text(
                        l10n.ghiChuNoiThucHien,
                        style: AppTextStyles.captionSm,
                      ),
                      const SizedBox(height: AppSpacing.stackGap),
                      Text(l10n.anhPhieuHoacHoaDon, style: AppTextStyles.label),
                      const SizedBox(height: AppSpacing.labelGap),
                      PreventionPhotoRow(
                        anh: _anh,
                        onThem: _themAnh,
                        onXem: _xemAnh,
                      ),
                      const SizedBox(height: AppSpacing.groupGap),
                      AppButton(
                        text: l10n.luu,
                        enabled: !_dangLuu,
                        onTap: _luu,
                      ),
                      if (_dangSua) ...[
                        const SizedBox(height: AppSpacing.itemGap),
                        AppButton(
                          text: l10n.xoaLanNay,
                          outlined: true,
                          color: AppColors.accent,
                          onTap: _xoaLan,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Nút phụ cạnh nhãn ngày, đặt nhanh ngày hôm nay
class _NutDatHomNay extends StatelessWidget {
  const _NutDatHomNay({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryColor,
        textStyle: AppTextStyles.captionSm,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.labelGap),
        minimumSize: Size.zero,
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(context.l10n.datHomNay),
    );
  }
}
