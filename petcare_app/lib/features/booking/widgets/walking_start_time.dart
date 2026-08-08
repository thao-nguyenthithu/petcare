import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/widgets/booking_time_dropdown.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

// Mục chọn giờ bắt đầu của dịch vụ dắt đi dạo
class WalkingStartTime extends StatelessWidget {
  const WalkingStartTime({
    super.key,
    required this.tenNcc,
    required this.nhanNgay,
    required this.khung,
    required this.chon,
    required this.thoiLuongPhut,
    required this.onChon,
  });

  final String tenNcc;

  // Ngày đã chọn dạng chữ, bỏ trống là chưa chọn ngày
  final String? nhanNgay;
  final List<KhungGio> khung;
  final KhungGio? chon;
  final int thoiLuongPhut;
  final void Function(KhungGio khung) onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        Text(l10n.ghiChuKhungGio30Phut(tenNcc), style: AppTextStyles.captionSm),
        const SizedBox(height: 14),
        if (nhanNgay == null)
          AppNoteBox(text: l10n.chonNgayTruocDeXemGio)
        else ...[
          BookingTimeDropdown(
            khung: khung,
            chon: chon,
            thoiLuongPhut: thoiLuongPhut,
            moTaChon: (k) =>
                '${l10n.ketThucGio(gioKetThuc(k, thoiLuongPhut))}'
                ' · ${l10n.goiNPhut('$thoiLuongPhut')}',
            chuThichDong: (k) => l10n.ketThucGio(gioKetThuc(k, thoiLuongPhut)),
            onChon: onChon,
          ),
          const SizedBox(height: 12),
          AppNoteBox(text: l10n.ghiChuLeadTimeNGio('${minLeadMinutes ~/ 60}')),
        ],
      ],
    );
  }
}
