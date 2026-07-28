import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/mock_sitter_home.dart';
import 'package:petcare_app/features/sitter/screens/sitter_pending_order_screen.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
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
  late final List<MockPendingOrder> _orders = List.of(widget.orders);

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
              const SizedBox(width: 8),
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
        const SizedBox(height: 12),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _orders.isEmpty
              ? SectionEmpty(
                  icon: Icons.inbox_outlined,
                  message: l10n.khongCoDonCho,
                )
              : Column(
                  children: [
                    for (final order in _orders) ...[
                      _PendingOrderCard(
                        order: order,
                        onOpen: () => _moChiTiet(order),
                        onAccept: () => _boDon(order.id),
                        onReject: () => _boDon(order.id),
                      ),
                      if (order != _orders.last) const SizedBox(height: 12),
                    ],
                  ],
                ),
        ),
      ],
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PetAvatar(imageUrl: order.petAvatar, size: 52, ring: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.petInfo, style: AppTextStyles.label),
                        const SizedBox(height: 5),
                        AppStatusBadge(
                          label: order.serviceLabel,
                          background: AppColors.cardMint,
                          textColor: AppColors.primaryColor,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${order.ownerName} · ${l10n.cachBan(order.distance)}',
                          style: AppTextStyles.captionSm.copyWith(fontSize: 11),
                        ),
                        Text(
                          order.scheduleTime,
                          style: AppTextStyles.captionSm.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${dinhDangTien(order.price)}đ',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 16,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 5),
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
                ],
              ),
              const SizedBox(height: 12),
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
