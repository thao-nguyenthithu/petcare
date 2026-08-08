import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/widgets/booking_time_dropdown.dart';

class BoardingStayTime extends StatelessWidget {
  const BoardingStayTime({
    super.key,
    required this.tenNcc,
    required this.khungDen,
    required this.khungVe,
    required this.gioDen,
    required this.gioVe,
    required this.nhanNgayDen,
    required this.nhanNgayVe,
    required this.onChonGioDen,
    required this.onChonGioVe,
  });

  final String tenNcc;

  final List<KhungGio> khungDen;
  final List<KhungGio> khungVe;
  final KhungGio? gioDen;
  final KhungGio? gioVe;
  final String? nhanNgayDen;
  final String? nhanNgayVe;

  final void Function(KhungGio khung) onChonGioDen;
  final void Function(KhungGio khung) onChonGioVe;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chuaCoNgay = nhanNgayDen == null || nhanNgayVe == null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.gioMangDenVaDonVe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        if (chuaCoNgay)
          Text(
            l10n.loiChonKhoangNgayTruoc,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
          )
        else ...[
          _Moc(
            nhan: l10n.mangBeDen,
            nhanChuaChon: l10n.chonGioMangDen,
            ngay: nhanNgayDen!,
            khung: khungDen,
            chon: gioDen,
            onChon: onChonGioDen,
          ),
          const SizedBox(height: 16),
          _Moc(
            nhan: l10n.donBeVe,
            nhanChuaChon: l10n.chonGioDonVe,
            ngay: nhanNgayVe!,
            khung: khungVe,
            chon: gioVe,
            onChon: onChonGioVe,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.ghiChuKhungGioTrongGiu(
              tenNcc,
              '${gioMoMacDinh.toString().padLeft(2, '0')}:00',
              '${gioDongMacDinh.toString().padLeft(2, '0')}:00',
            ),
            style: AppTextStyles.captionSm,
          ),
        ],
      ],
    );
  }
}

class _Moc extends StatelessWidget {
  const _Moc({
    required this.nhan,
    required this.nhanChuaChon,
    required this.ngay,
    required this.khung,
    required this.chon,
    required this.onChon,
  });

  final String nhan;
  final String nhanChuaChon;
  final String ngay;
  final List<KhungGio> khung;
  final KhungGio? chon;
  final void Function(KhungGio khung) onChon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$nhan · $ngay', style: AppTextStyles.captionSm),
        const SizedBox(height: 8),
        BookingTimeDropdown(
          khung: khung,
          chon: chon,
          moTaChon: (_) => nhan,
          onChon: onChon,
        ),
      ],
    );
  }
}
