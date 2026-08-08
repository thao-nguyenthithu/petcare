import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/grooming_form.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/widgets/services/choice_pill_row.dart';
import 'package:petcare_app/features/sitter/widgets/services/grooming_fields.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';

// Form cấu hình dịch vụ
const _banPhimSo = TextInputType.numberWithOptions(
  signed: false,
  decimal: false,
);

const _hintGiaLuot = {30: '50.000', 60: '80.000'};
const _hintGiaNgay = '200.000';

// Màn cấu hình 1 loại dịch vụ
class ServiceFormScreen extends StatefulWidget {
  final ServiceType type;
  final SitterServices services;

  const ServiceFormScreen({
    super.key,
    required this.type,
    required this.services,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  late PetKind _loai;

  // Mỗi mức thời lượng một ô giá, tất cả đều bắt buộc
  final _giaLuot = {
    for (final phut in walkingDurations) phut: TextEditingController(),
  };
  final _giaLuotFocus = {
    for (final phut in walkingDurations) phut: FocusNode(),
  };

  final _giaNgayController = TextEditingController();
  final _sucChuaController = TextEditingController();
  final _phuPhiController = TextEditingController();
  final _maxPetsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _giaNgayFocus = FocusNode();
  final _sucChuaFocus = FocusNode();
  final _phuPhiFocus = FocusNode();
  final _maxPetsFocus = FocusNode();
  late final GroomingForm _grooming;

  bool _dirty = false;
  bool _autoValidate = false;

  ServiceType get _type => widget.type;

  bool get _laGrooming => _type == ServiceType.grooming;

  void _markDirty() {
    if (_dirty && !_autoValidate) return;
    setState(() => _dirty = true);
  }

  void _doiLoai(PetKind loai) => setState(() {
    _loai = loai;
    _dirty = true;
  });

  @override
  void initState() {
    super.initState();
    switch (_type) {
      case ServiceType.walking:
        final c = widget.services.walking;
        _loai = PetKind.dog;
        for (final e in c.priceByDuration.entries) {
          _giaLuot[e.key]?.text = dinhDangTien(e.value);
        }
        if (c.additionalPetFee != null) {
          _phuPhiController.text = dinhDangTien(c.additionalPetFee!);
        }
        if (c.maxPets != null) _maxPetsController.text = '${c.maxPets}';
      case ServiceType.boarding:
        final c = widget.services.boarding;
        _loai = c.petKind;
        if (c.pricePerDay != null) {
          _giaNgayController.text = dinhDangTien(c.pricePerDay!);
        }
        if (c.capacity != null) _sucChuaController.text = '${c.capacity}';
        if (c.additionalPetFee != null) {
          _phuPhiController.text = dinhDangTien(c.additionalPetFee!);
        }
        if (c.maxPets != null) _maxPetsController.text = '${c.maxPets}';
      case ServiceType.grooming:
        final c = widget.services.grooming;
        _loai = c.petKind;
        _grooming = GroomingForm.from(c);
        _grooming.addListener(_markDirty);
        if (c.maxPets != null) _maxPetsController.text = '${c.maxPets}';
    }
    for (final c in [
      ..._giaLuot.values,
      _giaNgayController,
      _sucChuaController,
      _phuPhiController,
      _maxPetsController,
    ]) {
      c.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    for (final c in _giaLuot.values) {
      c.dispose();
    }
    for (final f in _giaLuotFocus.values) {
      f.dispose();
    }
    _giaNgayController.dispose();
    _sucChuaController.dispose();
    _phuPhiController.dispose();
    _maxPetsController.dispose();
    _giaNgayFocus.dispose();
    _sucChuaFocus.dispose();
    _phuPhiFocus.dispose();
    _maxPetsFocus.dispose();
    if (_laGrooming) _grooming.dispose();
    super.dispose();
  }

  // Validator từng ô
  String? _vBatBuoc(String? v) =>
      docSoTien(v ?? '') == null ? context.l10n.khongDuocDeTrong : null;

  // Map mã lỗi
  String? _thongBao(PricingError? e) => switch (e) {
    null => null,
    PricingError.trong => context.l10n.khongDuocDeTrong,
    PricingError.soBeToiThieu => context.l10n.loiSoBeToiThieu,
    PricingError.vuotSucChua => context.l10n.loiMaxPetVuotSucChua,
    PricingError.phuPhiBatBuoc => context.l10n.loiPhuPhiBatBuoc,
    PricingError.phuPhiThuaBe => context.l10n.loiPhuPhiCanNhieuBe,
  };

  int? get _sucChua => _type == ServiceType.boarding
      ? int.tryParse(_sucChuaController.text)
      : null;

  String? _vMaxPets(String? v) =>
      _thongBao(loiSoBeToiDa(int.tryParse(v ?? ''), capacity: _sucChua));

  String? _vPhuPhi(String? v) => _thongBao(
    loiPhuPhiBeThem(docSoTien(v ?? ''), int.tryParse(_maxPetsController.text)),
  );

  bool get _hopLe {
    final maxPets = int.tryParse(_maxPetsController.text);
    final phuPhi = docSoTien(_phuPhiController.text);
    switch (_type) {
      case ServiceType.walking:
        return walkingDurations.every(
              (phut) => docSoTien(_giaLuot[phut]!.text) != null,
            ) &&
            loiPhuPhiBeThem(phuPhi, maxPets) == null &&
            loiSoBeToiDa(maxPets) == null;
      case ServiceType.boarding:
        return docSoTien(_giaNgayController.text) != null &&
            _sucChua != null &&
            loiPhuPhiBeThem(phuPhi, maxPets) == null &&
            loiSoBeToiDa(maxPets, capacity: _sucChua) == null;
      case ServiceType.grooming:
        return _grooming.hopLe && loiSoBeToiDa(maxPets) == null;
    }
  }

  // Focus vào ô lỗi đầu tiên theo thứ tự hiển thị
  void _focusDauLoi() {
    if (_laGrooming) {
      final o = _grooming.oLoiDauTien;
      if (o != null) {
        o.requestFocus();
        return;
      }
    }
    final List<(String?, FocusNode)> ds = switch (_type) {
      ServiceType.walking => [
        for (final phut in walkingDurations)
          (_vBatBuoc(_giaLuot[phut]!.text), _giaLuotFocus[phut]!),
        (_vPhuPhi(_phuPhiController.text), _phuPhiFocus),
        (_vMaxPets(_maxPetsController.text), _maxPetsFocus),
      ],
      ServiceType.boarding => [
        (_vBatBuoc(_giaNgayController.text), _giaNgayFocus),
        (_vBatBuoc(_sucChuaController.text), _sucChuaFocus),
        (_vPhuPhi(_phuPhiController.text), _phuPhiFocus),
        (_vMaxPets(_maxPetsController.text), _maxPetsFocus),
      ],
      ServiceType.grooming => [
        (_vMaxPets(_maxPetsController.text), _maxPetsFocus),
      ],
    };
    for (final (loi, node) in ds) {
      if (loi != null) {
        node.requestFocus();
        return;
      }
    }
  }

  // Thoát màn có thay đổi chưa lưu thì hỏi xác nhận
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

  void _luu() {
    setState(() => _autoValidate = true);
    final formOk = _formKey.currentState?.validate() ?? true;
    if (!formOk || !_hopLe) {
      _focusDauLoi();
      return;
    }
    final maxPets = int.tryParse(_maxPetsController.text);
    final SitterServices ketQua = switch (_type) {
      ServiceType.walking => widget.services.copyWith(
        walking: WalkingConfig(
          enabled: true,
          petKind: _loai,
          priceByDuration: {
            for (final phut in walkingDurations)
              phut: ?docSoTien(_giaLuot[phut]!.text),
          },
          additionalPetFee: docSoTien(_phuPhiController.text),
          maxPets: maxPets,
        ),
      ),
      ServiceType.boarding => widget.services.copyWith(
        boarding: BoardingConfig(
          enabled: true,
          petKind: _loai,
          pricePerDay: docSoTien(_giaNgayController.text),
          capacity: _sucChua,
          additionalPetFee: docSoTien(_phuPhiController.text),
          maxPets: maxPets,
        ),
      ),
      ServiceType.grooming => widget.services.copyWith(
        grooming: _grooming.toConfig(petKind: _loai, maxPets: maxPets),
      ),
    };
    context.pop(ketQua);
  }

  String _moTa() => switch (_type) {
    ServiceType.walking => context.l10n.moTaDvDat,
    ServiceType.boarding => context.l10n.moTaDvTrongGiu,
    ServiceType.grooming => context.l10n.moTaDvCatTia,
  };

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppBackButton(onTap: _onBack),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      serviceTypeName(context, _type),
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: 8),
                    Text(_moTa(), style: AppTextStyles.caption),
                    const SizedBox(height: 20),
                    if (_type != ServiceType.walking) ...[
                      Text(l10n.nhanLoai, style: AppTextStyles.label),
                      const SizedBox(height: 12),
                      ChoicePillRow(
                        items: [
                          for (final kind in PetKind.values)
                            (
                              nhan: petKindLabel(context, kind),
                              chon: _loai == kind,
                              onTap: () => _doiLoai(kind),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.chiHoTroChoMeo, style: AppTextStyles.captionSm),
                      const SizedBox(height: 20),
                    ],
                    ..._truongTheoLoai(),
                    const SizedBox(height: 28),
                    AppButton(
                      text: l10n.luuDichVu,
                      height: 56,
                      enabled: !_autoValidate || _hopLe,
                      onTap: _luu,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _truongTheoLoai() {
    final l10n = context.l10n;
    switch (_type) {
      case ServiceType.walking:
        return [
          Text(l10n.bangGiaThoiLuong, style: AppTextStyles.label),
          for (final phut in walkingDurations) ...[
            const SizedBox(height: 12),
            AppTextField(
              label: l10n.soPhut('$phut'),
              hint: _hintGiaLuot[phut]!,
              controller: _giaLuot[phut]!,
              focusNode: _giaLuotFocus[phut]!,
              isRequired: true,
              validator: _vBatBuoc,
              height: 46,
              keyboardType: _banPhimSo,
              inputFormatters: const [DinhDangTienFormatter()],
              suffixText: l10n.donGiaLuot,
            ),
          ],
          const SizedBox(height: 8),
          Text(l10n.nhapGiaDuHaiThoiLuong, style: AppTextStyles.captionSm),
          const SizedBox(height: 20),
          _phuPhiField(),
          const SizedBox(height: 20),
          _maxPetsField(),
        ];
      case ServiceType.boarding:
        return [
          AppTextField(
            label: l10n.giaDichVu,
            hint: _hintGiaNgay,
            controller: _giaNgayController,
            focusNode: _giaNgayFocus,
            isRequired: true,
            validator: _vBatBuoc,
            height: 46,
            keyboardType: _banPhimSo,
            inputFormatters: const [DinhDangTienFormatter()],
            suffixText: l10n.donGiaNgay,
          ),
          const SizedBox(height: 8),
          Text(l10n.ghiChuMotNgay, style: AppTextStyles.captionSm),
          const SizedBox(height: 20),
          AppTextField(
            label: l10n.sucChuaToiDa,
            hint: l10n.hintSucChua,
            controller: _sucChuaController,
            focusNode: _sucChuaFocus,
            isRequired: true,
            validator: _vBatBuoc,
            height: 46,
            keyboardType: _banPhimSo,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
          ),
          const SizedBox(height: 20),
          _phuPhiField(),
          const SizedBox(height: 20),
          _maxPetsField(),
        ];
      case ServiceType.grooming:
        return [
          GroomingFields(
            form: _grooming,
            hienLoi: _autoValidate,
            onChanged: () => setState(() => _dirty = true),
          ),
          const SizedBox(height: 30),
          _maxPetsField(),
        ];
    }
  }

  // Ô nhập phụ phí mỗi bé thêm
  Widget _phuPhiField() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.phuPhiBeThem,
          hint: l10n.hintPhuPhiBeThem,
          controller: _phuPhiController,
          focusNode: _phuPhiFocus,
          validator: _vPhuPhi,
          height: 46,
          keyboardType: _banPhimSo,
          inputFormatters: const [DinhDangTienFormatter()],
          suffixText: l10n.donGiaBeThem,
        ),
        const SizedBox(height: 8),
        Text(l10n.ghiChuPhuPhiBeThem, style: AppTextStyles.captionSm),
      ],
    );
  }

  // Ô nhập số bé tối đa mỗi đơn
  Widget _maxPetsField() {
    final l10n = context.l10n;
    return AppTextField(
      label: l10n.soBeToiDaMoiDon,
      hint: l10n.hintSoBeToiDa,
      isRequired: true,
      controller: _maxPetsController,
      focusNode: _maxPetsFocus,
      validator: _vMaxPets,
      height: 46,
      keyboardType: _banPhimSo,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(2),
      ],
    );
  }
}
