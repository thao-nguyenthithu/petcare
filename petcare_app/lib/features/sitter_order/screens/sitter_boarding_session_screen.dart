import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/booking_detail_hero.dart';
import 'package:petcare_app/shared/widgets/booking_pet_notes.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_boarding_blocks.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_action_grid.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/session_stat_cards.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn tác nghiệp kỳ giữ, tính theo ngày nên không đếm ngược
class SitterBoardingSessionScreen extends StatelessWidget {
  const SitterBoardingSessionScreen({super.key, required this.phien});

  final BoardingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = phien.don;
    final ky = don.trongGiu;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: _ThanhTieuDe(don: don),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: BookingDetailHero(
              pets: don.pets,
              loai: don.loai,
              tenDichVu: don.tenDichVu,
              onXemBe: () => context.push(
                AppRoutes.bookingPets,
                extra: (
                  maDon: don.maDon,
                  tenDichVu: don.tenDichVu,
                  pets: don.pets,
                ),
              ),
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: BoardingStayBanner(
              soBe: don.pets.length,
              soDem: phien.soDem,
              demHienTai: phien.demHienTai,
              ketThucSom: don.daChotKetThucSom,
              dongCuoi: ky?.conLaiToiTra == null
                  ? null
                  : l10n.conLaiKhoang(ky!.conLaiToiTra!),
            ),
          ),
          const SizedBox(height: 16),
          FlatSection(
            child: BoardingOwnerNote(
              ghiChuDon: don.ghiChu,
              ghiChuLucNhanBe: ky?.ghiChuLucNhanBe,
            ),
          ),
          const SizedBox(height: 16),
          FlatSection(
            child: SessionStatCards(
              the: [
                (
                  icon: Icons.calendar_today_outlined,
                  so: l10n.ngayTrenTong(
                    '${phien.demHienTai}',
                    '${phien.soDem}',
                  ),
                  nhan: l10n.kyGiuNhan,
                  noiBat: false,
                  canhBao: false,
                ),
                (
                  icon: Icons.schedule_outlined,
                  so: ky?.gioTraDuKien ?? '',
                  nhan: l10n.traBe,
                  noiBat: true,
                  canhBao: false,
                ),
                (
                  icon: Icons.photo_library_outlined,
                  so: '${phien.soAnhDaGui}',
                  nhan: l10n.anhGui,
                  noiBat: false,
                  canhBao: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FlatSection(
            child: SessionActionGrid(
              bookingId: phien.don.bookingId,
              nhanGiua: l10n.guiCapNhat,
              onGiua: () => context.push(
                AppRoutes.sitterDailyUpdatePath(phien.don.bookingId),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FlatSection(
            child: _HangChiTietDon(
              onTap: () => context.push(
                AppRoutes.sitterOrderDetailPath(phien.don.bookingId),
              ),
            ),
          ),
          const FlatDivider(),
          FlatSection(child: BookingPetNotes(pets: don.pets)),
        ],
      ),
      bottomBar: _ThanhDuoi(phien: phien),
    );
  }
}

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
                    Text(l10n.dangTrong, style: AppTextStyles.h3),
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

// Nói rõ bên trong có gì, khỏi phải mở ra dò
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

// Thanh đáy hai nút, nút trả bé chỉ mở đúng ngày trả
class _ThanhDuoi extends StatelessWidget {
  const _ThanhDuoi({required this.phien});

  final BoardingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                text: l10n.nhanTinChoChuNuoi,
                height: 50,
                onTap: () => moChatCuaDon(
                  context,
                  phien.don.bookingId,
                  laChuNuoi: false,
                ),
              ),
              const SizedBox(height: 8),
              AppButton(
                text: phien.moTraBe
                    ? l10n.traBeVaChupAnh
                    : l10n.traBeVaChupAnhMoNgay(phien.ngayTraNgan),
                flat: true,
                height: 50,
                color: AppColors.textSecondary,
                enabled: phien.moTraBe,
                onTap: () => context.push(
                  AppRoutes.sitterHandoverCameraPath(
                    phien.don.bookingId,
                    LoaiBanGiao.traBe.ma,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
