import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/address/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/features/sitter/data/sitter_service_area.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/locked_field.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';

// Màn con sửa Khu vực phục vụ
class SitterServiceAreaScreen extends ConsumerStatefulWidget {
  const SitterServiceAreaScreen({super.key});

  @override
  ConsumerState<SitterServiceAreaScreen> createState() =>
      _SitterServiceAreaScreenState();
}

class _SitterServiceAreaScreenState
    extends ConsumerState<SitterServiceAreaScreen> {
  LatLng? _viTri;
  String? _diaChi;
  late int _banKinh;
  final _ghiChuController = TextEditingController();
  bool _dirty = false;
  bool _dangLuu = false;

  @override
  void initState() {
    super.initState();
    final area =
        ref.read(sitterServiceAreaProvider).value ?? const SitterServiceArea();
    _viTri = area.viTri;
    _diaChi = area.address;
    _banKinh = area.radiusKm;
    _ghiChuController.text = area.addressNote ?? '';
    _ghiChuController.addListener(() {
      if (!_dirty) setState(() => _dirty = true);
    });
  }

  @override
  void dispose() {
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _doiViTri() async {
    final kq = await context.push<KetQuaViTri>(
      AppRoutes.locationPicker,
      extra: _viTri,
    );
    if (!mounted || kq == null) return;
    final phanChiTiet = [
      kq.soNhaDuong,
      kq.phuong,
      kq.tinh,
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');
    setState(() {
      _dirty = true;
      _viTri = kq.viTri;
      _diaChi = (kq.moTa != null && kq.moTa!.trim().isNotEmpty)
          ? kq.moTa
          : (phanChiTiet.isEmpty ? null : phanChiTiet);
    });
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    final l10n = context.l10n;
    final ghiChu = _ghiChuController.text.trim();
    setState(() => _dangLuu = true);
    try {
      await ref
          .read(sitterServiceAreaProvider.notifier)
          .capNhat(
            SitterServiceArea(
              address: _diaChi,
              lat: _viTri?.latitude,
              lng: _viTri?.longitude,
              addressNote: ghiChu.isEmpty ? null : ghiChu,
              radiusKm: _banKinh,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.daLuuKhuVuc)));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _dangLuu = false);
      final thongBao = codeFromError(e) != null
          ? (messageFromError(e) ?? l10n.luuThatBai)
          : l10n.luuThatBai;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(thongBao)));
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
              AppScreenHeader(title: l10n.khuVucPhucVu, onBack: _onBack),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenPadding,
                    AppSpacing.textGap,
                    AppSpacing.screenPadding,
                    AppSpacing.groupGap,
                  ),
                  children: [
                    Text(l10n.moTaKhuVucPhucVu, style: AppTextStyles.captionSm),
                    const SizedBox(height: AppSpacing.blockGap),
                    if (_viTri != null)
                      MapPreview(viTri: _viTri!, onDoi: _doiViTri)
                    else
                      AppButton(
                        text: l10n.chonViTriTrenBanDo,
                        icon: Icons.map_outlined,
                        outlined: true,
                        onTap: _doiViTri,
                      ),
                    const SizedBox(height: AppSpacing.stackGap),
                    Text(l10n.diaChiPhucVu, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.labelGap),
                    LockedField(value: _diaChi),
                    const SizedBox(height: AppSpacing.stackGap),
                    AppTextField(
                      label: l10n.ghiChuDiaChi,
                      hint: l10n.hintGhiChuDiaChi,
                      controller: _ghiChuController,
                      height: 46,
                    ),
                    const SizedBox(height: AppSpacing.blockGap),
                    Row(
                      children: [
                        Text(l10n.banKinhPhucVu, style: AppTextStyles.label),
                        const Spacer(),
                        Text(
                          l10n.soKm('$_banKinh'),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _banKinh.toDouble(),
                      min: minServiceRadiusKm.toDouble(),
                      max: maxServiceRadiusKm.toDouble(),
                      divisions: maxServiceRadiusKm - minServiceRadiusKm,
                      label: l10n.soKm('$_banKinh'),
                      onChanged: (v) => setState(() {
                        _dirty = true;
                        _banKinh = v.round();
                      }),
                    ),
                    Text(
                      l10n.ghiChuKhuVucPhucVu,
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                vien: false,
                child: AppButton(
                  text: l10n.luuKhuVucPhucVu,
                  enabled: _viTri != null && !_dangLuu,
                  onTap: _luu,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
