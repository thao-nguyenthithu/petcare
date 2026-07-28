import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/service_summary.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

// Mục Dịch vụ và giá chỉ liệt kê loại đã cấu hình và đang bật nhận đơn
class SitterProfileServices extends StatelessWidget {
  const SitterProfileServices({super.key, required this.services});

  final SitterServices? services;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = services;
    final loai = s == null
        ? const <ServiceType>[]
        : s.configuredTypes.where(s.isEnabled).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.dichVuVaGia, style: AppTextStyles.h3),
            const Spacer(),
            if (loai.isNotEmpty)
              Text(l10n.chamXemChiTiet, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 12),
        if (loai.isEmpty)
          Text(
            l10n.chuaCoDichVu,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          for (final (i, t) in loai.indexed) ...[
            if (i != 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.neutralLight),
              ),
            _Dong(tt: _thongTinDichVu(context, s!, t)),
          ],
      ],
    );
  }
}

// Một dòng dịch vụ để hiển thị
typedef _TTDichVu = ({
  String ten,
  String loai,
  String phu,
  String gia,
  String donVi,
});

// Nhãn loài
String _loaiThu(BuildContext c, PetKind k) =>
    k == PetKind.both ? c.l10n.choVaMeo : petKindLabel(c, k);

_TTDichVu _thongTinDichVu(BuildContext c, SitterServices s, ServiceType t) {
  final l10n = c.l10n;
  switch (t) {
    case ServiceType.walking:
      final w = s.walking;
      return (
        ten: serviceTypeName(c, t),
        loai: _loaiThu(c, w.petKind),
        phu: l10n.phutMoiLuot('${w.durationMinutes}'),
        gia: '${dinhDangTien(w.price ?? 0)}đ',
        donVi: l10n.moiLuot,
      );
    case ServiceType.boarding:
      final b = s.boarding;
      return (
        ten: serviceTypeName(c, t),
        loai: _loaiThu(c, b.petKind),
        phu: l10n.taiCoSoToiDa('${b.capacity ?? 0}'),
        gia: '${dinhDangTien(b.pricePerDay ?? 0)}đ',
        donVi: l10n.moiNgay,
      );
    case ServiceType.grooming:
      final g = s.grooming;
      return (
        ten: serviceTypeName(c, t),
        loai: _loaiThu(c, g.petKind),
        phu: l10n.taiNhaTheoCan,
        gia: l10n.tuGiaTien(dinhDangTien(g.lowestPrice ?? 0)),
        donVi: l10n.moiBe,
      );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({required this.tt});

  final _TTDichVu tt;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(child: Text(tt.ten, style: AppTextStyles.label)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardMint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tt.loai,
                      style: AppTextStyles.captionSm.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                tt.phu,
                style: AppTextStyles.captionSm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              tt.gia,
              style: AppTextStyles.label.copyWith(color: AppColors.accent),
            ),
            const SizedBox(height: 2),
            Text(
              tt.donVi,
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Icon(
          Icons.chevron_right,
          size: 22,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
