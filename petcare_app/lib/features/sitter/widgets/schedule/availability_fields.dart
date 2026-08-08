import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Mốc nửa đêm cuối ngày, ô giờ đóng cửa nhận thêm giá trị này (bộ luật mục 10)
const String gioHetNgay = '24:00';

// Các ô nhập dùng chung của cụm Giờ rảnh chọn giờ và đặt số chỗ trông giữ
TimeOfDay gioTuChuoi(String gio) {
  final phan = gio.split(':');
  final gioSo = int.tryParse(phan.first) ?? 0;
  return TimeOfDay(hour: gioSo % 24, minute: int.tryParse(phan.last) ?? 0);
}

String chuoiTuGio(TimeOfDay gio) =>
    '${gio.hour.toString().padLeft(2, '0')}:'
    '${gio.minute.toString().padLeft(2, '0')}';

int _phutTuGio(String gio) {
  final phan = gio.split(':');
  return (int.tryParse(phan.first) ?? 0) * 60 + (int.tryParse(phan.last) ?? 0);
}

String _gioTuPhut(int phut) =>
    '${(phut ~/ 60).toString().padLeft(2, '0')}:'
    '${(phut % 60).toString().padLeft(2, '0')}';

// Đổi giờ mở cửa mà giờ đóng hoá ngược thì đẩy theo, khỏi bắt sửa lần lượt hai ô
String dayGioDong(String batDau, String ketThuc) {
  if (ketThuc.compareTo(batDau) > 0) return ketThuc;
  final phut = _phutTuGio(batDau) + 60;
  return phut >= 24 * 60 ? gioHetNgay : _gioTuPhut(phut);
}

// Ô chọn giờ: nhãn nhỏ trên, giờ xanh to dưới.
class TimePickField extends StatelessWidget {
  const TimePickField({
    super.key,
    required this.nhan,
    required this.gio,
    required this.onChon,
    this.laGioDong = false,
    this.sauGio,
  });

  final String nhan;
  final String gio;
  final ValueChanged<String> onChon;

  // Ô giờ đóng cửa: nửa đêm ở đây là hết ngày, không phải đầu ngày
  final bool laGioDong;

  // Chọn không sau mốc này thì trả lại ngay tại chỗ (bộ luật mục 10)
  final String? sauGio;

  Future<void> _chon(BuildContext context) async {
    final l10n = context.l10n;
    final chon = await showTimePicker(
      context: context,
      initialTime: gioTuChuoi(gio),
    );
    if (chon == null || !context.mounted) return;
    final moi = laGioDong && chon.hour == 0 && chon.minute == 0
        ? gioHetNgay
        : chuoiTuGio(chon);
    if (sauGio != null && moi.compareTo(sauGio!) <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.gioKetThucPhaiSauGioBatDau)));
      return;
    }
    onChon(moi);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: InkWell(
        onTap: () => _chon(context),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.labelGap),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.radius14),
            border: Border.all(color: AppColors.neutralLight),
          ),
          child: Column(
            children: [
              Text(nhan, style: AppTextStyles.captionSm),
              const SizedBox(height: 2),
              Text(
                gio,
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Ô đặt số chỗ trông giữ
class SlotStepperField extends StatelessWidget {
  const SlotStepperField({
    super.key,
    required this.soCho,
    required this.toiDa,
    required this.onDoi,
    required this.nhan,
    this.moTa,
    this.chiXem = false,
  });

  final int soCho;
  final int toiDa;
  final ValueChanged<int> onDoi;
  final String nhan;
  final String? moTa;
  final bool chiXem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.itemGap),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.neutralLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(nhan, style: AppTextStyles.label)),
              IconButton(
                onPressed: (!chiXem && soCho > 0)
                    ? () => onDoi(soCho - 1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primaryColor,
                visualDensity: VisualDensity.compact,
              ),
              Text(soCho.toString(), style: AppTextStyles.h3),
              IconButton(
                onPressed: (!chiXem && soCho < toiDa)
                    ? () => onDoi(soCho + 1)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primaryColor,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (moTa != null) ...[
            const SizedBox(height: AppSpacing.textGap),
            Text(moTa!, style: AppTextStyles.captionSm),
          ],
        ],
      ),
    );
  }
}
