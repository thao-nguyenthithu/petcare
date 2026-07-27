import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

enum _TrangThaiBuoc { xong, hienTai, chuaToi }

// Checklist trang thiết lập dịch vụ khi NCC chưa đủ điều kiện nhận đơn
class OnboardingChecklist extends StatelessWidget {
  const OnboardingChecklist({
    super.key,
    required this.coKhuVuc,
    required this.coDichVu,
    required this.onThietLap,
    required this.onHoanTat,
    required this.onVeChuNuoi,
  });

  final bool coKhuVuc;
  final bool coDichVu;
  final VoidCallback onThietLap;
  final VoidCallback onHoanTat;
  final VoidCallback onVeChuNuoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final xong = [coKhuVuc, coDichVu];
    final tieuDe = [l10n.buocDatKhuVuc, l10n.buocThietLapDichVu];
    final xongHet = coKhuVuc && coDichVu;
    final buocHienTai = xong.indexWhere((e) => !e);

    _TrangThaiBuoc trangThai(int i) {
      if (xong[i]) return _TrangThaiBuoc.xong;
      if (i == buocHienTai) return _TrangThaiBuoc.hienTai;
      return _TrangThaiBuoc.chuaToi;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.hoanTatDeNhanDon, style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(l10n.moTaHoanTat, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.groupGap),
          for (var i = 0; i < xong.length; i++)
            _BuocStep(
              so: i + 1,
              tieuDe: tieuDe[i],
              trangThai: trangThai(i),
              mauNoi: xong[i] ? AppColors.primaryColor : AppColors.neutralLight,
              laCuoi: i == xong.length - 1,
            ),
          const SizedBox(height: AppSpacing.stackGap),
          if (xongHet) ...[
            Text(
              l10n.sanSangNhanDon,
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.itemGap),
            AppButton(text: l10n.batDauNhanDon, onTap: onHoanTat),
          ] else
            AppButton(text: l10n.thietLapNgay, onTap: onThietLap),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onVeChuNuoi,
            child: Text(
              l10n.veCheDoChuNuoi,
              style: AppTextStyles.button.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuocStep extends StatelessWidget {
  const _BuocStep({
    required this.so,
    required this.tieuDe,
    required this.trangThai,
    required this.mauNoi,
    required this.laCuoi,
  });

  final int so;
  final String tieuDe;
  final _TrangThaiBuoc trangThai;
  final Color mauNoi;
  final bool laCuoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                _Node(trangThai: trangThai),
                if (!laCuoi)
                  Expanded(child: Container(width: 2, color: mauNoi)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2, bottom: laCuoi ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.buocSo('$so'),
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tieuDe,
                    style: AppTextStyles.label.copyWith(
                      color: trangThai == _TrangThaiBuoc.chuaToi
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Node tròn xong tick xanh hiện tại vòng viền xanh
class _Node extends StatelessWidget {
  const _Node({required this.trangThai});

  final _TrangThaiBuoc trangThai;

  @override
  Widget build(BuildContext context) {
    switch (trangThai) {
      case _TrangThaiBuoc.xong:
        return Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 18, color: AppColors.textWhite),
        );
      case _TrangThaiBuoc.hienTai:
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: Center(
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case _TrangThaiBuoc.chuaToi:
        return Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.neutralLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral),
          ),
        );
    }
  }
}
