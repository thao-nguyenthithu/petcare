import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/service_summary.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/widgets/services/weight_price_row.dart';
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

const _hintGiaLuot = '50.000';
const _hintGiaNgay = '200.000';
const _hintGiaTheoCan = {
  WeightTier.duoi5: '150.000',
  WeightTier.tu5den10: '220.000',
  WeightTier.tu10den20: '300.000',
  WeightTier.tren20: '400.000',
};

String _nhanMucCan(BuildContext context, WeightTier muc) => switch (muc) {
  WeightTier.duoi5 => context.l10n.duoi5kg,
  WeightTier.tu5den10 => context.l10n.tu5den10kg,
  WeightTier.tu10den20 => context.l10n.tu10den20kg,
  WeightTier.tren20 => context.l10n.tren20kg,
};

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

  int _phut = walkingDurations.first;
  final _giaController = TextEditingController();

  final _giaNgayController = TextEditingController();
  final _sucChuaController = TextEditingController();
  final _phuPhiController = TextEditingController();
  final _maxPetsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _giaFocus = FocusNode();
  final _giaNgayFocus = FocusNode();
  final _sucChuaFocus = FocusNode();
  final _phuPhiFocus = FocusNode();
  final _maxPetsFocus = FocusNode();

  late Set<GroomingPackage> _goiNhan;
  final _giaGoi = {
    for (final goi in GroomingPackage.values)
      goi: {for (final m in WeightTier.values) m: TextEditingController()},
  };
  late Map<GroomingPackage, Set<WeightTier>> _mucNhan;

  bool _dirty = false;
  bool _autoValidate = false;

  ServiceType get _type => widget.type;

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
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
        _loai = c.petKind;
        _phut = c.durationMinutes;
        if (c.price != null) _giaController.text = dinhDangTien(c.price!);
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
        _goiNhan = c.priceByPackage.keys.toSet();
        _mucNhan = {
          for (final goi in GroomingPackage.values)
            goi: c.priceByPackage[goi]?.keys.toSet() ?? {},
        };
        for (final goi in c.priceByPackage.keys) {
          for (final e in c.priceByPackage[goi]!.entries) {
            _giaGoi[goi]?[e.key]?.text = dinhDangTien(e.value);
          }
        }
        if (c.maxPets != null) _maxPetsController.text = '${c.maxPets}';
    }
    _goiNhan = _type == ServiceType.grooming ? _goiNhan : <GroomingPackage>{};
    _mucNhan = _type == ServiceType.grooming
        ? _mucNhan
        : {for (final g in GroomingPackage.values) g: <WeightTier>{}};
    for (final c in [
      _giaController,
      _giaNgayController,
      _sucChuaController,
      _phuPhiController,
      _maxPetsController,
      for (final bang in _giaGoi.values) ...bang.values,
    ]) {
      c.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _giaController.dispose();
    _giaNgayController.dispose();
    _sucChuaController.dispose();
    _phuPhiController.dispose();
    _maxPetsController.dispose();
    _giaFocus.dispose();
    _giaNgayFocus.dispose();
    _sucChuaFocus.dispose();
    _phuPhiFocus.dispose();
    _maxPetsFocus.dispose();
    for (final bang in _giaGoi.values) {
      for (final c in bang.values) {
        c.dispose();
      }
    }
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

  String? _vMaxPets(String? v) => _thongBao(
    loiSoBeToiDa(
      int.tryParse(v ?? ''),
      capacity: _type == ServiceType.boarding
          ? int.tryParse(_sucChuaController.text)
          : null,
    ),
  );

  String? _vPhuPhi(String? v) => _thongBao(
    loiPhuPhiBeThem(docSoTien(v ?? ''), int.tryParse(_maxPetsController.text)),
  );

  // Focus vào ô lỗi đầu tiên theo thứ tự hiển thị
  void _focusDauLoi() {
    final List<(String?, FocusNode)> ds = switch (_type) {
      ServiceType.walking => [
        (_vBatBuoc(_giaController.text), _giaFocus),
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
    if (!_autoValidate) setState(() => _autoValidate = true);
    // Toàn bộ validation inline qua Form lỗi thì focus ô lỗi đầu tiên
    if (!(_formKey.currentState?.validate() ?? true)) {
      _focusDauLoi();
      return;
    }
    final SitterServices ketQua;
    switch (_type) {
      case ServiceType.walking:
        ketQua = widget.services.copyWith(
          walking: WalkingConfig(
            enabled: true,
            petKind: _loai,
            durationMinutes: _phut,
            price: docSoTien(_giaController.text),
            additionalPetFee: docSoTien(_phuPhiController.text),
            maxPets: int.tryParse(_maxPetsController.text),
          ),
        );
      case ServiceType.boarding:
        ketQua = widget.services.copyWith(
          boarding: BoardingConfig(
            enabled: true,
            petKind: _loai,
            pricePerDay: docSoTien(_giaNgayController.text),
            capacity: docSoTien(_sucChuaController.text),
            additionalPetFee: docSoTien(_phuPhiController.text),
            maxPets: int.tryParse(_maxPetsController.text),
          ),
        );
      case ServiceType.grooming:
        final bangGoi = <GroomingPackage, Map<WeightTier, int>>{};
        for (final goi in _goiNhan) {
          final bang = <WeightTier, int>{};
          for (final muc in _mucNhan[goi] ?? <WeightTier>{}) {
            final gia = docSoTien(_giaGoi[goi]![muc]!.text);
            if (gia != null) bang[muc] = gia;
          }
          bangGoi[goi] = bang;
        }
        ketQua = widget.services.copyWith(
          grooming: GroomingConfig(
            enabled: true,
            petKind: _loai,
            priceByPackage: bangGoi,
            maxPets: int.tryParse(_maxPetsController.text),
          ),
        );
    }
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
                    _nhan(l10n.nhanLoai),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _chon(
                          l10n.cho,
                          _loai == PetKind.dog,
                          () => _doiLoai(PetKind.dog),
                        ),
                        const SizedBox(width: 10),
                        _chon(
                          l10n.meo,
                          _loai == PetKind.cat,
                          () => _doiLoai(PetKind.cat),
                        ),
                        const SizedBox(width: 10),
                        _chon(
                          l10n.caHai,
                          _loai == PetKind.both,
                          () => _doiLoai(PetKind.both),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.chiHoTroChoMeo, style: AppTextStyles.captionSm),
                    const SizedBox(height: 20),
                    ..._truongTheoLoai(),
                    const SizedBox(height: 28),
                    AppButton(text: l10n.luuDichVu, height: 56, onTap: _luu),
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

  // Nút chọn dạng viên thuốc
  Widget _chon(String nhan, bool chon, VoidCallback onTap) => Expanded(
    child: AppButton(
      text: nhan,
      height: 40,
      radius: AppRadius.radius20,
      outlined: !chon,
      onTap: onTap,
    ),
  );

  List<Widget> _truongTheoLoai() {
    final l10n = context.l10n;
    switch (_type) {
      case ServiceType.walking:
        return [
          _nhan(l10n.thoiLuongMoiLuot),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final phut in walkingDurations) ...[
                if (phut != walkingDurations.first) const SizedBox(width: 10),
                _chon(
                  l10n.soPhut('$phut'),
                  _phut == phut,
                  () => setState(() {
                    _phut = phut;
                    _dirty = true;
                  }),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: l10n.giaDichVu,
            hint: _hintGiaLuot,
            controller: _giaController,
            focusNode: _giaFocus,
            isRequired: true,
            validator: _vBatBuoc,
            height: 46,
            keyboardType: _banPhimSo,
            inputFormatters: const [DinhDangTienFormatter()],
            suffixText: l10n.donGiaLuot,
          ),
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
          _nhan(l10n.goiNayGom),
          const SizedBox(height: 12),
          FormField<bool>(
            validator: (_) => _goiNhan.isEmpty ? l10n.chonItNhatMotGoi : null,
            builder: (state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _chon(
                      l10n.chiTam,
                      _goiNhan.contains(GroomingPackage.bath),
                      () => _doiGoi(GroomingPackage.bath),
                    ),
                    const SizedBox(width: 10),
                    _chon(
                      l10n.tamVaCatTia,
                      _goiNhan.contains(GroomingPackage.bathAndTrim),
                      () => _doiGoi(GroomingPackage.bathAndTrim),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  state.hasError ? state.errorText! : l10n.chonGoiBanCungCap,
                  style: AppTextStyles.captionSm.copyWith(
                    color: state.hasError ? AppColors.error : null,
                  ),
                ),
              ],
            ),
          ),
          for (final goi in GroomingPackage.values)
            if (_goiNhan.contains(goi)) ..._bangGiaGoi(goi),
          const SizedBox(height: 20),
          _maxPetsField(),
        ];
    }
  }

  void _doiGoi(GroomingPackage goi) {
    setState(() {
      _dirty = true;
      if (_goiNhan.contains(goi)) {
        _goiNhan.remove(goi);
      } else {
        _goiNhan.add(goi);
        // Gói mới bật thì mặc định nhận đủ 4 mức cân
        _mucNhan[goi] = WeightTier.values.toSet();
      }
    });
  }

  List<Widget> _bangGiaGoi(GroomingPackage goi) {
    final l10n = context.l10n;
    final tenGoi = goi == GroomingPackage.bath ? l10n.chiTam : l10n.tamVaCatTia;
    final mucs = _mucNhan[goi] ?? {};
    return [
      const SizedBox(height: 20),
      FormField<void>(
        validator: (_) {
          final ms = _mucNhan[goi] ?? {};
          if (ms.isEmpty) return l10n.chonItNhatMotMucCan;
          for (final muc in ms) {
            if (docSoTien(_giaGoi[goi]![muc]!.text) == null) {
              return l10n.khongDuocDeTrong;
            }
          }
          return null;
        },
        builder: (state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _nhan('${l10n.bangGiaCanNang} · $tenGoi'),
                const Spacer(),
                Text(l10n.donGiaBe, style: AppTextStyles.captionSm),
              ],
            ),
            const SizedBox(height: 12),
            for (final muc in WeightTier.values) ...[
              if (muc != WeightTier.values.first) const SizedBox(height: 8),
              WeightPriceRow(
                label: _nhanMucCan(context, muc),
                hint: _hintGiaTheoCan[muc]!,
                controller: _giaGoi[goi]![muc]!,
                selected: mucs.contains(muc),
                onToggle: (bat) => setState(() {
                  _dirty = true;
                  if (bat) {
                    mucs.add(muc);
                  } else {
                    mucs.remove(muc);
                    _giaGoi[goi]![muc]!.clear();
                  }
                  _mucNhan[goi] = mucs;
                }),
              ),
            ],
            if (state.hasError) ...[
              const SizedBox(height: 8),
              Text(
                state.errorText!,
                style: AppTextStyles.captionSm.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    ];
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

  Widget _nhan(String text) => Text(
    text,
    style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
  );
}
