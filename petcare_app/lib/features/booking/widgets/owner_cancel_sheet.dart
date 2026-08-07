import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/cancel_reasons.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/order_summary_head.dart';

// Đơn sắp huỷ, nhìn từ phía chủ nuôi
typedef OwnerCancelTarget = ({
  String maDon,
  String tenDichVu,
  List<Pet> pets,
  String moTaThoiGian,
  String tenNcc,
  int tongTien,
  int phiHuy,
  int tienHoan,
  bool mienPhi,
});

typedef LyDoHuyCuaChuNuoi = ({String ma, String moTa});

// Sheet huỷ đơn phía CHỦ NUÔI
Future<LyDoHuyCuaChuNuoi?> showOwnerCancelSheet(
  BuildContext context,
  OwnerCancelTarget don,
) {
  return showModalBottomSheet<LyDoHuyCuaChuNuoi>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _OwnerCancelSheet(don: don),
  );
}

class _OwnerCancelSheet extends StatefulWidget {
  const _OwnerCancelSheet({required this.don});

  final OwnerCancelTarget don;

  @override
  State<_OwnerCancelSheet> createState() => _OwnerCancelSheetState();
}

class _OwnerCancelSheetState extends State<_OwnerCancelSheet> {
  final TextEditingController _moTa = TextEditingController();
  String? _lyDo;
  bool _laLyDoKhac = false;

  @override
  void dispose() {
    _moTa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = widget.don;
    final mq = MediaQuery.of(context);
    final duocHuy =
        _lyDo != null && (!_laLyDoKhac || _moTa.text.trim().isNotEmpty);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPaddingWide,
        0,
        AppSpacing.screenPaddingWide,
        AppSpacing.groupGap + mq.viewPadding.bottom + mq.viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.huyDonMaDon(don.maDon), style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(
              don.mienPhi ? l10n.moTaHuyConMienPhi : l10n.moTaHuyDaTinhPhi,
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            _TomTatDon(don: don),
            const SizedBox(height: AppSpacing.stackGap),
            Text(l10n.lyDoHuy, style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.labelGap),
            Wrap(
              spacing: AppSpacing.labelGap,
              runSpacing: AppSpacing.labelGap,
              children: [
                for (final ma in maLyDoHuyChuNuoi)
                  AppFilterChip(
                    label: nhanLyDoHuy(context, ma),
                    selected: _lyDo == ma,
                    onTap: () => setState(() {
                      _lyDo = ma;
                      _laLyDoKhac = ma == maLyDoKhac;
                    }),
                  ),
              ],
            ),
            if (_laLyDoKhac) ...[
              const SizedBox(height: AppSpacing.itemGap),
              AppTextField(
                label: '',
                hint: l10n.moTaHuyBatBuocKhac,
                controller: _moTa,
                isRequired: true,
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: AppSpacing.stackGap),
            if (don.mienPhi)
              _DongGhiChu(
                icon: Icons.info_outline,
                chu: l10n.hoanTienVeTaiKhoan,
                mau: AppColors.textSecondary,
              )
            else ...[
              _BangPhiHuy(don: don),
              const SizedBox(height: AppSpacing.itemGap),
              _DongGhiChu(
                icon: Icons.error_outline,
                chu: l10n.canhBaoPhiHuyChuNuoi,
                mau: AppColors.accent,
              ),
            ],
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: don.mienPhi ? l10n.huyDon : l10n.xacNhanHuyVaChiuPhi,
              color: AppColors.accent,
              enabled: duocHuy,
              onTap: () =>
                  Navigator.pop(context, (ma: _lyDo!, moTa: _moTa.text.trim())),
            ),
            const SizedBox(height: AppSpacing.labelGap),
            AppButton(
              text: l10n.giuDon,
              flat: true,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _TomTatDon extends StatelessWidget {
  const _TomTatDon({required this.don});

  final OwnerCancelTarget don;

  @override
  Widget build(BuildContext context) {
    return OrderSummaryHead(
      pets: don.pets,
      tenDichVu: don.tenDichVu,
      moTaThoiGian: don.moTaThoiGian,
      tenDoiTac: don.tenNcc,
      keDuoi: true,
    );
  }
}

class _BangPhiHuy extends StatelessWidget {
  const _BangPhiHuy({required this.don});

  final OwnerCancelTarget don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phanTram = don.tongTien == 0
        ? 0
        : (don.phiHuy * 100 / don.tongTien).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.phiHuyMuon, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.itemGap),
        _Hang(nhan: l10n.giaCuaDon, tien: don.tongTien),
        const SizedBox(height: AppSpacing.textGap),
        _Hang(
          nhan: l10n.phiHuyPhanTram('$phanTram'),
          tien: don.phiHuy,
          mau: AppColors.accent,
        ),
        const SizedBox(height: AppSpacing.textGap),
        _Hang(nhan: l10n.hoanVeVnpay, tien: don.tienHoan),
      ],
    );
  }
}

class _Hang extends StatelessWidget {
  const _Hang({required this.nhan, required this.tien, this.mau});

  final String nhan;
  final int tien;
  final Color? mau;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(nhan, style: AppTextStyles.captionSm)),
        Text(
          '${dinhDangTien(tien)}đ',
          style: AppTextStyles.label.copyWith(color: mau),
        ),
      ],
    );
  }
}

class _DongGhiChu extends StatelessWidget {
  const _DongGhiChu({required this.icon, required this.chu, required this.mau});

  final IconData icon;
  final String chu;
  final Color mau;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: mau),
        const SizedBox(width: AppSpacing.labelGap),
        Expanded(
          child: Text(chu, style: AppTextStyles.captionSm.copyWith(color: mau)),
        ),
      ],
    );
  }
}
