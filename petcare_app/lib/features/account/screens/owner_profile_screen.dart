import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const double _duongKinhAvatar = 88;

// Màn Hồ sơ của tôi của chủ nuôi
class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(currentUserProvider);

    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.hoSoCuaToi,
            action: _NutSua(
              onTap: () => context.push(AppRoutes.ownerProfileEdit),
            ),
          ),
          const AppDongKe(),
        ],
      ),
      body: switch (async) {
        AsyncData(:final value) => AppRefreshIndicator(
          onRefresh: () => ref.read(currentUserProvider.future),
          child: _NoiDung(user: value),
        ),
        AsyncError() => AppNetworkError(
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        _ => const AppSkeletonList(soThe: 5, caoThe: 64),
      },
    );
  }
}

class _NutSua extends StatelessWidget {
  const _NutSua({required this.onTap});
  static const double _co = 36;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardMint,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: _co,
          height: _co,
          child: Icon(
            Icons.edit_outlined,
            size: 18,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _NoiDung extends ConsumerWidget {
  const _NoiDung({required this.user});

  final CurrentUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final soBe = ref.watch(myPetsProvider).asData?.value.length;
    final soDiaChi = ref.watch(savedAddressesProvider).asData?.value.length;
    final laNguoiCham = user.laNguoiCham;
    final ncc = laNguoiCham ? ref.watch(sitterMeProvider).asData?.value : null;
    final ngaySinh = ncc?.dateOfBirth ?? user.dateOfBirth;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.blockGap,
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
      ),
      children: [
        Center(
          child: Column(
            children: [
              UserAvatar(
                name: user.fullName,
                imageUrl: user.avatarUrl,
                size: _duongKinhAvatar,
              ),
              const SizedBox(height: AppSpacing.itemGap),
              Text(user.fullName, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.labelGap),
              // Người vừa chăm vừa nuôi thì đeo cả hai vai
              Wrap(
                spacing: AppSpacing.labelGap,
                runSpacing: AppSpacing.labelGap,
                alignment: WrapAlignment.center,
                children: [
                  _Pill(text: l10n.chuNuoi),
                  if (laNguoiCham) ...[
                    _Pill(text: l10n.nguoiCham),
                    _Pill(text: l10n.daXacMinh, xanh: true),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.blockGap),
        const AppDongKe(),
        const SizedBox(height: AppSpacing.blockGap),
        _TieuDeNhom(l10n.thongTinCaNhan),
        const SizedBox(height: AppSpacing.labelGap),
        Text(l10n.moTaHoSoChiMinhBan, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.itemGap),
        _Hang(nhan: l10n.hoVaTen, giaTri: user.fullName),
        _Hang(
          nhan: l10n.ngaySinh,
          giaTri: ngaySinh == null ? l10n.chuaCapNhat : ngayThangNam(ngaySinh),
          mo: ngaySinh == null,
          duoi: laNguoiCham && ngaySinh != null
              ? _Pill(text: l10n.khopCccd, xanh: true)
              : null,
        ),
        if (laNguoiCham)
          _Hang(
            nhan: l10n.soCccd,
            giaTri: ncc?.nationalIdMasked ?? l10n.chuaXacThuc,
            mo: ncc?.nationalIdMasked == null,
            duoi: ncc?.nationalIdMasked == null
                ? null
                : _Pill(text: l10n.daXacThuc, xanh: true),
          ),
        _Hang(
          nhan: l10n.soDienThoai,
          giaTri: user.phone ?? l10n.chuaCapNhat,
          mo: user.phone == null,
        ),
        _Hang(
          nhan: l10n.email,
          giaTri: user.email ?? l10n.chuaCapNhat,
          mo: user.email == null,
          duoi: user.emailVerified
              ? _Pill(text: l10n.daXacMinh, xanh: true)
              : null,
        ),
        const SizedBox(height: AppSpacing.blockGap),
        _TieuDeNhom(l10n.cuaToi),
        const SizedBox(height: AppSpacing.labelGap),
        _HangMo(
          nhan: l10n.thuCungCuaToi,
          phu: soBe == null ? '' : l10n.soBe('$soBe'),
          onTap: () => context.push(AppRoutes.myPets),
        ),
        _HangMo(
          nhan: l10n.diaChiDaLuu,
          phu: soDiaChi == null ? '' : l10n.soDiaChi('$soDiaChi'),
          onTap: () => context.push(AppRoutes.addresses),
        ),
        if (laNguoiCham) ...[
          const SizedBox(height: AppSpacing.blockGap),
          _TieuDeNhom(l10n.vaiNguoiCham),
          const SizedBox(height: AppSpacing.itemGap),
          _TheTrangDichVu(ncc: ncc),
        ],
      ],
    );
  }
}

class _TheTrangDichVu extends StatelessWidget {
  const _TheTrangDichVu({required this.ncc});
  static const double _cham = 8;
  final SitterProfile? ncc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      nen: AppColors.cardMint,
      vien: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.trangDichVuCuaBan, style: AppTextStyles.label),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              InkWell(
                onTap: () => context.push(AppRoutes.sitterProfileView),
                child: Text(
                  l10n.xemTrang,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Text(l10n.moTaTrangDichVu, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.itemGap),
          Row(
            children: [
              Container(
                width: _cham,
                height: _cham,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.textGap),
              Text(
                l10n.dangHoatDong,
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              if (ncc case final p? when p.totalReviews > 0) ...[
                const SizedBox(width: AppSpacing.labelGap),
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 2),
                Text(
                  p.ratingAvg.toStringAsFixed(1).replaceAll('.', ','),
                  style: AppTextStyles.captionSm,
                ),
                const SizedBox(width: AppSpacing.textGap),
                Text(
                  '· ${l10n.soDanhGia('${p.totalReviews}')}',
                  style: AppTextStyles.captionSm,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TieuDeNhom extends StatelessWidget {
  const _TieuDeNhom(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.captionSm.copyWith(letterSpacing: 0.6),
  );
}

class _Hang extends StatelessWidget {
  const _Hang({
    required this.nhan,
    required this.giaTri,
    this.mo = false,
    this.duoi,
  });

  final String nhan;
  final String giaTri;
  final bool mo;
  final Widget? duoi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
      child: Row(
        children: [
          Text(nhan, style: AppTextStyles.caption),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Text(
              giaTri,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                color: mo ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
          if (duoi case final d?) ...[
            const SizedBox(width: AppSpacing.labelGap),
            d,
          ],
        ],
      ),
    );
  }
}

class _HangMo extends StatelessWidget {
  const _HangMo({required this.nhan, required this.phu, required this.onTap});

  final String nhan;
  final String phu;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
        child: Row(
          children: [
            Expanded(child: Text(nhan, style: AppTextStyles.label)),
            Text(phu, style: AppTextStyles.captionSm),
            const SizedBox(width: AppSpacing.textGap),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.xanh = false});

  final String text;
  final bool xanh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.itemGap,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: xanh ? AppColors.cardMint : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
      ),
      child: Text(
        text,
        style: AppTextStyles.captionSm.copyWith(
          color: xanh ? AppColors.primaryColor : AppColors.textSecondary,
        ),
      ),
    );
  }
}
