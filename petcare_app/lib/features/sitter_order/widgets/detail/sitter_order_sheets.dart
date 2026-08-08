import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_cancel_reasons.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_action_sheet.dart';

// Từ chối đơn còn đang chờ trả lời
Future<LyDoBoDon?> showSitterRejectSheet(
  BuildContext context,
  SitterOrderDetail don,
) {
  final l10n = context.l10n;
  return showSitterOrderActionSheet(
    context,
    don: don,
    tieuDe: l10n.tuChoiDonMa(don.maDon),
    moTa: l10n.moTaTuChoiDon,
    nhanLyDo: l10n.lyDoTuChoi,
    nhom: const [(tieuDe: null, maLyDo: maLyDoTuChoiDon)],
    hintMoTa: l10n.moTaThemBatBuocKhac,
    nhanChinh: l10n.tuChoiDon,
    nhanPhu: l10n.quayLai,
    ghiChuCuoi: const _GhiChuTuChoi(),
  );
}

// Huỷ đơn đã nhận nhưng chưa bấm Xuất phát
Future<LyDoBoDon?> showSitterCancelSheet(
  BuildContext context,
  SitterOrderDetail don,
) {
  final l10n = context.l10n;
  return showSitterOrderActionSheet(
    context,
    don: don,
    tieuDe: l10n.huyDonMaDon(don.maDon),
    moTa: l10n.moTaHuyDonChuaXuatPhat,
    nhanLyDo: l10n.lyDoHuy,
    nhom: const [(tieuDe: null, maLyDo: maLyDoHuyDonNcc)],
    hintMoTa: l10n.moTaThemDeChuNuoiHieu,
    nhanChinh: l10n.huyDonVaChiuAnhHuong,
    nhanPhu: l10n.giuDon,
    anhHuong: [
      l10n.canhBaoTinhTyLeHuy('${don.tranTyLeHuy}'),
      l10n.canhBaoHuyKhongSinhCanhCao,
    ],
  );
}

// Đã bấm Xuất phát nên không còn là huỷ thường
Future<LyDoBoDon?> showSitterCannotProceedSheet(
  BuildContext context,
  SitterOrderDetail don,
) {
  final l10n = context.l10n;
  return showSitterOrderActionSheet(
    context,
    don: don,
    tieuDe: l10n.khongTheTiepNhanMa(don.maDon),
    moTa: l10n.moTaKhongTheTiepNhan,
    nhanLyDo: l10n.lyDoDung,
    nhom: [
      (tieuDe: l10n.doiHoTroSeXemXetMienPhat, maLyDo: maLyDoKhongTheTiepNhan),
    ],
    hintMoTa: l10n.moTaChoDoiHoTro,
    luonBatBuocMoTa: true,
    soAnhToiDa: soAnhChungMinhToiDa,
    nhanChinh: l10n.guiBaoVaKetThucDon,
    nhanPhu: l10n.tiepTucDiToi,
    anhHuong: [l10n.canhBaoKhongDuocMienPhat],
  );
}

// Dòng nhắc dưới sheet từ chối, kèm lối mở chính sách huỷ
class _GhiChuTuChoi extends StatelessWidget {
  const _GhiChuTuChoi();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.error_outline,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.labelGap),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${l10n.canhBaoTuChoiNhieuDon} '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.sitterCancelPolicy),
                    child: Text(
                      l10n.xemChinhSachHuy,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            style: AppTextStyles.captionSm,
          ),
        ),
      ],
    );
  }
}

// Báo đến muộn, chọn số phút trễ so với giờ hẹn
Future<int?> showSitterLateSheet(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.baoDenMuonTieuDe, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(l10n.baoDenMuonMoTa, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.stackGap),
            for (final phut in _mucBaoMuon) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheetContext, phut),
                  child: Text(l10n.nPhutNhan('$phut')),
                ),
              ),
              const SizedBox(height: AppSpacing.labelGap),
            ],
          ],
        ),
      ),
    ),
  );
}

// Trễ hơn mức này thì nên huỷ đơn chứ không phải báo muộn
const List<int> _mucBaoMuon = [5, 10, 15];
