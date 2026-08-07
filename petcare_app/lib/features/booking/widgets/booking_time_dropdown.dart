import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/shared/widgets/expand_select_box.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/widgets/booking_time_row.dart';

const double _caoDanhSach = 268;

// Ô chọn giờ
class BookingTimeDropdown extends StatefulWidget {
  const BookingTimeDropdown({
    super.key,
    required this.khung,
    required this.chon,
    required this.onChon,
    required this.moTaChon,
    this.thoiLuongPhut,
    this.chuThichDong,
    this.nhanChuaChon,
  });

  final List<KhungGio> khung;
  final KhungGio? chon;
  final void Function(KhungGio khung) onChon;

  final String? nhanChuaChon;

  final String Function(KhungGio khung) moTaChon;

  final String Function(KhungGio khung)? chuThichDong;

  final int? thoiLuongPhut;

  @override
  State<BookingTimeDropdown> createState() => _BookingTimeDropdownState();
}

class _BookingTimeDropdownState extends State<BookingTimeDropdown> {
  final _cuon = ScrollController();
  bool _mo = false;

  @override
  void dispose() {
    _cuon.dispose();
    super.dispose();
  }

  void _doiTrangThai() {
    setState(() => _mo = !_mo);
    if (!_mo) return;
    final i = widget.khung.indexWhere((k) => k.nhan == widget.chon?.nhan);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (i >= 0 && _cuon.hasClients) {
        _cuon.jumpTo(
          (i * caoDongGio - _caoDanhSach / 2 + caoDongGio).clamp(
            0,
            _cuon.position.maxScrollExtent,
          ),
        );
      }
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chon = widget.chon;
    return ExpandSelectBox(
      dangMo: _mo,
      onMoDong: _doiTrangThai,
      mauVien: _mo ? AppColors.primaryColor : AppColors.neutral,
      doDayVien: 1,
      dong: Row(
        children: [
          const Icon(Icons.schedule, size: 18, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chon?.nhan ?? widget.nhanChuaChon ?? l10n.chonGioBatDau,
                  style: AppTextStyles.label,
                ),
                if (chon != null) ...[
                  const SizedBox(height: 2),
                  Text(widget.moTaChon(chon), style: AppTextStyles.captionSm),
                ],
              ],
            ),
          ),
        ],
      ),
      danhSach: SizedBox(
        height: _caoDanhSach,
        child: Scrollbar(
          controller: _cuon,
          thumbVisibility: true,
          child: ListView.builder(
            controller: _cuon,
            padding: EdgeInsets.zero,
            itemCount: widget.khung.length,
            itemExtent: caoDongGio,
            itemBuilder: (_, i) {
              final k = widget.khung[i];
              return BookingTimeRow(
                khung: k,
                dangChon: k.nhan == chon?.nhan,
                thoiLuongPhut: widget.thoiLuongPhut,
                chuThichPhai: widget.chuThichDong?.call(k),
                onTap: () {
                  widget.onChon(k);
                  setState(() => _mo = false);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
