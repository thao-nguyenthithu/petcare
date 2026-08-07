import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/widgets/no_show_contest_box.dart';
import 'package:petcare_app/shared/widgets/booking_detail_hero.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

// Đơn đã huỷ thay hoá đơn bằng tiền hoàn và lối đặt lại
class CancelledBookingBody extends StatelessWidget {
  const CancelledBookingBody({
    super.key,
    required this.don,
    required this.onXemBe,
    required this.onXemThem,
    required this.onChonNcc,
  });

  final OwnerBookingDetail don;
  final VoidCallback onXemBe;
  final VoidCallback onXemThem;
  final void Function(GoiYNcc ncc) onChonNcc;

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
        if (don.thongTinHuy?.ben == BenHuy.chuNuoiVangMat) ...[
          const FlatDivider(),
          FlatSection(child: NoShowContestBox(don: don)),
        ],
        const FlatDivider(),
        FlatSection(child: _PhiVaHoanTien(don: don)),
        const FlatDivider(),
        FlatSection(child: _ThongTinDonDaHuy(don: don)),
        if (don.goiYNcc.isNotEmpty) ...[
          const FlatDivider(),
          FlatSection(
            child: _GoiYNccKhac(
              don: don,
              onXemThem: onXemThem,
              onChon: onChonNcc,
            ),
          ),
        ],
      ],
    );
  }
}

class _KhoiDaHuy extends StatelessWidget {
  const _KhoiDaHuy({required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final huy = don.thongTinHuy;
    if (huy == null) return const SizedBox.shrink();
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
                _tieuDe(context, huy),
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 6),
              Text(_moTa(context, huy), style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }

  String _tieuDe(BuildContext context, ThongTinHuy huy) {
    final l10n = context.l10n;
    return switch (huy.ben) {
      BenHuy.chuNuoi => l10n.banDaHuyLuc(huy.gioHuy, huy.ngayHuy),
      BenHuy.nguoiCham => l10n.nccDaHuyLuc(huy.gioHuy, huy.ngayHuy),
      // Mốc ở đây chỉ là lúc đơn khép lại nên không đưa lên dòng đầu
      BenHuy.nccChuaToi || BenHuy.heThongNccChuaToi => l10n.nccKhongToiDiemDon,
      BenHuy.heThongKhongBatDau => l10n.donHuyViQuaGioHen,
      BenHuy.heThongHetHan => l10n.donHetHanNhanLuc(huy.gioHuy, huy.ngayHuy),
      // Chủ nuôi cần biết vì sao mất chỗ, mốc giờ không nói lên điều gì
      BenHuy.heThongNccBan => l10n.nguoiChamDaBanKhungNay,
      BenHuy.chuNuoiVangMat => l10n.khongCoMatOGioHen,
      BenHuy.quanTri => l10n.quanTriDaHuyNhan,
    };
  }

  String _moTa(BuildContext context, ThongTinHuy huy) {
    final l10n = context.l10n;
    return switch (huy.ben) {
      BenHuy.nguoiCham => l10n.lyDoNganGon(huy.lyDo),
      BenHuy.nccChuaToi => l10n.moTaHuyNccChuaToi,
      BenHuy.heThongNccChuaToi => l10n.moTaHeThongHuyNccChuaToi,
      BenHuy.heThongKhongBatDau => l10n.moTaHuyKhongAiBatDau,
      BenHuy.heThongHetHan => l10n.moTaTuHuyHetHan,
      BenHuy.heThongNccBan => l10n.moTaTuHuyNccBan,
      BenHuy.chuNuoiVangMat => l10n.banBiBaoVangMat,
      BenHuy.quanTri => l10n.moTaQuanTriHuyChuNuoi,
      BenHuy.chuNuoi =>
        huy.phiHuy == 0
            ? l10n.lyDoHuyKhongMatPhi(huy.lyDo)
            : l10n.lyDoHuyMatPhi(huy.lyDo, '${don.phanTramPhiHuy}'),
    };
  }
}

class _PhiVaHoanTien extends StatelessWidget {
  const _PhiVaHoanTien({required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phi = don.thongTinHuy?.phiHuy ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.phiVaHoanTien, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        _HangTien(nhan: l10n.giaCuaDon, tien: don.tongTien),
        const SizedBox(height: 10),
        _HangTien(
          nhan: phi == 0
              ? l10n.phiHuy
              : l10n.phiHuyPhanTram('${phi * 100 ~/ don.tongTien}'),
          tien: phi,
          mau: phi == 0 ? null : AppColors.accent,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text(l10n.hoanVeVnpay, style: AppTextStyles.h3)),
            Text(
              '${dinhDangTien(don.tienHoanLai)}đ',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.credit_card,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.hoanTienVeTaiKhoan,
                style: AppTextStyles.captionSm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HangTien extends StatelessWidget {
  const _HangTien({required this.nhan, required this.tien, this.mau});

  final String nhan;
  final int tien;
  final Color? mau;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
        Text(
          '${dinhDangTien(tien)}đ',
          style: AppTextStyles.label.copyWith(color: mau),
        ),
      ],
    );
  }
}

class _ThongTinDonDaHuy extends StatelessWidget {
  const _ThongTinDonDaHuy({required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final huy = don.thongTinHuy;
    final ben = huy?.ben;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.thongTinDonDaHuy, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        _Hang(
          icon: Icons.calendar_today_outlined,
          nhan: l10n.thoiGianDaDat,
          giaTri: [don.moTaThoiGian],
        ),
        const SizedBox(height: 16),
        _Hang(
          icon: Icons.person_outline,
          nhan: l10n.nguoiCham,
          giaTri: [
            if (ben == BenHuy.chuNuoi) ...[
              don.tenNcc,
              if (huy != null) l10n.banHuyTruocGioHen(huy.truocGioHen),
            ] else if (ben == BenHuy.nguoiCham)
              l10n.nccHuyTruocGioHen(don.tenNcc, huy?.truocGioHen ?? '')
            else
              don.tenNcc,
          ],
        ),
      ],
    );
  }
}

class _Hang extends StatelessWidget {
  const _Hang({required this.icon, required this.nhan, required this.giaTri});

  final IconData icon;
  final String nhan;
  final List<String> giaTri;

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
              for (final g in giaTri) Text(g, style: AppTextStyles.label),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoiYNccKhac extends StatelessWidget {
  const _GoiYNccKhac({
    required this.don,
    required this.onXemThem,
    required this.onChon,
  });

  final OwnerBookingDetail don;
  final VoidCallback onXemThem;
  final void Function(GoiYNcc ncc) onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ben = don.thongTinHuy?.ben;
    final nccHuy =
        ben == BenHuy.nguoiCham ||
        ben == BenHuy.nccChuaToi ||
        ben == BenHuy.heThongNccChuaToi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  nccHuy ? l10n.nccKhacRanhKhungNay : l10n.datVoiNccKhac,
                  maxLines: 1,
                  softWrap: false,
                  style: AppTextStyles.h3,
                ),
              ),
            ),
            InkWell(
              onTap: onXemThem,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
                child: Row(
                  children: [
                    Text(
                      l10n.xemThem,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final ncc in don.goiYNcc)
          InkWell(
            onTap: () => onChon(ncc),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  PetAvatar(imageUrl: ncc.avatar, name: ncc.ten, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ncc.ten, style: AppTextStyles.label),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.honey,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${ncc.rating} (${ncc.soDanhGia}) · '
                              '${l10n.cachSoKm(l10n.soKm(soLeKm(ncc.km)))}',
                              style: AppTextStyles.captionSm,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.tuGiaTien(dinhDangTien(ncc.gia)),
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
