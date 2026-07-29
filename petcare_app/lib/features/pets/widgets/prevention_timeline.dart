import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/features/pets/widgets/dashed_border.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';

// Màu đường nối và chấm mờ của dòng thời gian, chỉ dùng ở đây
const _mauDuong = Color(0xFFC9DBD3);

// Đường nối khi mốc đã quá hạn, ăn theo tông cam của khối cảnh báo
const _duongQuaHan = Color(0xFFE2CCC0);

// Dòng thời gian của một hạng mục: mốc hẹn kế tiếp ở trên cùng, rồi tới các
// lần đã làm xếp từ mới đến cũ
class PreventionTimeline extends StatelessWidget {
  const PreventionTimeline({
    super.key,
    required this.hangMuc,
    required this.onChonLan,
  });

  final PreventionRecord hangMuc;
  final ValueChanged<PreventionDose> onChonLan;

  // Bề rộng cột chấm và đường nối
  static const double _rongRay = 22;

  @override
  Widget build(BuildContext context) {
    final cacLan = [...hangMuc.lanThucHien]
      ..sort((a, b) => b.ngay.compareTo(a.ngay));
    final coHen = hangMuc.ngayNhacLai != null;
    return Column(
      children: [
        if (coHen) _DongHen(hangMuc: hangMuc, rongRay: _rongRay),
        for (final (i, lan) in cacLan.indexed)
          _DongLan(
            lan: lan,
            laGanNhat: i == 0,
            laCuoiCung: i == cacLan.length - 1,
            rongRay: _rongRay,
            onTap: () => onChonLan(lan),
          ),
      ],
    );
  }
}

// Mốc hẹn lần kế tiếp, chưa xảy ra nên tô mint và không bấm được
class _DongHen extends StatelessWidget {
  const _DongHen({required this.hangMuc, required this.rongRay});

  final PreventionRecord hangMuc;
  final double rongRay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Hạn đã trôi qua thì cả mốc chuyển sang tông cam để chủ nuôi thấy ngay
    final quaHan = hangMuc.trangThai == PreventionStatus.quaHan;
    final mauNhanManh = quaHan ? AppColors.accent : AppColors.primaryColor;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Ray(
            rongRay: rongRay,
            chamRong: 14,
            mauCham: mauNhanManh,
            mauDuong: quaHan ? _duongQuaHan : _mauDuong,
            // Mốc chưa xảy ra nên chấm để rỗng, viền đứt
            chamDut: true,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.itemGap),
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: quaHan ? nenCanhBao : AppColors.cardMint,
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ngayThangNam(hangMuc.ngayNhacLai!),
                          style: AppTextStyles.h3.copyWith(color: mauNhanManh),
                        ),
                      ),
                      AppStatusBadge(
                        label: preventionRemainLabel(context, hangMuc),
                        background: mauNhanManh,
                        textColor: AppColors.textWhite,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.textGap),
                  Text(
                    quaHan
                        ? l10n.moTaMocQuaHan
                        : l10n.moTaLanKeTiep(
                            ngayThangNam(hangMuc.lanGanNhat!.ngay),
                            preventionCycleLabel(
                              context,
                              hangMuc.lanGanNhat!.chuKy!,
                            ),
                          ),
                    style: AppTextStyles.captionSm,
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

// Một lần đã làm; chạm vào để sửa hoặc xoá riêng lần đó
class _DongLan extends StatelessWidget {
  const _DongLan({
    required this.lan,
    required this.laGanNhat,
    required this.laCuoiCung,
    required this.rongRay,
    required this.onTap,
  });

  final PreventionDose lan;
  final bool laGanNhat;
  final bool laCuoiCung;
  final double rongRay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Ray(
            rongRay: rongRay,
            chamRong: laGanNhat ? 14 : 11,
            mauCham: laGanNhat ? AppColors.primaryColor : _mauDuong,
            veDuong: !laCuoiCung,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                bottom: laCuoiCung ? 0 : AppSpacing.itemGap,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.neutralLight),
                borderRadius: BorderRadius.circular(AppRadius.radius14),
              ),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ngayThangNam(lan.ngay),
                            style: AppTextStyles.label,
                          ),
                          if (laGanNhat) ...[
                            const SizedBox(width: AppSpacing.labelGap),
                            AppStatusBadge(
                              label: l10n.nhanLanGanNhat,
                              background: AppColors.cardMint,
                              textColor: AppColors.primaryColor,
                            ),
                          ],
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      if (lan.noiThucHien case final noi?) ...[
                        const SizedBox(height: AppSpacing.textGap),
                        Text(noi, style: AppTextStyles.captionSm),
                      ],
                      const SizedBox(height: AppSpacing.textGap),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lan.chuKy == null
                                  ? l10n.khongDatNhacLai
                                  : l10n.henNhacLaiSau(
                                      preventionCycleLabel(context, lan.chuKy!),
                                    ),
                              style: AppTextStyles.captionSm,
                            ),
                          ),
                          if (lan.anh.isNotEmpty) ...[
                            const Icon(
                              Icons.attach_file,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.textGap),
                            Text(
                              '${lan.anh.length}',
                              style: AppTextStyles.captionSm,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cột chấm và đường nối bên trái mỗi dòng
class _Ray extends StatelessWidget {
  const _Ray({
    required this.rongRay,
    required this.chamRong,
    required this.mauCham,
    this.mauDuong = _mauDuong,
    this.veDuong = true,
    this.chamDut = false,
  });

  final double rongRay;
  final double chamRong;
  final Color mauCham;
  final Color mauDuong;
  final bool veDuong;

  // Chấm rỗng viền đứt, dành cho mốc hẹn chưa xảy ra
  final bool chamDut;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: rongRay,
      child: Column(
        children: [
          if (chamDut)
            CustomPaint(
              size: Size.square(chamRong),
              painter: DashedBorderPainter(
                boGoc: chamRong / 2,
                mau: mauCham,
                doDay: 1.4,
                net: 3,
                ho: 3,
              ),
            )
          else
            Container(
              width: chamRong,
              height: chamRong,
              decoration: BoxDecoration(color: mauCham, shape: BoxShape.circle),
            ),
          if (veDuong)
            Expanded(
              child: SizedBox(width: 2, child: ColoredBox(color: mauDuong)),
            ),
        ],
      ),
    );
  }
}
