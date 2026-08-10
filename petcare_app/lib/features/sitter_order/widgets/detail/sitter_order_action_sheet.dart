import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_cancel_reasons.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/shared/widgets/order_summary_head.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';

typedef LyDoBoDon = ({String lyDo, String moTa, List<Uint8List> anh});

typedef NhomLyDo = ({String? tieuDe, List<String> maLyDo});

// Khung chung cho các sheet bỏ đơn
Future<LyDoBoDon?> showSitterOrderActionSheet(
  BuildContext context, {
  required SitterOrderDetail don,
  required String tieuDe,
  required String moTa,
  required String nhanLyDo,
  required List<NhomLyDo> nhom,
  required String hintMoTa,
  required String nhanChinh,
  required String nhanPhu,
  bool luonBatBuocMoTa = false,
  int soAnhToiDa = 0,
  List<String> anhHuong = const [],
  Widget? ghiChuCuoi,
}) {
  return showModalBottomSheet<LyDoBoDon>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _SitterOrderActionSheet(
      don: don,
      tieuDe: tieuDe,
      moTa: moTa,
      nhanLyDo: nhanLyDo,
      nhom: nhom,
      hintMoTa: hintMoTa,
      nhanChinh: nhanChinh,
      nhanPhu: nhanPhu,
      luonBatBuocMoTa: luonBatBuocMoTa,
      soAnhToiDa: soAnhToiDa,
      anhHuong: anhHuong,
      ghiChuCuoi: ghiChuCuoi,
    ),
  );
}

class _SitterOrderActionSheet extends StatefulWidget {
  const _SitterOrderActionSheet({
    required this.don,
    required this.tieuDe,
    required this.moTa,
    required this.nhanLyDo,
    required this.nhom,
    required this.hintMoTa,
    required this.nhanChinh,
    required this.nhanPhu,
    required this.luonBatBuocMoTa,
    required this.soAnhToiDa,
    required this.anhHuong,
    required this.ghiChuCuoi,
  });

  final SitterOrderDetail don;
  final String tieuDe;
  final String moTa;
  final String nhanLyDo;
  final List<NhomLyDo> nhom;
  final String hintMoTa;
  final String nhanChinh;
  final String nhanPhu;
  final bool luonBatBuocMoTa;
  final int soAnhToiDa;
  final List<String> anhHuong;
  final Widget? ghiChuCuoi;

  @override
  State<_SitterOrderActionSheet> createState() =>
      _SitterOrderActionSheetState();
}

class _SitterOrderActionSheetState extends State<_SitterOrderActionSheet> {
  final TextEditingController _moTa = TextEditingController();
  final List<Uint8List> _anh = [];
  String? _lyDo;

  @override
  void dispose() {
    _moTa.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final canMoTa = widget.luonBatBuocMoTa || _lyDo == maLyDoKhacNcc;
    final duocBam = _lyDo != null && (!canMoTa || _moTa.text.trim().isNotEmpty);
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
            Text(widget.tieuDe, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.textGap),
            Text(widget.moTa, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.stackGap),
            _TomTatDon(don: widget.don),
            const SizedBox(height: AppSpacing.stackGap),
            Text(widget.nhanLyDo, style: AppTextStyles.label),
            for (final (i, n) in widget.nhom.indexed) ...[
              if (n.tieuDe case final tieuDe?) ...[
                SizedBox(
                  height: i == 0 ? AppSpacing.labelGap : AppSpacing.stackGap,
                ),
                Text(tieuDe, style: AppTextStyles.captionSm),
              ],
              const SizedBox(height: AppSpacing.labelGap),
              Wrap(
                spacing: AppSpacing.labelGap,
                runSpacing: AppSpacing.labelGap,
                children: [
                  for (final ma in n.maLyDo)
                    AppFilterChip(
                      label: nhanLyDoNcc(context, ma),
                      selected: _lyDo == ma,
                      onTap: () => setState(() => _lyDo = ma),
                    ),
                ],
              ),
            ],
            if (canMoTa) ...[
              const SizedBox(height: AppSpacing.itemGap),
              AppTextField(
                label: '',
                hint: widget.hintMoTa,
                controller: _moTa,
                isRequired: true,
                maxLines: 2,
                height: 82,
                onChanged: (_) => setState(() {}),
              ),
            ],
            if (widget.soAnhToiDa > 0) ...[
              const SizedBox(height: AppSpacing.stackGap),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.anhHoacGiayToTuyChon,
                      style: AppTextStyles.label,
                    ),
                  ),
                  Text(
                    context.l10n.toiDaNAnh('${widget.soAnhToiDa}'),
                    style: AppTextStyles.captionSm,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.labelGap),
              PhotoPickerGrid(
                anh: _anh,
                tran: widget.soAnhToiDa,
                soCot: 4,
                onDoi: (ds) => setState(() {
                  _anh
                    ..clear()
                    ..addAll(ds);
                }),
              ),
            ],
            if (widget.anhHuong.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.stackGap),
              const AppDongKe(),
              const SizedBox(height: AppSpacing.stackGap),
              Text(context.l10n.anhHuongToiBan, style: AppTextStyles.label),
              const SizedBox(height: AppSpacing.itemGap),
              _KhoiAnhHuong(dong: widget.anhHuong),
            ],
            if (widget.ghiChuCuoi case final ghiChu?) ...[
              const SizedBox(height: AppSpacing.stackGap),
              ghiChu,
            ],
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(
              text: widget.nhanChinh,
              color: AppColors.accent,
              enabled: duocBam,
              onTap: () => Navigator.pop(context, (
                lyDo: _lyDo!,
                moTa: _moTa.text.trim(),
                anh: List<Uint8List>.unmodifiable(_anh),
              )),
            ),
            const SizedBox(height: AppSpacing.labelGap),
            AppButton(
              text: widget.nhanPhu,
              flat: true,
              color: AppColors.textSecondary,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// Nhắc lại đang bỏ đơn nào, kẻo bấm nhầm
class _TomTatDon extends StatelessWidget {
  const _TomTatDon({required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    return OrderSummaryHead(
      pets: don.pets,
      tenDichVu: don.tenDichVu,
      moTaThoiGian: don.moTaThoiGian,
      tenDoiTac: don.tenChuNuoi,
      keDuoi: true,
    );
  }
}

// Nói hệ quả trước khi bấm, không giấu tới lúc bấm xong
class _KhoiAnhHuong extends StatelessWidget {
  const _KhoiAnhHuong({required this.dong});

  final List<String> dong;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, d) in dong.indexed) ...[
            if (i != 0) const SizedBox(height: AppSpacing.itemGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(d, style: AppTextStyles.captionSm)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
