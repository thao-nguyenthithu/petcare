import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/sitter/data/sitter_dashboard.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';
import 'package:petcare_app/features/sitter/widgets/section_empty.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Đọc THẲNG danh sách truyền vào, chép sang state riêng là chốt rỗng mãi
class PendingOrdersSection extends ConsumerWidget {
  const PendingOrdersSection({
    super.key,
    required this.orders,
    this.tongDonCho = 0,
  });

  final List<DonChoTraLoi> orders;
  final int tongDonCho;
  List<DonChoTraLoi> get _orders =>
      List.of(orders)..sort((a, b) => a.hanTraLoi.compareTo(b.hanTraLoi));

  Future<void> _moChiTiet(BuildContext context, DonChoTraLoi order) =>
      context.push(AppRoutes.sitterOrderDetailPath(order.id));

  Future<void> _nhanDon(
    BuildContext context,
    WidgetRef ref,
    DonChoTraLoi order,
  ) async {
    if (order.serviceType == LoaiDichVu.datDiDao) {
      await _moChiTiet(context, order);
      return;
    }
    final l10n = context.l10n;
    await chayHanhDongDon(
      context,
      ref,
      order.id,
      (s) => s.nhanDon(order.id),
      nhanBaoXong: l10n.daChapNhanDon,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.donChoXacNhan, style: AppTextStyles.h3),
            if (_orders.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.labelGap),
              AppStatusBadge(
                label: l10n.soMoi(
                  '${tongDonCho > _orders.length ? tongDonCho : _orders.length}',
                ),
                background: AppColors.accent,
                textColor: AppColors.textWhite,
              ),
            ],
            const Spacer(),
            if (_orders.isNotEmpty)
              InkWell(
                onTap: () => context.push(
                  AppRoutes.sitterBookingsPath(
                    trangThai: maChipDon(SitterBookingStatus.choXacNhan),
                  ),
                ),
                child: Text(l10n.xemTatCa, style: AppTextStyles.label),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _orders.isEmpty
              ? SectionEmpty(
                  icon: Icons.inbox_outlined,
                  message: l10n.khongCoDonCho,
                )
              : _ChongThe(
                  soDonSau: (_orders.length - 1).clamp(0, 2),
                  child: _PendingOrderCard(
                    order: _orders.first,
                    onOpen: () => _moChiTiet(context, _orders.first),
                    onAccept: () => _nhanDon(context, ref, _orders.first),
                    onReject: () => _moChiTiet(context, _orders.first),
                  ),
                ),
        ),
      ],
    );
  }
}

// Chồng thẻ
class _ChongThe extends StatelessWidget {
  const _ChongThe({required this.soDonSau, required this.child});

  final int soDonSau;
  final Widget child;

  static const double _thut = 10;
  static const double _mep = 8; // mỗi lớp thò xuống dưới

  @override
  Widget build(BuildContext context) {
    if (soDonSau == 0) return child;
    return Padding(
      // chừa chỗ cho phần mép thò ra khỏi thẻ trên cùng
      padding: EdgeInsets.only(bottom: _mep * soDonSau),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Lớp xa vẽ trước để nằm dưới cùng
          for (var i = soDonSau; i >= 1; i--)
            Positioned(
              left: _thut * i,
              right: _thut * i,
              top: 0,
              bottom: -_mep * i,
              child: Opacity(
                opacity: i == 1 ? 0.7 : 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.radius14),
                    border: Border.all(color: AppColors.neutralLight),
                  ),
                ),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _PendingOrderCard extends StatelessWidget {
  const _PendingOrderCard({
    required this.order,
    required this.onOpen,
    required this.onAccept,
    required this.onReject,
  });

  final DonChoTraLoi order;
  final VoidCallback onOpen;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: 14, // cao riêng của card đơn chờ
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UserAvatar(
                    name: order.ownerName,
                    imageUrl: order.ownerAvatar,
                    size: 52,
                  ),
                  const SizedBox(width: AppSpacing.itemGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.ownerName,
                          style: AppTextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        AppStatusBadge(
                          label: _nhanDichVu(context, order),
                          background: AppColors.cardMint,
                          textColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  AppStatusBadge(
                    label: _conLaiTraLoi(context, order),
                    background: AppColors.accent.withValues(alpha: 0.12),
                    textColor: AppColors.accent,
                    leading: const Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${nhanThoiDiemNgan(l10n, order.startAt)}'
                          '${order.distanceKm == null ? '' : ' · ${l10n.cachBan(kmGon(order.distanceKm!))}'}',
                          style: AppTextStyles.captionSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.soBeVaTen(
                            '${order.pets.length}',
                            PetBrief.moTa(order.pets),
                          ),
                          style: AppTextStyles.captionSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Text(
                    '${dinhDangTien(order.price)}đ',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.itemGap),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.tuChoi,
                      icon: Icons.close,
                      outlined: true,
                      color: AppColors.textSecondary,
                      height: 46,
                      onTap: onReject,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      text: l10n.chapNhan,
                      icon: Icons.check,
                      height: 46,
                      onTap: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _nhanDichVu(BuildContext context, DonChoTraLoi don) {
  final l10n = context.l10n;
  final ten = don.serviceType.ten(l10n);
  return don.durationMinutes == null
      ? ten
      : '$ten · ${l10n.nPhutNhan('${don.durationMinutes}')}';
}

String _conLaiTraLoi(BuildContext context, DonChoTraLoi don) {
  final con = don.hanTraLoi.difference(nowVn()).inMinutes;
  return dongHoConLai(context.l10n, con);
}

String kmGon(double km) => km.toStringAsFixed(1).replaceAll('.', ',');
