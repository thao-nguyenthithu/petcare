import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  ServiceType _type = ServiceType.walking;
  // 0 = Chó, 1 = Mèo, 2 = Cả hai
  int _loai = 2;
  int _phut = 30;
  final _tenController = TextEditingController();
  final _giaController = TextEditingController();
  final _sucChuaController = TextEditingController();
  final _giaTheoCan = List.generate(4, (_) => TextEditingController());

  @override
  void dispose() {
    _tenController.dispose();
    _giaController.dispose();
    _sucChuaController.dispose();
    for (final controller in _giaTheoCan) {
      controller.dispose();
    }
    super.dispose();
  }

  void _baoLoi(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _luu() {
    final l10n = context.l10n;
    final ten = _tenController.text.trim();
    if (ten.isEmpty) {
      _baoLoi(l10n.khongDuocDeTrong);
      return;
    }
    final loai = switch (_loai) {
      0 => l10n.cho,
      1 => l10n.meo,
      _ => l10n.caHai,
    };
    final String subtitle;
    switch (_type) {
      case ServiceType.walking:
        final gia = _giaController.text.trim();
        if (gia.isEmpty) {
          _baoLoi(l10n.khongDuocDeTrong);
          return;
        }
        subtitle = '${l10n.datThuCung} · $loai · $gia${l10n.donGiaLuot}';
      case ServiceType.boarding:
        final gia = _giaController.text.trim();
        if (gia.isEmpty) {
          _baoLoi(l10n.khongDuocDeTrong);
          return;
        }
        subtitle = '${l10n.trongGiu} · $loai · $gia${l10n.donGiaNgay}';
      case ServiceType.grooming:
        final gia = _giaTheoCan.first.text.trim();
        if (gia.isEmpty) {
          _baoLoi(l10n.khongDuocDeTrong);
          return;
        }
        subtitle = '${l10n.catTia} · $loai · $gia${l10n.donGiaBe}';
    }
    context.pop(ServiceDraft(type: _type, name: ten, subtitle: subtitle));
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
                Text(l10n.themDichVu, style: AppTextStyles.h1),
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
                      onTap: () => setState(() => _type = ServiceType.walking),
                    ),
                    const SizedBox(width: 10),
                    _TypeTile(
                      icon: 'assets/icons/paw.svg',
                      label: l10n.trongGiu,
                      selected: _type == ServiceType.boarding,
                      onTap: () => setState(() => _type = ServiceType.boarding),
                    ),
                    const SizedBox(width: 10),
                    _TypeTile(
                      icon: 'assets/icons/icon_grooming.svg',
                      label: l10n.catTia,
                      selected: _type == ServiceType.grooming,
                      onTap: () => setState(() => _type = ServiceType.grooming),
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
                      selected: _loai == 0,
                      onTap: () => setState(() => _loai = 0),
                    ),
                    const SizedBox(width: 10),
                    _ChipChon(
                      label: l10n.meo,
                      selected: _loai == 1,
                      onTap: () => setState(() => _loai = 1),
                    ),
                    const SizedBox(width: 10),
                    _ChipChon(
                      label: l10n.caHai,
                      selected: _loai == 2,
                      onTap: () => setState(() => _loai = 2),
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
                      for (final phut in const [30, 60, 90]) ...[
                        if (phut != 30) const SizedBox(width: 10),
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
                    hint: '50.000',
                    controller: _giaController,
                    height: 46,
                    keyboardType: TextInputType.number,
                    suffixText: l10n.donGiaLuot,
                  ),
                ] else if (_type == ServiceType.boarding) ...[
                  AppTextField(
                    label: l10n.giaDichVu,
                    hint: '200.000',
                    controller: _giaController,
                    height: 46,
                    keyboardType: TextInputType.number,
                    suffixText: l10n.donGiaNgay,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: l10n.sucChuaToiDa,
                    hint: l10n.hintSucChua,
                    controller: _sucChuaController,
                    height: 46,
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  Row(
                    children: [
                      _nhan(l10n.bangGiaCanNang),
                      const Spacer(),
                      Text(l10n.donGiaBe, style: AppTextStyles.captionSm),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _HangGia(
                    label: l10n.duoi5kg,
                    hint: '150.000',
                    controller: _giaTheoCan[0],
                  ),
                  const SizedBox(height: 8),
                  _HangGia(
                    label: l10n.tu5den10kg,
                    hint: '220.000',
                    controller: _giaTheoCan[1],
                  ),
                  const SizedBox(height: 8),
                  _HangGia(
                    label: l10n.tu10den20kg,
                    hint: '300.000',
                    controller: _giaTheoCan[2],
                  ),
                  const SizedBox(height: 8),
                  _HangGia(
                    label: l10n.tren20kg,
                    hint: '400.000',
                    controller: _giaTheoCan[3],
                  ),
                ],
                const SizedBox(height: 28),
                AppButton(text: l10n.luuDichVu, height: 56, onTap: _luu),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: selected ? AppColors.cardMint : AppColors.surface,
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : AppColors.surface,
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
    );
  }
}

class _HangGia extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const _HangGia({
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.caption,
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text('đ', style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}
