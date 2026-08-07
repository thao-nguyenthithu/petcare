import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_cancel_reasons.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/booking_detail_hero.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

class SitterCancelledBody extends StatelessWidget {
  const SitterCancelledBody({
    super.key,
    required this.don,
    required this.onXemBe,
  });

  final SitterOrderDetail don;
  final VoidCallback onXemBe;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 14, bottom: 24),
      children: [
        FlatSection(
          child: BookingDetailHero(
            pets: don.pets,
            loai: don.loai,
            tenDichVu: don.tenDichVu,
            onXemBe: onXemBe,
          ),
        ),
        const FlatDivider(),
        FlatSection(child: _KhoiDaHuy(don: don)),
        const FlatDivider(),
        FlatSection(child: _KhoanBanNhan(don: don)),
        const FlatDivider(),
        FlatSection(child: _ThongTinDonDaHuy(don: don)),
      ],
    );
  }
}

class _KhoiDaHuy extends StatelessWidget {
  const _KhoiDaHuy({required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gio = don.gioHetHan ?? '';
    final ngay = don.ngayHetHan ?? '';
    final (String tieuDe, String moTa) = switch (don.tinhTrang) {
      TinhTrangDonNcc.banDaHuy => (
        l10n.banDaHuyLuc(gio, ngay),
        _themLyDo(context, l10n.moTaBanBoDon),
      ),
      TinhTrangDonNcc.khachHuy => (
        l10n.chuNuoiDaHuyLuc(gio, ngay),
        _themLyDo(context, l10n.moTaChuNuoiBoDon),
      ),
      TinhTrangDonNcc.khachVangMat => (
        l10n.donHuyViChuNuoiVangMat,
        l10n.moTaHuyViChuNuoiVangMat(gio, ngay),
      ),
      // Không ai bấm huỷ, do đã nhận đơn khác trùng khung giờ
      TinhTrangDonNcc.tuHuyTrungLich => (
        l10n.donTuHuyTrungLich,
        l10n.moTaTuHuyTrungLich(gio, ngay),
      ),
      // Nói rõ không tính tỷ lệ huỷ
      TinhTrangDonNcc.huyBoiQuanTri => (
        l10n.quanTriDaHuyNhan,
        l10n.moTaQuanTriHuyNcc,
      ),
      // Hết hạn nhận thì không ai bấm huỷ, không có lý do
      _ => (l10n.donHetHanNhanLuc(gio, ngay), l10n.moTaBoLoHanNhan),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.cancel_outlined, size: 20, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tieuDe,
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 6),
              Text(moTa, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }

  // Lý do đứng trước câu hệ quả, giống bản của chủ nuôi
  String _themLyDo(BuildContext context, String hauQua) {
    final ma = don.lyDoHuy;
    if (ma == null || ma.isEmpty) return hauQua;
    return '${context.l10n.lyDoNganGon(nhanLyDoNcc(context, ma))} $hauQua';
  }
}

// Con số do server chốt, màn không tự tính
class _KhoanBanNhan extends StatelessWidget {
  const _KhoanBanNhan({required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tien = don.tienHuyBanNhan;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.khoanBanNhan, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                tien > 0
                    ? l10n.khoanBuTuPhiHuy
                    : don.daHetHan
                    ? l10n.donHetHanKhongCoPhiHuy
                    : l10n.donHuyKhongCoKhoanNhan,
                style: AppTextStyles.captionSm,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${dinhDangTien(tien)}đ',
              style: AppTextStyles.h2.copyWith(
                // Có tiền về mới tô xanh
                color: tien > 0
                    ? AppColors.primaryColor
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (tien > 0) ...[
          const SizedBox(height: 10),
          Text(l10n.moTaKhoanBuVaoVi, style: AppTextStyles.captionSm),
        ],
      ],
    );
  }
}

// Đơn vừa mất là đơn nào: khung giờ hẹn và chủ nuôi
class _ThongTinDonDaHuy extends StatelessWidget {
  const _ThongTinDonDaHuy({required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.thongTinDonDaHuy, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        _Hang(
          icon: Icons.calendar_today_outlined,
          nhan: l10n.thoiGianDaDat,
          giaTri: don.moTaThoiGian,
        ),
        const SizedBox(height: 16),
        _Hang(
          icon: Icons.person_outline,
          nhan: l10n.chuNuoi,
          giaTri: don.tenChuNuoi,
        ),
      ],
    );
  }
}

class _Hang extends StatelessWidget {
  const _Hang({required this.icon, required this.nhan, required this.giaTri});

  final IconData icon;
  final String nhan;
  final String giaTri;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nhan, style: AppTextStyles.captionSm),
              const SizedBox(height: 4),
              Text(giaTri, style: AppTextStyles.label),
            ],
          ),
        ),
      ],
    );
  }
}
