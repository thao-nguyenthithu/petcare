import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

const double _voTron = 88;

class PaymentResultRing extends StatelessWidget {
  const PaymentResultRing({super.key, required this.thanhCong});

  final bool thanhCong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _voTron,
      height: _voTron,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: thanhCong ? AppColors.surface : AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        thanhCong ? Icons.check_rounded : Icons.priority_high_rounded,
        size: 44,
        color: thanhCong ? AppColors.primaryColor : AppColors.textWhite,
      ),
    );
  }
}

class PaymentResultTitle extends StatelessWidget {
  const PaymentResultTitle({super.key, required this.args, required this.con});

  final PaymentResultArgs args;
  final Duration con;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thanhCong = args.thanhCong;
    final mauChinh = thanhCong ? AppColors.textWhite : AppColors.textPrimary;
    final mauPhu = thanhCong ? AppColors.cardMint : AppColors.textSecondary;
    final hetGio = !thanhCong && con == Duration.zero;
    final draft = args.draft;
    return Column(
      children: [
        Text(
          thanhCong
              ? l10n.thanhToanThanhCong
              : hetGio
              ? l10n.daHetThoiGianGiuCho
              : l10n.thanhToanThatBai,
          textAlign: TextAlign.center,
          style: AppTextStyles.h1.copyWith(color: mauChinh),
        ),
        const SizedBox(height: 10),
        Text(
          thanhCong
              ? l10n.daGuiYeuCauToiNcc
              : hetGio
              ? l10n.moTaHetGioGiuCho(
                  draft.gio?.nhan ?? '',
                  draft.ngay == null ? '' : ngayThang(draft.ngay!),
                )
              : l10n.moTaThanhToanThatBai,
          textAlign: TextAlign.center,
          style: AppTextStyles.captionSm.copyWith(color: mauPhu),
        ),
        const SizedBox(height: 4),
        if (thanhCong)
          Text(
            l10n.seNhanThongBaoKhiNhanDon,
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm.copyWith(color: mauPhu),
          )
        else if (!hetGio)
          _DongThuLai(con: con),
      ],
    );
  }
}

class PaymentReminder extends StatelessWidget {
  const PaymentReminder({super.key, required this.args, required this.con});

  final PaymentResultArgs args;
  final Duration con;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = args.draft;
    if (!args.thanhCong) {
      if (con == Duration.zero) {
        return Text(
          l10n.chonGioKhacGiuNguyen,
          textAlign: TextAlign.center,
          style: AppTextStyles.captionSm,
        );
      }
      final gio = draft.gio?.nhan ?? '';
      final ngay = draft.ngay == null ? '' : ngayThang(draft.ngay!);
      return Text(
        l10n.ghiChuKhungGioSeNha(gio, ngay),
        textAlign: TextAlign.center,
        style: AppTextStyles.captionSm,
      );
    }
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.radius14),
          ),
          child: Text(
            l10n.conThoiGianNhanDon(dongHoDem(con), draft.sitter.fullName),
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.ghiChuHetHanTuHuy(dinhDangTien(draft.tongTien)),
          textAlign: TextAlign.center,
          style: AppTextStyles.captionSm.copyWith(color: AppColors.cardMint),
        ),
      ],
    );
  }
}

class _DongThuLai extends StatelessWidget {
  const _DongThuLai({required this.con});

  final Duration con;

  @override
  Widget build(BuildContext context) {
    final dongHo = dongHoPhutGiay(con);
    final cau = context.l10n.thuLaiTrongVong(dongHo);
    final viTri = cau.indexOf(dongHo);
    final thuong = AppTextStyles.captionSm;
    if (viTri < 0) {
      return Text(cau, textAlign: TextAlign.center, style: thuong);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: cau.substring(0, viTri)),
          TextSpan(
            text: dongHo,
            style: AppTextStyles.label.copyWith(color: AppColors.accent),
          ),
          TextSpan(text: cau.substring(viTri + dongHo.length)),
        ],
      ),
      textAlign: TextAlign.center,
      style: thuong,
    );
  }
}
