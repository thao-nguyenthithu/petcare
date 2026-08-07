import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Cụm nút đáy màn chi tiết đơn
class SitterOrderBottomBar extends StatelessWidget {
  const SitterOrderBottomBar({
    super.key,
    required this.don,
    required this.daCamKet,
    required this.onChapNhan,
    required this.onTuChoi,
    required this.onXuatPhat,
    required this.onDaToi,
    required this.onKetThuc,
    required this.onNhanBe,
    required this.onBaoVangMat,
    required this.onNhanTin,
    required this.onBaoMuon,
    required this.onBoDon,
    required this.onXemDonCho,
    required this.onVeDanhSach,
    this.onXemVi,
    this.onBaoSuCo,
  });

  final SitterOrderDetail don;
  final bool daCamKet;
  final VoidCallback onChapNhan;
  final VoidCallback onTuChoi;
  final VoidCallback onXuatPhat;
  final VoidCallback onDaToi;

  final VoidCallback onKetThuc;
  final VoidCallback onNhanBe;
  final VoidCallback onBaoVangMat;
  final VoidCallback onNhanTin;
  final VoidCallback onBaoMuon;
  final VoidCallback onBoDon;

  final VoidCallback onXemDonCho;
  final VoidCallback onVeDanhSach;
  final VoidCallback? onXemVi;
  final VoidCallback? onBaoSuCo;

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
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _nut(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _nut(BuildContext context) {
    final l10n = context.l10n;
    if (don.daBoDangDo) return _nutDaKhep(context);
    if (don.laTrongGiu && don.tinhTrang != TinhTrangDonNcc.choXacNhan) {
      return _nutTrongGiu(context);
    }
    return switch (don.tinhTrang) {
      TinhTrangDonNcc.choXacNhan => [
        AppButton(
          text: l10n.chapNhanDon,
          height: 50,
          enabled: !don.canCamKetAnToan || daCamKet,
          onTap: onChapNhan,
        ),
        const SizedBox(height: 6),
        AppButton(
          text: l10n.tuChoiDon,
          flat: true,
          height: 50,
          color: AppColors.textSecondary,
          onTap: onTuChoi,
        ),
      ],
      TinhTrangDonNcc.choChuNuoiXacNhan => [
        AppButton(
          text: l10n.nhanChoChuNuoi,
          outlined: true,
          height: 50,
          onTap: onNhanTin,
        ),
      ],
      TinhTrangDonNcc.dangDat =>
        don.laGrooming
            ? [
                AppButton(
                  text: l10n.ketThucDichVu,
                  height: 50,
                  color: AppColors.accent,
                  onTap: onKetThuc,
                ),
              ]
            : [
                AppButton(
                  text: don.duGioKetThuc
                      ? l10n.ketThucDichVu
                      : l10n.ketThucDichVuMoLuc(don.gioMoKetThuc ?? ''),
                  height: 50,
                  enabled: don.duGioKetThuc,
                  onTap: onKetThuc,
                ),
                const SizedBox(height: 6),
                AppButton(
                  text: l10n.nhanTinVaBaoSuCo,
                  flat: true,
                  height: 50,
                  color: AppColors.textSecondary,
                  onTap: onNhanTin,
                ),
              ],
      TinhTrangDonNcc.daToiDiemDon => [
        AppButton(
          text: don.moBatDau
              ? (don.laGrooming ? l10n.batDau : l10n.nhanBeVaChupAnhCheckIn)
              : l10n.batDauMoLuc(don.gioMoBatDau ?? ''),
          height: 50,
          enabled: don.moBatDau,
          onTap: onNhanBe,
        ),
        const SizedBox(height: 6),
        AppButton(
          text: don.gioMoBaoVangMat == null
              ? l10n.chuNuoiKhongCoMat
              : l10n.chuNuoiKhongCoMatMoLuc(don.gioMoBaoVangMat!),
          outlined: true,
          height: 50,
          mauChu: AppColors.textSecondary,
          enabled: don.gioMoBaoVangMat == null,
          onTap: onBaoVangMat,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LienKet(nhan: l10n.nhanTin, onTap: onNhanTin),
            const _Cham(),
            _LienKet(nhan: l10n.khongTheTiepNhan, onTap: onBoDon),
          ],
        ),
      ],
      _ => [
        if (!don.daXuatPhat)
          AppButton(
            text: don.moXuatPhat
                ? l10n.xuatPhat
                : l10n.xuatPhatMoLuc(don.gioMoXuatPhat ?? ''),
            height: 50,
            enabled: don.moXuatPhat,
            onTap: onXuatPhat,
          )
        else
          AppButton(text: l10n.daToiNoi, height: 50, onTap: onDaToi),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (don.daMoDiaChi) ...[
              _LienKet(
                nhan: don.daBaoMuon ? l10n.daBaoDenMuon : l10n.toiDenMuon,
                onTap: don.daBaoMuon ? null : onBaoMuon,
              ),
              const _Cham(),
            ],
            _LienKet(
              nhan: don.daXuatPhat ? l10n.khongTheTiepNhan : l10n.huyDon,
              onTap: onBoDon,
            ),
          ],
        ),
      ],
    };
  }

  // Đơn đã khép thì chỉ còn hai lối đi tiếp
  List<Widget> _nutDaKhep(BuildContext context) {
    final l10n = context.l10n;
    return [
      AppButton(text: l10n.xemDonDangCho, height: 50, onTap: onXemDonCho),
      const SizedBox(height: 6),
      AppButton(
        text: l10n.veDanhSachDon,
        flat: true,
        height: 50,
        color: AppColors.textSecondary,
        onTap: onVeDanhSach,
      ),
    ];
  }

  // Kỳ trông giữ chỉ bấm hai lần: nhận bé và trả bé
  List<Widget> _nutTrongGiu(BuildContext context) {
    final l10n = context.l10n;
    final ky = don.trongGiu;
    // Chỉ ngày cuối mới mở nút trả bé
    final moTraBe = (ky?.demHienTai ?? 0) >= (ky?.soDem ?? 0);
    return switch (don.tinhTrang) {
      TinhTrangDonNcc.hoanThanh => [
        AppButton(
          text: l10n.xemViVaThuNhap,
          height: 50,
          onTap: onXemVi ?? onNhanTin,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LienKet(
              nhan: ky?.gioConBaoSuCo == null
                  ? l10n.baoSuCo
                  : l10n.baoSuCoConNGio('${ky!.gioConBaoSuCo}'),
              onTap: onBaoSuCo,
            ),
          ],
        ),
      ],
      // Chỉ còn việc trả bé, nút khoá tới ngày trả đã hẹn
      TinhTrangDonNcc.dangDat => [
        AppButton(
          text: moTraBe
              ? l10n.traBeVaChupAnh
              : l10n.traBeVaChupAnhMoNgay(ky?.ngayTraNgan ?? ''),
          height: 50,
          enabled: moTraBe,
          onTap: onKetThuc,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_LienKet(nhan: l10n.baoSuCo, onTap: onBaoSuCo)],
        ),
      ],
      TinhTrangDonNcc.quaHenNhanBe => [
        AppButton(
          text: l10n.nhanBeVaChupAnhMoKhiChuNuoiToi,
          height: 50,
          enabled: false,
          onTap: onNhanBe,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LienKet(
              nhan: l10n.chuNuoiChuaMangBeToi,
              mau: AppColors.accent,
              onTap: onBaoVangMat,
            ),
          ],
        ),
      ],
      _ => [
        AppButton(
          text: don.tinhTrang == TinhTrangDonNcc.daNhanDon
              ? l10n.nhanBeMoKhiChuNuoiToi
              : l10n.nhanBeVaChupAnhMoKhiChuNuoiToi,
          height: 50,
          enabled: false,
          onTap: onNhanBe,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_LienKet(nhan: l10n.huyDon, onTap: onBoDon)],
        ),
      ],
    };
  }
}

// Dấu chấm ngăn hai liên kết
class _Cham extends StatelessWidget {
  const _Cham();

  @override
  Widget build(BuildContext context) =>
      Text('·', style: AppTextStyles.captionSm);
}

class _LienKet extends StatelessWidget {
  const _LienKet({required this.nhan, required this.onTap, this.mau});

  final String nhan;
  final VoidCallback? onTap;
  final Color? mau;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        nhan,
        style: AppTextStyles.captionSm.copyWith(
          color: mau ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}
