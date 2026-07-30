import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/service_summary.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Mục Dịch vụ và giá
class SitterProfileServices extends StatefulWidget {
  const SitterProfileServices({super.key, required this.services});

  final SitterServices? services;

  @override
  State<SitterProfileServices> createState() => _SitterProfileServicesState();
}

class _SitterProfileServicesState extends State<SitterProfileServices> {
  ServiceType? _mo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = widget.services;
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
              Flexible(
                child: Text(
                  l10n.chamXemGoiVaChinhSach,
                  style: AppTextStyles.captionSm,
                  textAlign: TextAlign.end,
                ),
              ),
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
                child: AppDongKe(),
              ),
            _Dong(
              tt: _thongTinDichVu(context, s!, t),
              mo: _mo == t,
              onTap: () => setState(() => _mo = _mo == t ? null : t),
            ),
            if (_mo == t) ...[
              const SizedBox(height: 12),
              _KhoiChiTiet(dong: _chiTietGia(context, s, t)),
            ],
          ],
      ],
    );
  }
}

typedef _TTDichVu = ({String ten, String phu, String gia, String donVi});
typedef _DongGia = ({String nhan, String giaTri, bool nhanManh});

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
        phu: [
          _loaiThu(c, w.petKind),
          l10n.nPhut(walkingDurations.join('/')),
          l10n.toiDaNBe('${w.maxPets ?? 1}'),
        ].join(' · '),
        gia: l10n.tuGiaTien(dinhDangTien(w.lowestPrice ?? 0)),
        donVi: l10n.moiLuot,
      );
    case ServiceType.boarding:
      final b = s.boarding;
      return (
        ten: serviceTypeName(c, t),
        phu:
            '${_loaiThu(c, b.petKind)} · '
            '${l10n.taiCoSoToiDa('${b.maxPets ?? 1}')}',
        gia: '${dinhDangTien(b.pricePerDay ?? 0)}đ',
        donVi: l10n.moiNgay,
      );
    case ServiceType.grooming:
      final g = s.grooming;
      return (
        ten: serviceTypeName(c, t),
        phu: '${_loaiThu(c, g.petKind)} · ${l10n.taiNhaTheoCan}',
        gia: l10n.tuGiaTien(dinhDangTien(g.lowestPrice ?? 0)),
        donVi: l10n.moiBe,
      );
  }
}

// Bảng giá đầy đủ của một loại
List<_DongGia> _chiTietGia(BuildContext c, SitterServices s, ServiceType t) {
  final l10n = c.l10n;
  final dong = <_DongGia>[];
  switch (t) {
    case ServiceType.walking:
      final w = s.walking;
      for (final phut in walkingDurations) {
        final gia = w.priceByDuration[phut];
        if (gia == null) continue;
        dong.add((
          nhan: l10n.goiNPhut('$phut'),
          giaTri: '${dinhDangTien(gia)}đ',
          nhanManh: true,
        ));
      }
      dong.add((
        nhan: l10n.soBeToiDa,
        giaTri: l10n.soBe('${w.maxPets ?? 1}'),
        nhanManh: false,
      ));
      dong.add((
        nhan: l10n.phuPhiBeThem,
        giaTri: w.additionalPetFee == null
            ? l10n.khongCo
            : l10n.congGiaMoiBe(dinhDangTien(w.additionalPetFee!)),
        nhanManh: false,
      ));
    case ServiceType.boarding:
      final b = s.boarding;
      dong.add((
        nhan: l10n.trongTaiCoSoMoiNgay,
        giaTri: '${dinhDangTien(b.pricePerDay ?? 0)}đ',
        nhanManh: true,
      ));
      dong.add((
        nhan: l10n.soBeToiDa,
        giaTri: l10n.soBe('${b.maxPets ?? 1}'),
        nhanManh: false,
      ));
      dong.add((
        nhan: l10n.phuPhiBeThem,
        giaTri: b.additionalPetFee == null
            ? l10n.khongCo
            : l10n.congGiaMoiBeMoiNgay(dinhDangTien(b.additionalPetFee!)),
        nhanManh: false,
      ));
    case ServiceType.grooming:
      final g = s.grooming;
      for (final goi in GroomingPackage.values) {
        final bang = g.priceByPackage[goi];
        if (bang == null) continue;
        for (final muc in WeightTier.values) {
          final gia = bang[muc];
          if (gia == null) continue;
          final phut = g.phutCua(goi, muc);
          dong.add((
            nhan:
                '${groomingPackageName(c, goi)} · '
                '${weightTierLabel(c, muc).toLowerCase()}',
            giaTri: phut == null
                ? '${dinhDangTien(gia)}đ'
                : '${dinhDangTien(gia)}đ · ${l10n.nPhut('$phut')}',
            nhanManh: true,
          ));
        }
      }
      dong.add((
        nhan: l10n.soBeToiDa,
        giaTri: l10n.soBe('${g.maxPets ?? 1}'),
        nhanManh: false,
      ));
      // Grooming cộng giá từng bé nên không có phụ phí bé thêm
      dong.add((
        nhan: l10n.phuPhiBeThem,
        giaTri: l10n.khongCoTinhRiengTungBe,
        nhanManh: false,
      ));
  }
  return dong;
}

class _Dong extends StatelessWidget {
  const _Dong({required this.tt, required this.mo, required this.onTap});

  final _TTDichVu tt;
  final bool mo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tt.ten, style: AppTextStyles.label),
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
          Icon(
            mo
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 22,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

// Bảng giá mở rộng của một loại dịch vụ
class _KhoiChiTiet extends StatelessWidget {
  const _KhoiChiTiet({required this.dong});

  final List<_DongGia> dong;

  @override
  Widget build(BuildContext context) {
    final soNhanManh = dong.where((d) => d.nhanManh).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Column(
        children: [
          for (final (i, d) in dong.indexed) ...[
            // Vạch ngăn giữa nhóm giá và nhóm giới hạn
            if (i == soNhanManh && i != 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: AppDongKe(mau: AppColors.neutral),
              )
            else if (i != 0)
              const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    d.nhan,
                    style: d.nhanManh
                        ? AppTextStyles.label
                        : AppTextStyles.captionSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  d.giaTri,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.label.copyWith(
                    color: d.nhanManh
                        ? AppColors.primaryColor
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
