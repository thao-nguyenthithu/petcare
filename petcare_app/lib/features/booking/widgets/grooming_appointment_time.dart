import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/widgets/booking_time_dropdown.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

typedef DongThoiLuong = ({String nhan, int phut});

// Mục chọn giờ hẹn của dịch vụ tắm và cắt tỉa, kèm khoảng tới và dự kiến xong
class GroomingAppointmentTime extends StatelessWidget {
  const GroomingAppointmentTime({
    super.key,
    required this.tenNcc,
    required this.nhanNgay,
    required this.khung,
    required this.chon,
    required this.dong,
    required this.onChon,
  });

  final String tenNcc;
  final String? nhanNgay;
  final List<KhungGio> khung;
  final KhungGio? chon;
  final List<DongThoiLuong> dong;
  final void Function(KhungGio khung) onChon;

  int get _tongPhut => dong.fold(0, (t, d) => t + d.phut);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final daChon = chon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nhanNgay == null
              ? l10n.gioBatDauLabel
              : '${l10n.gioBatDauLabel} · $nhanNgay',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 8),
        Text(l10n.ghiChuKhungGioHen, style: AppTextStyles.captionSm),
        const SizedBox(height: 14),
        if (nhanNgay == null)
          AppNoteBox(text: l10n.chonNgayTruocDeXemGio)
        else ...[
          BookingTimeDropdown(
            khung: khung,
            chon: chon,
            thoiLuongPhut: _tongPhut,
            moTaChon: (_) => l10n.nguoiChamToiQuanhGioNay,
            onChon: onChon,
          ),
          if (daChon != null) ...[
            const SizedBox(height: 20),
            Text(
              l10n.duKienXongKhoang(gioKetThuc(daChon, _tongPhut)),
              style: AppTextStyles.button.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            for (final d in dong)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(d.nhan, style: AppTextStyles.captionSm),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.nPhut('${d.phut}'), style: AppTextStyles.label),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              l10n.tongPhutTheoThoiLuong('$_tongPhut', tenNcc),
              style: AppTextStyles.captionSm,
            ),
          ],
          const SizedBox(height: 16),
          AppNoteBox(text: l10n.ghiChuLeadTimeNGio('${minLeadMinutes ~/ 60}')),
        ],
      ],
    );
  }
}
