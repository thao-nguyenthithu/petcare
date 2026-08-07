import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';
import 'package:petcare_app/shared/widgets/dotted_box.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/data/booking_args.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

typedef _Muc = ({SavedAddress diaChi, double? km, bool trongBanKinh});

class PickupAddressScreen extends ConsumerStatefulWidget {
  const PickupAddressScreen({super.key, required this.args});

  final BookingArgs args;

  @override
  ConsumerState<PickupAddressScreen> createState() =>
      _PickupAddressScreenState();
}

class _PickupAddressScreenState extends ConsumerState<PickupAddressScreen> {
  String? _chon;

  SitterProfile get _sitter => widget.args.sitter;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ds = ref.watch(savedAddressesProvider).asData?.value ?? const [];
    final muc = [for (final d in ds) _tinh(d)];
    final trongVung = muc.where((m) => m.trongBanKinh).toList();
    final chon =
        _chon ?? (trongVung.isEmpty ? null : trongVung.first.diaChi.id);
    final banKinh = _sitter.serviceArea?.radiusKm;

    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: widget.args.loai == ServiceType.walking
                ? l10n.chonDiemDon
                : l10n.chonDiaChi,
            subtitle:
                '${_sitter.fullName} · '
                '${serviceTypeName(context, widget.args.loai)}',
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.diaChiDaLuu, style: AppTextStyles.h3),
                const SizedBox(height: 14),
                for (final m in muc)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ButtonSelect(
                      selected: m.trongBanKinh && m.diaChi.id == chon,
                      title: m.diaChi.tenNhan(l10n.nha, l10n.congTy, l10n.khac),
                      titleColor: m.trongBanKinh ? null : AppColors.neutral,
                      subtitle: m.diaChi.diaChiDayDu,
                      subtitleMaxLines: 2,
                      subtitleColor: m.trongBanKinh ? null : AppColors.neutral,
                      duoi: _ChipKhoangCach(
                        muc: m,
                        tenNcc: _sitter.fullName,
                        xetBanKinh: _xetBanKinh,
                      ),
                      onTap: m.trongBanKinh
                          ? () => setState(() => _chon = m.diaChi.id)
                          : null,
                    ),
                  ),
                DottedBox(
                  onTap: () => context.push(AppRoutes.addAddress),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.themDiaChiMoi,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!_xetBanKinh)
                  AppNoteBox(
                    text: l10n.ghiChuKhongChanBanKinh(_sitter.fullName),
                  )
                else if (banKinh != null)
                  AppNoteBox(
                    text: l10n.ghiChuBanKinhNhanDon(
                      _sitter.fullName,
                      l10n.soKm(soLeKm(banKinh.toDouble())),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          text: l10n.dungDiaChiNay,
          enabled: chon != null,
          onTap: () =>
              context.pop(muc.firstWhere((m) => m.diaChi.id == chon).diaChi),
        ),
      ),
    );
  }

  bool get _xetBanKinh => widget.args.loai != ServiceType.boarding;

  _Muc _tinh(SavedAddress d) {
    final area = _sitter.serviceArea;
    if (area == null || !area.daDat || d.lat == null || d.lng == null) {
      return (diaChi: d, km: null, trongBanKinh: true);
    }
    final km = const Distance().as(
      LengthUnit.Kilometer,
      LatLng(d.lat!, d.lng!),
      area.viTri!,
    );
    return (
      diaChi: d,
      km: km,
      trongBanKinh: !_xetBanKinh || km <= area.radiusKm,
    );
  }
}

class _ChipKhoangCach extends StatelessWidget {
  const _ChipKhoangCach({
    required this.muc,
    required this.tenNcc,
    required this.xetBanKinh,
  });

  final _Muc muc;
  final String tenNcc;
  final bool xetBanKinh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (muc.km == null) return const SizedBox.shrink();
    final trong = muc.trongBanKinh;
    final chu = !xetBanKinh
        ? l10n.cachNhaNccSoKm(tenNcc, l10n.soKm(soLeKm(muc.km!)))
        : '${trong ? l10n.trongKhuVuc : l10n.ngoaiBanKinh} · '
              '${l10n.cachSoKm(l10n.soKm(soLeKm(muc.km!)))}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: trong ? AppColors.cardMint : nenCanhBao,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        chu,
        style: AppTextStyles.captionSm.copyWith(
          color: trong ? AppColors.primaryColor : AppColors.accent,
        ),
      ),
    );
  }
}
