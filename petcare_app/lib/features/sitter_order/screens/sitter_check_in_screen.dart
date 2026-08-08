import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_orders_api_service.dart';
import 'package:petcare_app/features/sitter_order/widgets/gear_missing_sheet.dart';
import 'package:petcare_app/shared/widgets/booking_pet_notes.dart';
import 'package:petcare_app/features/sitter_order/widgets/check_in_location_box.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn nhận bé của người chăm: xác thực điểm đón, đối chiếu bé rồi chụp ảnh
class SitterCheckInScreen extends StatelessWidget {
  const SitterCheckInScreen({super.key, required this.args});

  final CheckInArgs args;

  bool get _duGan => (args.don.metCachDiemDon ?? 0) <= metGeofence;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = args.don;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.nhanBeVaChupAnhCheckIn,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonDichVuSoBe(
                          don.maDon,
                          don.tenDichVu.split(' · ').first,
                          '${don.pets.length}',
                        ),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: CheckInLocationBox(
              met: don.metCachDiemDon ?? 0,
              gio: don.gioToiNoi ?? '',
              duGan: _duGan,
              tieuDeGan: l10n.banDangODiemDon,
              tieuDeXa: l10n.banDangOXaDiemDon,
            ),
          ),
          const SizedBox(height: 14),
          FlatSection(child: _DongNhac(args: args)),
          const FlatDivider(),
          FlatSection(
            child: BookingPetNotes(
              pets: don.pets,
              tieuDe: l10n.doiChieuKhiNhanBe,
              moTa: l10n.chamDeXemThongTinCanThiet,
            ),
          ),
        ],
      ),
      bottomBar: _ThanhNut(args: args, duGan: _duGan),
    );
  }
}

// Chưa báo thiếu thì nhắc luật geofence, báo rồi thì kể lại mốc đã báo
class _DongNhac extends StatelessWidget {
  const _DongNhac({required this.args});

  final CheckInArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daBao = args.trangThai != TrangThaiCheckIn.binhThuong;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          daBao ? Icons.info_outline : Icons.error_outline,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            daBao
                ? l10n.moTaDaBaoThieuDungCu(
                    args.gioBaoThieu ?? '',
                    '$phutChoDungCu',
                  )
                : l10n.canhBaoXaQuaBanKinh('$metGeofence'),
            style: AppTextStyles.captionSm,
          ),
        ),
      ],
    );
  }
}

// Nút phụ đổi theo tình huống thiếu dụng cụ, chỉ sống khi còn việc để làm
class _ThanhNut extends ConsumerStatefulWidget {
  const _ThanhNut({required this.args, required this.duGan});

  final CheckInArgs args;
  final bool duGan;

  @override
  ConsumerState<_ThanhNut> createState() => _ThanhNutState();
}

class _ThanhNutState extends ConsumerState<_ThanhNut> {
  bool _dangGui = false;

  CheckInArgs get args => widget.args;

  Future<void> _baoThieu() async {
    final anh = await showGearMissingSheet(context);
    if (anh == null || anh.isEmpty || !mounted) return;
    await _chay(
      (s) => s.baoThieuDungCu(
        args.don.bookingId,
        anh: anhMultipart(anh, 'gear-missing'),
      ),
    );
  }

  Future<void> _huyViThieu() =>
      _chay((s) => s.huyViThieuDungCu(args.don.bookingId));

  Future<void> _chay(
    Future<void> Function(SitterOrdersApiService s) viec,
  ) async {
    setState(() => _dangGui = true);
    final xong = await chayHanhDongDon(context, ref, args.don.bookingId, viec);
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (xong) {
      context.pushReplacement(
        AppRoutes.sitterOrderDetailPath(args.don.bookingId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final duGan = widget.duGan;
    final (String nhanPhu, VoidCallback? onPhu) = switch (args.trangThai) {
      TrangThaiCheckIn.binhThuong => (l10n.beThieuRoMomHoacDayXich, _baoThieu),
      TrangThaiCheckIn.daBaoThieu => (
        l10n.daBaoThieuRoMomConLai(args.conLai ?? ''),
        null,
      ),
      TrangThaiCheckIn.hetHanDungCu => (l10n.huyDonViThieuDungCu, _huyViThieu),
    };
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: l10n.chupAnhCheckInCacBe,
                height: 50,
                enabled: duGan,
                onTap: () => context.push(
                  AppRoutes.sitterCheckInCameraPath(args.don.bookingId),
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                text: nhanPhu,
                outlined: true,
                height: 50,
                mauChu: AppColors.textSecondary,
                enabled: onPhu != null,
                dangTai: _dangGui,
                onTap: onPhu ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
