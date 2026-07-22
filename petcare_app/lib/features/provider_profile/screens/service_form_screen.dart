import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

// Bàn phím số thuần
const _banPhimSo = TextInputType.numberWithOptions(
  signed: false,
  decimal: false,
);

// Giá gợi ý ở hint ô nhập
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

// Màn thêm mới hoặc sửa một dịch vụ, mở từ màn quản lý dịch vụ
class ServiceFormScreen extends StatefulWidget {
  final ServiceDraft? banDau;

  const ServiceFormScreen({super.key, this.banDau});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  ServiceType _type = ServiceType.walking;
  PetKind _loai = PetKind.both;
  int _phut = 30;
  final _tenController = TextEditingController();
  final _giaController = TextEditingController();
  final _sucChuaController = TextEditingController();
  final _giaTheoCan = {
    for (final muc in WeightTier.values) muc: TextEditingController(),
  };
  final _mucCanNhan = WeightTier.values.toSet();
  GroomingPackage _goi = GroomingPackage.bathAndTrim;

  bool get _dangSua => widget.banDau != null;

  @override
  void initState() {
    super.initState();
    final cu = widget.banDau;
    if (cu == null) return;
    _type = cu.type;
    _loai = cu.petKind;
    _tenController.text = cu.name;
    _phut = cu.durationMinutes ?? 30;
    if (cu.price != null) _giaController.text = dinhDangTien(cu.price!);
    if (cu.capacity != null) _sucChuaController.text = '${cu.capacity}';
    final bangGia = cu.priceByWeight;
    if (bangGia != null) {
      _mucCanNhan
        ..clear()
        ..addAll(bangGia.keys);
      for (final muc in bangGia.keys) {
        _giaTheoCan[muc]!.text = dinhDangTien(bangGia[muc]!);
      }
    }
    _goi = cu.package ?? GroomingPackage.bathAndTrim;
  }

  @override
  void dispose() {
    _tenController.dispose();
    _giaController.dispose();
    _sucChuaController.dispose();
    for (final controller in _giaTheoCan.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _baoLoi(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _doiLoai(ServiceType moi) {
    if (moi == _type) return;
    setState(() {
      _type = moi;
      _phut = 30;
      _tenController.clear();
      _giaController.clear();
      _sucChuaController.clear();
      for (final controller in _giaTheoCan.values) {
        controller.clear();
      }
      _mucCanNhan
        ..clear()
        ..addAll(WeightTier.values);
      _goi = GroomingPackage.bathAndTrim;
    });
  }

  // Bỏ tick mức cân thì xóa luôn giá đã nhập của mức đó cho khỏi gửi nhầm
  void _doiMucCan(WeightTier muc, bool nhan) {
    setState(() {
      if (nhan) {
        _mucCanNhan.add(muc);
      } else {
        _mucCanNhan.remove(muc);
        _giaTheoCan[muc]!.clear();
      }
    });
  }

  void _luu() {
    final l10n = context.l10n;
    final ten = _tenController.text.trim();
    if (ten.isEmpty) {
      _baoLoi(l10n.khongDuocDeTrong);
      return;
    }
    final ServiceDraft dichVu;
    switch (_type) {
      case ServiceType.walking:
        final gia = docSoTien(_giaController.text);
        if (gia == null) {
          _baoLoi(l10n.khongDuocDeTrong);
          return;
        }
        dichVu = ServiceDraft(
          type: _type,
          name: ten,
          petKind: _loai,
          durationMinutes: _phut,
          price: gia,
        );
      case ServiceType.boarding:
        final gia = docSoTien(_giaController.text);
        final sucChua = docSoTien(_sucChuaController.text);
        if (gia == null || sucChua == null) {
          _baoLoi(l10n.khongDuocDeTrong);
          return;
        }
        dichVu = ServiceDraft(
          type: _type,
          name: ten,
          petKind: _loai,
          price: gia,
          capacity: sucChua,
        );
      case ServiceType.grooming:
        if (_mucCanNhan.isEmpty) {
          _baoLoi(l10n.chonItNhatMotMucCan);
          return;
        }
        final bangGia = <WeightTier, int>{};
        for (final muc in WeightTier.values) {
          if (!_mucCanNhan.contains(muc)) continue;
          final gia = docSoTien(_giaTheoCan[muc]!.text);
          if (gia == null) {
            _baoLoi(l10n.khongDuocDeTrong);
            return;
          }
          bangGia[muc] = gia;
        }
        dichVu = ServiceDraft(
          type: _type,
          name: ten,
          petKind: _loai,
          priceByWeight: bangGia,
          package: _goi,
        );
    }
    context.pop(ServiceEditResult(dichVu));
  }

  Future<void> _xoa() async {
    final l10n = context.l10n;
    final dongY = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.xoaDichVu, style: AppTextStyles.h2),
        content: Text(l10n.xacNhanXoaDichVu, style: AppTextStyles.caption),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(l10n.huy),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(
              l10n.xoa,
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (dongY != true || !mounted) return;
    context.pop(const ServiceEditResult.deleted());
  }

  String _moTa(BuildContext context) => switch (_type) {
    ServiceType.walking => context.l10n.moTaDvDat,
    ServiceType.boarding => context.l10n.moTaDvTrongGiu,
    ServiceType.grooming => context.l10n.moTaDvCatTia,
  };

  String _hintTen(BuildContext context) => switch (_type) {
    ServiceType.walking => context.l10n.viDuDatCho,
    ServiceType.boarding => context.l10n.viDuTrongGiu,
    ServiceType.grooming => context.l10n.viDuCatTia,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackButton(),
                ),
                const SizedBox(height: 16),
                Text(
                  _dangSua ? l10n.suaDichVu : l10n.themDichVu,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 8),
                Text(_moTa(context), style: AppTextStyles.caption),
                const SizedBox(height: 20),
                _nhan(l10n.loaiDichVu),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeTile(
                      icon: 'assets/icons/icon_leash.svg',
                      label: l10n.datThuCung,
                      selected: _type == ServiceType.walking,
                      onTap: () => _doiLoai(ServiceType.walking),
                    ),
                    const SizedBox(width: 10),
                    _TypeTile(
                      icon: 'assets/icons/paw.svg',
                      label: l10n.trongGiu,
                      selected: _type == ServiceType.boarding,
                      onTap: () => _doiLoai(ServiceType.boarding),
                    ),
                    const SizedBox(width: 10),
                    _TypeTile(
                      icon: 'assets/icons/icon_grooming.svg',
                      label: l10n.tamVaTia,
                      selected: _type == ServiceType.grooming,
                      onTap: () => _doiLoai(ServiceType.grooming),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _nhan(l10n.nhanLoai),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ChipChon(
                      label: l10n.cho,
                      selected: _loai == PetKind.dog,
                      onTap: () => setState(() => _loai = PetKind.dog),
                    ),
                    const SizedBox(width: 10),
                    _ChipChon(
                      label: l10n.meo,
                      selected: _loai == PetKind.cat,
                      onTap: () => setState(() => _loai = PetKind.cat),
                    ),
                    const SizedBox(width: 10),
                    _ChipChon(
                      label: l10n.caHai,
                      selected: _loai == PetKind.both,
                      onTap: () => setState(() => _loai = PetKind.both),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.chiHoTroChoMeo, style: AppTextStyles.captionSm),
                const SizedBox(height: 20),
                AppTextField(
                  label: l10n.tenDichVu,
                  hint: _hintTen(context),
                  controller: _tenController,
                  height: 46,
                ),
                const SizedBox(height: 20),
                if (_type == ServiceType.walking) ...[
                  _nhan(l10n.thoiLuongMoiLuot),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (final phut in walkingDurations) ...[
                        if (phut != walkingDurations.first)
                          const SizedBox(width: 10),
                        _ChipChon(
                          label: l10n.soPhut('$phut'),
                          selected: _phut == phut,
                          onTap: () => setState(() => _phut = phut),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: l10n.giaDichVu,
                    hint: _hintGiaLuot,
                    controller: _giaController,
                    height: 46,
                    keyboardType: _banPhimSo,
                    inputFormatters: const [DinhDangTienFormatter()],
                    suffixText: l10n.donGiaLuot,
                  ),
                ] else if (_type == ServiceType.boarding) ...[
                  AppTextField(
                    label: l10n.giaDichVu,
                    hint: _hintGiaNgay,
                    controller: _giaController,
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
                    height: 46,
                    keyboardType: _banPhimSo,
                    // Số bé, không phải tiền nên không chèn dấu phân cách
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                ] else ...[
                  _nhan(l10n.goiNayGom),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ChipChon(
                        label: l10n.chiTam,
                        selected: _goi == GroomingPackage.bath,
                        onTap: () =>
                            setState(() => _goi = GroomingPackage.bath),
                      ),
                      const SizedBox(width: 10),
                      _ChipChon(
                        label: l10n.tamVaCatTia,
                        selected: _goi == GroomingPackage.bathAndTrim,
                        onTap: () =>
                            setState(() => _goi = GroomingPackage.bathAndTrim),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.banRiengThiTaoHaiGoi,
                    style: AppTextStyles.captionSm,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _nhan(l10n.bangGiaCanNang),
                      const Spacer(),
                      Text(l10n.donGiaBe, style: AppTextStyles.captionSm),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l10n.chonMucCanNhan, style: AppTextStyles.captionSm),
                  const SizedBox(height: 12),
                  for (final muc in WeightTier.values) ...[
                    if (muc != WeightTier.values.first)
                      const SizedBox(height: 8),
                    _HangGia(
                      label: _nhanMucCan(context, muc),
                      hint: _hintGiaTheoCan[muc]!,
                      controller: _giaTheoCan[muc]!,
                      selected: _mucCanNhan.contains(muc),
                      onToggle: (bat) => _doiMucCan(muc, bat),
                    ),
                  ],
                ],
                const SizedBox(height: 28),
                AppButton(
                  text: _dangSua ? l10n.luuThayDoi : l10n.luuDichVu,
                  height: 56,
                  onTap: _luu,
                ),
                if (_dangSua) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _xoa,
                    child: Text(
                      l10n.xoaDichVu,
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nhan(String text) => Text(
    text,
    style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
  );
}

class _TypeTile extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.cardMint : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              border: Border.all(
                color: selected ? AppColors.primaryColor : AppColors.neutral,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(icon, width: 26),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: AppTextStyles.captionSm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primaryColor
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipChon extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChipChon({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.primaryColor : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: selected ? null : Border.all(color: AppColors.neutral),
            ),
            child: Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: selected ? AppColors.textWhite : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Một mức cân trong bảng giá, NCC tự bật mức mình nhận
class _HangGia extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool selected;
  final ValueChanged<bool> onToggle;

  const _HangGia({
    required this.label,
    required this.hint,
    required this.controller,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<_HangGia> createState() => _HangGiaState();
}

class _HangGiaState extends State<_HangGia> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color get _mauVien {
    if (!widget.selected) return AppColors.neutral;
    return _focusNode.hasFocus ? AppColors.primaryColor : AppColors.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final dangChon = widget.selected;
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 6, right: 16),
      decoration: BoxDecoration(
        color: dangChon ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(
          color: _mauVien,
          width: dangChon && _focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: dangChon,
              onChanged: (value) => widget.onToggle(value ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: const BorderSide(color: AppColors.neutral),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: AppTextStyles.label.copyWith(
              color: dangChon ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: dangChon,
              textAlign: TextAlign.right,
              keyboardType: _banPhimSo,
              inputFormatters: const [DinhDangTienFormatter()],
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: dangChon ? widget.hint : '',
                hintStyle: AppTextStyles.caption,
                isDense: true,
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(context.l10n.donViDong, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}
