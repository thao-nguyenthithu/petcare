import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_grooming_blocks.dart';
import 'package:petcare_app/features/sitter_order/data/grooming_session.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_action_grid.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_stat_cards.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn tác nghiệp lúc đang tắm và cắt tỉa, đo bằng hạng mục và mốc dự kiến xong
class SitterGroomingSessionScreen extends StatelessWidget {
  const SitterGroomingSessionScreen({super.key, required this.phien});

  final GroomingSession phien;

  @override
  Widget build(BuildContext context) {
    final don = phien.don;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: _ThanhTieuDe(don: don),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: GroomingTasksToDo(
              goiTungBe: phien.goiTungBe,
              tieuDe: context.l10n.cacHangMucCanLam,
            ),
          ),
          const SizedBox(height: 16),
          FlatSection(child: _LuoiSoLieu(phien: phien)),
          const SizedBox(height: 12),
          FlatSection(child: SessionActionGrid(bookingId: phien.don.bookingId)),
          if (phien.nhacDonKeTiep case final nhac?) ...[
            const SizedBox(height: 12),
            FlatSection(
              child: Text(
                nhac,
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FlatSection(
            child: _HangChiTietDon(
              onTap: () => context.push(
                AppRoutes.sitterOrderDetailPath(phien.don.bookingId),
              ),
            ),
          ),
          if (don.dienBien.isNotEmpty) ...[
            const SizedBox(height: 20),
            FlatSection(child: SessionTimeline(moc: don.dienBien)),
          ],
        ],
      ),
      bottomBar: _ThanhDuoi(phien: phien),
    );
  }
}

// Hàng trên cùng: back, việc đang làm kèm mã đơn và chip phiên còn sống
class _ThanhTieuDe extends StatelessWidget {
  const _ThanhTieuDe({required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
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
                    Text(l10n.dangLam, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      l10n.maDonSoBe(don.maDon, '${don.pets.length}'),
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                l10n.dangDienRa,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
        const AppDongKe(),
      ],
    );
  }
}

// Ô giữa nổi hơn vì đó là thứ người chăm liếc nhiều nhất
class _LuoiSoLieu extends StatelessWidget {
  const _LuoiSoLieu({required this.phien});

  final GroomingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final qua = phien.quaDuKien;
    return SessionStatCards(
      the: [
        (
          icon: Icons.calendar_today_outlined,
          so: phien.gioBatDau,
          nhan: l10n.batDau,
          noiBat: false,
          canhBao: false,
        ),
        (
          icon: Icons.schedule_outlined,
          so: qua ? '+${phien.conLaiDuKien}' : phien.conLaiDuKien,
          nhan: qua ? l10n.quaDuKien : l10n.duKienXong,
          noiBat: true,
          canhBao: qua,
        ),
        (
          icon: Icons.photo_library_outlined,
          so: '${phien.soAnhDaGui}',
          nhan: l10n.anhGui,
          noiBat: false,
          canhBao: false,
        ),
      ],
    );
  }
}

// Nói thẳng bên trong có gì để người chăm khỏi phải mở ra dò
class _HangChiTietDon extends StatelessWidget {
  const _HangChiTietDon({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(l10n.xemChiTietDon, style: AppTextStyles.h3)),
            const SizedBox(width: 10),
            Text(l10n.beGhiChuTien, style: AppTextStyles.captionSm),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Thanh đáy chỉ một việc; nút tô cam để không bấm nhầm lúc còn đang làm dở
class _ThanhDuoi extends StatelessWidget {
  const _ThanhDuoi({required this.phien});

  final GroomingSession phien;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
          child: AppButton(
            text: context.l10n.ketThucDichVu,
            height: 50,
            color: AppColors.accent,
            onTap: () => context.push(
              AppRoutes.sitterFinishGroomingPath(phien.don.bookingId),
            ),
          ),
        ),
      ),
    );
  }
}
