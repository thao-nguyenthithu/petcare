import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_service_area.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/widgets/services/service_list_card.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Trang tất cả dịch vụ của NCC
class MyServicesScreen extends ConsumerWidget {
  const MyServicesScreen({super.key});

  Future<void> _cauHinh(
    BuildContext context,
    WidgetRef ref,
    ServiceType type,
  ) async {
    final services =
        ref.read(sitterServicesProvider).value ?? const SitterServices();
    final ketQua = await context.push<SitterServices>(
      AppRoutes.sitterAddService,
      extra: (type, services),
    );
    if (ketQua == null) return;
    ref.read(sitterServicesProvider.notifier).capNhat(ketQua);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final area =
        ref.watch(sitterServiceAreaProvider).value ?? const SitterServiceArea();
    final services =
        ref.watch(sitterServicesProvider).value ?? const SitterServices();
    final thieu = _banner(l10n, area.daDat, services.hasAny);
    // Đang onboarding tiêu đề Thiết lập công việc của bạn
    final tieuDe = (ref.watch(sitterOnboardingProvider).value ?? false)
        ? l10n.tatCaDichVuCuaToi
        : l10n.hoanTatDeNhanDon;

    return AppScreen(
      backgroundColor: AppColors.background,
      header: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(bottom: BorderSide(color: AppColors.neutralLight)),
        ),
        child: AppScreenHeader(title: tieuDe),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          if (thieu != null) ...[
            _BannerThieu(text: thieu),
            const SizedBox(height: 20),
          ],

          // Khu vực phục vụ
          Text(l10n.khuVucPhucVu, style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(l10n.moTaKhuVucPhucVu, style: AppTextStyles.captionSm),
          const SizedBox(height: 14),
          if (area.daDat)
            _KhuVucDaDat(
              area: area,
              onSua: () => context.push(AppRoutes.sitterServiceArea),
            )
          else
            _KhuVucTrong(
              onDat: () => context.push(AppRoutes.sitterServiceArea),
            ),
          const SizedBox(height: 28),

          // Loại dịch vụ cung cấp
          Text(l10n.loaiDichVu, style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(l10n.batLoaiDichVuBanCungCap, style: AppTextStyles.captionSm),
          const SizedBox(height: 14),
          for (final type in ServiceType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TypeCard(
                type: type,
                services: services,
                onTap: () => _cauHinh(context, ref, type),
                onToggle: (v) =>
                    ref.read(sitterServicesProvider.notifier).batTat(type, v),
              ),
            ),
        ],
      ),
    );
  }

  // Nội dung banner theo phần còn thiếu
  String? _banner(AppLocalizations l10n, bool coKhuVuc, bool coDichVu) {
    if (coKhuVuc && coDichVu) return null;
    if (!coKhuVuc && !coDichVu) return l10n.thieuKhuVucVaDichVu;
    if (!coKhuVuc) return l10n.thieuKhuVuc;
    return l10n.thieuDichVu;
  }
}

// Banner nhắc còn thiếu điều kiện nhận đơn
class _BannerThieu extends StatelessWidget {
  const _BannerThieu({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: AppColors.accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhuVucDaDat extends StatelessWidget {
  const _KhuVucDaDat({required this.area, required this.onSua});

  final SitterServiceArea area;
  final VoidCallback onSua;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final diaChi = (area.address?.isNotEmpty ?? false) ? area.address! : '—';
    final ghiChu = area.addressNote?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MapPreview(viTri: area.viTri!, onDoi: onSua),
        const SizedBox(height: 12),
        Text(
          diaChi,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        if (ghiChu != null && ghiChu.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('${l10n.ghiChu}: $ghiChu', style: AppTextStyles.captionSm),
        ],
        const SizedBox(height: 16),
        Text(
          l10n.banKinhPhucVu,
          style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(l10n.soKm('${area.radiusKm}'), style: AppTextStyles.body),
        const SizedBox(height: 16),
        AppButton(
          text: l10n.suaKhuVuc,
          icon: Icons.edit_location_alt_outlined,
          outlined: true,
          onTap: onSua,
        ),
      ],
    );
  }
}

// Khu vực chưa đặt
class _KhuVucTrong extends StatelessWidget {
  const _KhuVucTrong({required this.onDat});

  final VoidCallback onDat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 40,
            color: AppColors.neutral,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.chuaDatKhuVuc,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: 14),
          AppButton(text: l10n.datKhuVuc, icon: Icons.add, onTap: onDat),
        ],
      ),
    );
  }
}

// Thẻ một loại dịch vụ
class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.type,
    required this.services,
    required this.onTap,
    required this.onToggle,
  });

  final ServiceType type;
  final SitterServices services;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daCauHinh = services.isConfigured(type);
    final bat = services.isEnabled(type);
    return ServiceListCard(
      iconAsset: type.iconAsset,
      title: serviceTypeName(context, type),
      subtitle: daCauHinh
          ? (serviceTypeSummary(context, services, type) ?? '')
          : l10n.chuaThietLap,
      dimmed: daCauHinh && !bat,
      onTap: onTap,
      trailing: daCauHinh
          ? Switch(
              value: bat,
              onChanged: onToggle,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeTrackColor: AppColors.primaryColor,
            )
          : const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
    );
  }
}
