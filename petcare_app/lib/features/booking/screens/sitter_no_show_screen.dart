import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/booking/data/cancel_reasons.dart';
import 'package:petcare_app/features/booking/providers/don_hien_hanh.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';
import 'package:petcare_app/features/booking/services/booking_error_mapper.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/icon_text_row.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const int banKinhDiemDonMet = 200;

// Màn báo người chăm chưa tới
class SitterNoShowScreen extends ConsumerWidget {
  const SitterNoShowScreen({super.key, required this.banChup});

  final OwnerBookingDetail banChup;

  Future<void> _huyDon(BuildContext context, WidgetRef ref) async {
    try {
      await showAppLoading(
        context,
        () => ref
            .read(bookingDetailProvider(banChup.id).notifier)
            .huy(lyDo: maLyDoNccChuaToi),
      );
      if (context.mounted) context.pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(moTaLoiDatLich(context, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final don = donHienHanh(context, ref, banChup);
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: don.chuNuoiPhaiDi
                ? l10n.nguoiChamKhongCoNha
                : l10n.nguoiChamChuaToi,
            subtitle: [
              don.maDon,
              don.chuNuoiPhaiDi
                  ? serviceTypeName(context, don.loai)
                  : serviceTypeNameDai(context, don.loai),
              l10n.soBe('${don.pets.length}'),
              if (don.soDem case final dem?) l10n.soDemNhan('$dem'),
            ].join(' · '),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          FlatSection(child: _TomTatDon(don: don)),
          const FlatDivider(),
          FlatSection(child: _CanCu(don: don)),
          const FlatDivider(),
          FlatSection(child: _BanDuocHoan(don: don)),
        ],
      ),
      bottomBar: BottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: l10n.huyDonVaHoanTien,
              color: AppColors.accent,
              onTap: () => _huyDon(context, ref),
            ),
            const SizedBox(height: 4),
            AppButton(
              text: l10n.choThem,
              flat: true,
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TomTatDon extends StatelessWidget {
  const _TomTatDon({required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(name: don.tenNcc, imageUrl: don.avatarNcc, size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(don.tenNcc, style: AppTextStyles.label),
              const SizedBox(height: 3),
              Text(
                don.chuNuoiPhaiDi
                    ? '${context.l10n.nhanBe} ${don.moTaThoiGian}'
                    : don.moTaThoiGian,
                style: AppTextStyles.captionSm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CanCu extends StatelessWidget {
  const _CanCu({required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (don.chuNuoiPhaiDi) {
      return Column(
        children: [
          IconTextRow(
            icon: Icons.schedule,
            chu: l10n.daGioQuaHenDuDieuKienBaoVang(
              don.gioMoBaoKhongCoNha ?? '',
              '${don.phutQuaHen ?? 0}',
            ),
          ),
          const SizedBox(height: 14),
          IconTextRow(
            icon: Icons.info_outline,
            chu: l10n.moTaViTriBanKhopNhaNcc(don.gioToiNoi ?? ''),
          ),
        ],
      );
    }
    return Column(
      children: [
        IconTextRow(
          icon: Icons.schedule,
          chu:
              '${l10n.daGioQuaGioHenNPhut('${don.phutQuaHen ?? 0}')}. '
              '${l10n.duDieuKienBaoChuaToi}',
        ),
        const SizedBox(height: 14),
        IconTextRow(
          icon: Icons.info_outline,
          chu: don.kmLanCuoi == null
              ? l10n.moTaNccChuaXacThucViTri(don.tenNcc)
              : l10n.moTaViTriNccLanCuoi(
                  '$banKinhDiemDonMet',
                  l10n.soKm(soLeKm(don.kmLanCuoi!)),
                  don.gioGhiNhanCuoi ?? '',
                ),
        ),
      ],
    );
  }
}

class _BanDuocHoan extends StatelessWidget {
  const _BanDuocHoan({required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.banDuocHoan, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        _HangTien(nhan: l10n.daTraQuaVnpay, tien: don.tongTien),
        const SizedBox(height: 10),
        _HangTien(nhan: l10n.phiHuyBanChiu, tien: 0),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text(l10n.hoanVeVnpay, style: AppTextStyles.h3)),
            Text(
              '${dinhDangTien(don.tongTien)}đ',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        IconTextRow(
          icon: Icons.info_outline,
          mauIcon: AppColors.textSecondary,
          chu: l10n.ghiChuDonChuyenDaHuy,
        ),
      ],
    );
  }
}

class _HangTien extends StatelessWidget {
  const _HangTien({required this.nhan, required this.tien});

  final String nhan;
  final int tien;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
        Text('${dinhDangTien(tien)}đ', style: AppTextStyles.label),
      ],
    );
  }
}
