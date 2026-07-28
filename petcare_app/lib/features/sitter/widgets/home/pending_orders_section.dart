import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_home.dart';
import 'package:petcare_app/features/sitter/screens/sitter_pending_order_screen.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';
import 'package:petcare_app/features/sitter/widgets/section_empty.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';

// Đơn chờ xác nhận
class PendingOrdersSection extends StatefulWidget {
  const PendingOrdersSection({super.key, required this.orders});

  final List<MockPendingOrder> orders;

  @override
  State<PendingOrdersSection> createState() => _PendingOrdersSectionState();
}

class _PendingOrdersSectionState extends State<PendingOrdersSection> {
  // Đơn đến trước nằm trên cùng chồng thẻ
  late final List<MockPendingOrder> _orders = List.of(widget.orders)
    ..sort((a, b) => a.responseCountdown.compareTo(b.responseCountdown));

  void _boDon(String id) {
    setState(() => _orders.removeWhere((o) => o.id == id));
  }

  // Mở chi tiết yêu cầu
  Future<void> _moChiTiet(MockPendingOrder order) async {
    final ketQua = await Navigator.push<PendingOrderResult>(
      context,
      MaterialPageRoute(builder: (_) => SitterPendingOrderScreen(order: order)),
    );
    if (ketQua != null) _boDon(order.id);
  }

  @override
  Widget build(BuildContext context) {
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
                label: l10n.soMoi('${_orders.length}'),
                background: AppColors.accent,
                textColor: AppColors.textWhite,
              ),
            ],
            const Spacer(),
            if (_orders.isNotEmpty)
              InkWell(
                onTap: () => context.push(AppRoutes.sitterBookings),
                child: Text(
                  l10n.xemTatCa,
                  style: AppTextStyles.captionSm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                    onOpen: () => _moChiTiet(_orders.first),
                    onAccept: () => _boDon(_orders.first.id),
                    onReject: () => _boDon(_orders.first.id),
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

  final MockPendingOrder order;
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
                  PetAvatarStack(pets: order.pets, size: 52, ring: true),
                  const SizedBox(width: AppSpacing.itemGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.nhieuBe
                              ? l10n.soBeVaTen(
                                  '${order.pets.length}',
                                  order.moTaBe,
                                )
                              : order.moTaBe,
                          style: AppTextStyles.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        AppStatusBadge(
                          label: order.serviceLabel,
                          background: AppColors.cardMint,
                          textColor: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  AppStatusBadge(
                    label: order.responseCountdown,
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
                          '${order.ownerName} · ${l10n.cachBan(order.distance)}',
                          style: AppTextStyles.captionSm.copyWith(fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          order.scheduleTime,
                          style: AppTextStyles.captionSm.copyWith(fontSize: 11),
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
                      fontSize: 16,
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
