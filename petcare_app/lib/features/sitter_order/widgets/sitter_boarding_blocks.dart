import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';
import 'package:petcare_app/shared/utils/diem_so.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

const double _doanDem = 6;

class BoardingStayBanner extends StatelessWidget {
  const BoardingStayBanner({
    super.key,
    required this.soBe,
    required this.soDem,
    required this.demHienTai,
    this.ketThucSom = false,
    this.dongTrai,
    this.dongPhai,
    this.dongCuoi,
  });

  final int soBe;
  final int soDem;
  final int demHienTai;
  final bool ketThucSom;
  final String? dongTrai;
  final String? dongPhai;
  final String? dongCuoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mauNhan = ketThucSom ? AppColors.accent : AppColors.primaryColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.home_outlined,
              size: 18,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.dangTrongNBe('$soBe'),
                style: AppTextStyles.label,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              ketThucSom
                  ? l10n.demTrenTong('$demHienTai', '$soDem')
                  : l10n.ngayTrenTong('$demHienTai', '$soDem'),
              style: AppTextStyles.label.copyWith(color: mauNhan),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < soDem; i++) ...[
              if (i != 0) const SizedBox(width: 4),
              Expanded(child: _Doan(mau: _mauDoan(i))),
            ],
          ],
        ),
        if (dongTrai != null || dongPhai != null) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (dongTrai case final trai?)
                Expanded(child: Text(trai, style: AppTextStyles.captionSm)),
              if (dongPhai case final phai?) ...[
                const SizedBox(width: 10),
                Text(phai, style: AppTextStyles.captionSm),
              ],
            ],
          ),
        ],
        if (dongCuoi case final cuoi?) ...[
          const SizedBox(height: 6),
          Text(cuoi, style: AppTextStyles.captionSm),
        ],
      ],
    );
  }

  // Đêm thứ i tô màu gì
  Color _mauDoan(int i) {
    if (ketThucSom) {
      return i < demHienTai
          ? AppColors.primaryColor
          : AppColors.accent.withValues(alpha: 0.35);
    }
    if (i < demHienTai - 1) return AppColors.primaryColor;
    if (i == demHienTai - 1) return AppColors.accent;
    return AppColors.cardMint;
  }
}

class _Doan extends StatelessWidget {
  const _Doan({required this.mau});

  final Color mau;

  @override
  Widget build(BuildContext context) => Container(
    height: _doanDem,
    decoration: BoxDecoration(
      color: mau,
      borderRadius: BorderRadius.circular(_doanDem / 2),
    ),
  );
}

// Lời dặn của chủ nuôi kèm phần gõ thêm lúc nhận bé
class BoardingOwnerNote extends StatelessWidget {
  const BoardingOwnerNote({
    super.key,
    required this.ghiChuDon,
    this.ghiChuLucNhanBe,
  });

  final String ghiChuDon;
  final String? ghiChuLucNhanBe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.ghiChuCuaChuNuoi, style: AppTextStyles.captionSm),
          const SizedBox(height: 4),
          Text(ghiChuDon, style: AppTextStyles.label),
          if (ghiChuLucNhanBe case final them? when them.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.ghiChuThemLucNhanBe, style: AppTextStyles.captionSm),
            const SizedBox(height: 4),
            Text(them, style: AppTextStyles.label),
          ],
        ],
      ),
    );
  }
}

// Album hai đầu bàn giao, bốn nhóm đứng riêng để dễ tra
class BoardingHandoverAlbum extends StatelessWidget {
  const BoardingHandoverAlbum({super.key, required this.ky});

  final ThongTinTrongGiu ky;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nhom = [
      (l10n.anhLucNhanBe, ky.anhBeNhan),
      (l10n.doDungLucNhan, ky.anhDoDungNhan),
      (l10n.anhLucTraBe, ky.anhBeTra),
      (l10n.doDungLucTra, ky.anhDoDungTra),
    ].where((n) => n.$2.isNotEmpty).toList();
    if (nhom.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.albumBanGiao, style: AppTextStyles.h3),
        for (final (tieuDe, anh) in nhom) ...[
          const SizedBox(height: 12),
          Text(
            '$tieuDe · ${l10n.nAnh('${anh.length}')}',
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: 8),
          ViPhotoRow(anh: anh),
        ],
      ],
    );
  }
}

class BoardingUpdateBlock extends StatelessWidget {
  const BoardingUpdateBlock({
    super.key,
    required this.don,
    required this.onNhatKy,
    this.onGuiCapNhat,
    this.onMoManTrong,
  });

  final SitterOrderDetail don;

  final VoidCallback onNhatKy;

  final VoidCallback? onGuiCapNhat;
  final VoidCallback? onMoManTrong;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SessionPhotoLog(
          anh: don.anhNhatKy,
          tong: don.tongAnhNhatKy,
          tieuDe: l10n.capNhatChoChuNuoi,
          nhanXemTatCa: l10n.nhatKyNAnh('${don.tongAnhNhatKy}'),
          onXemTatCa: onNhatKy,
        ),
        if (don.trongGiu?.capNhatMoiNhat case final ghiChu?) ...[
          const SizedBox(height: 12),
          Text('"$ghiChu"', style: AppTextStyles.label),
        ],
        if (don.trongGiu?.gioCapNhatMoiNhat case final gio?) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(gio, style: AppTextStyles.captionSm),
          ),
        ],
        if (onGuiCapNhat case final gui?) ...[
          const SizedBox(height: 14),
          AppButton(text: l10n.guiCapNhatMoi, height: 50, onTap: gui),
          const SizedBox(height: 12),
          Text(l10n.nhacGuiCapNhatMoiNgay, style: AppTextStyles.captionSm),
        ],
        if (onMoManTrong case final mo?) ...[
          const SizedBox(height: 14),
          InkWell(
            onTap: mo,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.moManDangTrong,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Đánh giá chủ nuôi để lại sau kỳ giữ
class BoardingReviewBlock extends StatelessWidget {
  const BoardingReviewBlock({super.key, required this.danhGia});

  final DanhGiaChuNuoi danhGia;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.danhGiaCuaChuNuoi, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  i < danhGia.sao
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 22,
                  color: AppColors.accent,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              l10n.diemVaNgay(soDiem(danhGia.diem), danhGia.ngay),
              style: AppTextStyles.captionSm,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('"${danhGia.noiDung}"', style: AppTextStyles.label),
      ],
    );
  }
}
