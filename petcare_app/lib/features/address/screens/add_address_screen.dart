import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/address/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/features/address/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';
import 'package:petcare_app/shared/widgets/locked_field.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.diaChiSua, this.viTriMoi});

  final SavedAddress? diaChiSua;
  final KetQuaViTri? viTriMoi;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  late final TextEditingController _tenKhacController;
  late final TextEditingController _ghiChuController;
  late NhanDiaChi _nhan;

  // Địa chỉ lấy từ bản đồ
  String? _tinh;
  String? _phuong;
  String? _soNha;
  LatLng? _viTri;
  bool _dangLuu = false;

  bool get _laSua => widget.diaChiSua != null;

  @override
  void initState() {
    super.initState();
    final dc = widget.diaChiSua;
    final vm = widget.viTriMoi;
    _tenKhacController = TextEditingController(text: dc?.customLabel ?? '');
    _ghiChuController = TextEditingController(text: dc?.ghiChu ?? '');
    _nhan = dc?.label ?? NhanDiaChi.nha;
    if (vm != null) {
      _tinh = vm.tinh;
      _phuong = vm.phuong;
      _soNha = vm.soNhaDuong;
      _viTri = vm.viTri;
    } else if (dc != null) {
      _tinh = dc.tinh;
      _phuong = dc.phuongXa;
      _soNha = dc.soNha;
      if (dc.lat != null && dc.lng != null) _viTri = LatLng(dc.lat!, dc.lng!);
    }
  }

  @override
  void dispose() {
    _tenKhacController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  bool get _duDieuKien =>
      _viTri != null &&
      (_tinh?.trim().isNotEmpty ?? false) &&
      (_phuong?.trim().isNotEmpty ?? false);

  Future<void> _doiViTri() async {
    final kq = await context.push<KetQuaViTri>(
      AppRoutes.locationPicker,
      extra: _viTri,
    );
    if (!mounted || kq == null) return;
    setState(() {
      _tinh = kq.tinh;
      _phuong = kq.phuong;
      _soNha = kq.soNhaDuong;
      _viTri = kq.viTri;
    });
  }

  Future<void> _luu() async {
    if (_dangLuu) return;
    setState(() => _dangLuu = true);
    final notifier = ref.read(savedAddressesProvider.notifier);
    final tenKhac = _tenKhacController.text.trim();
    final ghiChu = _ghiChuController.text.trim();
    final diaChi = SavedAddress(
      id: _laSua ? widget.diaChiSua!.id : '',
      label: _nhan,
      tinh: _tinh ?? '',
      phuongXa: _phuong ?? '',
      soNha: _soNha ?? '',
      customLabel: _nhan == NhanDiaChi.khac && tenKhac.isNotEmpty
          ? tenKhac
          : null,
      ghiChu: ghiChu.isEmpty ? null : ghiChu,
      lat: _viTri?.latitude,
      lng: _viTri?.longitude,
      isDefault: _laSua ? widget.diaChiSua!.isDefault : false,
    );
    try {
      if (_laSua) {
        await notifier.capNhat(diaChi);
      } else {
        await notifier.them(diaChi);
      }
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        setState(() => _dangLuu = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.luuDiaChiThatBai)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(title: _laSua ? l10n.suaDiaChi : l10n.themDiaChi),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.textGap,
                  AppSpacing.screenPadding,
                  AppSpacing.groupGap,
                ),
                children: [
                  if (_viTri != null)
                    MapPreview(viTri: _viTri!, onDoi: _doiViTri)
                  else
                    AppButton(
                      text: l10n.chonViTriTrenBanDo,
                      icon: Icons.map_outlined,
                      outlined: true,
                      onTap: _doiViTri,
                    ),
                  const SizedBox(height: AppSpacing.blockGap),
                  LockedField(label: l10n.tinhThanhPho, value: _tinh),
                  const SizedBox(height: AppSpacing.stackGap),
                  LockedField(label: l10n.phuongXa, value: _phuong),
                  const SizedBox(height: AppSpacing.stackGap),
                  LockedField(label: l10n.soNhaTenDuong, value: _soNha),
                  const SizedBox(height: AppSpacing.stackGap),
                  AppTextField(
                    label: l10n.ghiChuDiaChi,
                    hint: l10n.hintGhiChuDiaChi,
                    controller: _ghiChuController,
                    fillColor: AppColors.surface,
                  ),
                  const SizedBox(height: AppSpacing.stackGap),
                  Text(l10n.nhanDiaChi, style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.labelGap),
                  _ChonNhan(
                    nhan: _nhan,
                    onChon: (nhan) => setState(() => _nhan = nhan),
                  ),
                  if (_nhan == NhanDiaChi.khac) ...[
                    const SizedBox(height: AppSpacing.stackGap),
                    AppTextField(
                      label: l10n.tenNhanTuChon,
                      hint: l10n.hintTenNhanTuChon,
                      controller: _tenKhacController,
                      fillColor: AppColors.surface,
                    ),
                  ],
                ],
              ),
            ),
            BottomActionBar(
              vien: false,
              child: AppButton(
                text: l10n.luuDiaChi,
                enabled: _duDieuKien && !_dangLuu,
                onTap: _luu,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Ba nhãn địa chỉ là một ButtonSelect
class _ChonNhan extends StatelessWidget {
  const _ChonNhan({required this.nhan, required this.onChon});

  final NhanDiaChi nhan;
  final ValueChanged<NhanDiaChi> onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ten = {
      NhanDiaChi.nha: l10n.nha,
      NhanDiaChi.congTy: l10n.congTy,
      NhanDiaChi.khac: l10n.khac,
    };
    return Column(
      children: [
        for (final loai in NhanDiaChi.values) ...[
          ButtonSelect(
            selected: nhan == loai,
            title: ten[loai]!,
            onTap: () => onChon(loai),
          ),
          if (loai != NhanDiaChi.values.last)
            const SizedBox(height: AppSpacing.stackGap),
        ],
      ],
    );
  }
}
