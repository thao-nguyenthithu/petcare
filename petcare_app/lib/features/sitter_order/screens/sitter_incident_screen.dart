import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/widgets/handover_photo_group.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

const int _soAnhToiDa = 3;
const int _moTaToiThieu = 10;
const List<String> _maLyDo = [
  'beKhongHopTac',
  'chuNuoiVang',
  'diaChiSai',
  'thoiTietXau',
  'khac',
];

String _nhanLyDo(AppLocalizations l10n, String ma) => switch (ma) {
  'beKhongHopTac' => l10n.scBeKhongHopTac,
  'chuNuoiVang' => l10n.scChuNuoiVang,
  'diaChiSai' => l10n.scDiaChiSai,
  'thoiTietXau' => l10n.scThoiTietXau,
  _ => l10n.scKhac,
};

// Màn Báo sự cố của người chăm, mở từ màn Đang diễn ra
class SitterIncidentScreen extends ConsumerStatefulWidget {
  const SitterIncidentScreen({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  ConsumerState<SitterIncidentScreen> createState() =>
      _SitterIncidentScreenState();
}

class _SitterIncidentScreenState extends ConsumerState<SitterIncidentScreen> {
  final _moTaController = TextEditingController();
  final List<Uint8List> _anh = [];
  int _selected = 0;
  bool _dangGui = false;

  @override
  void dispose() {
    _moTaController.dispose();
    super.dispose();
  }

  Future<void> _chup() async {
    if (_anh.length >= _soAnhToiDa) return;
    final chon = await chupMotAnh();
    if (!mounted) return;
    if (chon.quaNang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
      return;
    }
    final bytes = chon.anh;
    if (bytes == null) return;
    setState(() => _anh.add(bytes));
  }

  List<String> _options(BuildContext context) {
    final l10n = context.l10n;
    return [for (final ma in _maLyDo) _nhanLyDo(l10n, ma)];
  }

  // Chỉ mở hồ sơ: phiên vẫn chạy tiếp, đơn không đổi trạng thái (mục 7)
  Future<void> _gui() async {
    final l10n = context.l10n;
    final id = widget.don.bookingId;
    setState(() => _dangGui = true);
    final xong = await chayHanhDongDon(
      context,
      ref,
      id,
      (s) => s.baoSuCo(
        id,
        moTa: _moTaController.text.trim(),
        maLyDo: _maLyDo[_selected],
        anh: anhMultipart(_anh, 'incident'),
      ),
      nhanBaoXong: l10n.daGuiBaoCao,
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (xong) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = _options(context);
    final don = widget.don;
    final orderCtx = l10n.maDonDichVuNBe(
      don.maDon,
      don.tenDichVu.split('·').first.trim(),
      '${don.pets.length}',
    );
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(title: l10n.baoSuCo),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.stackGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          Text(orderCtx, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.itemGap),
          Text(l10n.chuyenGiDangXayRa, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.itemGap),
          for (var i = 0; i < options.length; i++) ...[
            _OptionTile(
              label: options[i],
              selected: i == _selected,
              onTap: () => setState(() => _selected = i),
            ),
            if (i != options.length - 1)
              const SizedBox(height: AppSpacing.labelGap),
          ],
          const SizedBox(height: AppSpacing.blockGap),
          Text(l10n.moTaVaAnh, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.itemGap),
          AppCard(
            nen: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: TextField(
              controller: _moTaController,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l10n.moTaSuCoHint,
                hintStyle: AppTextStyles.body,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          HandoverPhotoGroup(
            tieuDe: l10n.anhSuCoTrenTran('${_anh.length}', '$_soAnhToiDa'),
            anh: _anh,
            tran: _soAnhToiDa,
            onThem: _chup,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _CanhBaoBanner(text: l10n.canhBaoNguyHiem),
        ],
      ),
      bottomBar: _BottomBar(
        onSubmit: _gui,
        guiDuoc: _moTaController.text.trim().length >= _moTaToiThieu,
        dangGui: _dangGui,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.neutralLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? AppColors.accent : AppColors.neutral,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.body)),
          ],
        ),
      ),
    );
  }
}

class _CanhBaoBanner extends StatelessWidget {
  const _CanhBaoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTextStyles.captionSm)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.onSubmit,
    required this.guiDuoc,
    required this.dangGui,
  });

  final VoidCallback onSubmit;
  final bool guiDuoc;
  final bool dangGui;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        12,
        AppSpacing.screenPadding,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: l10n.guiBaoCaoSuCo,
              color: AppColors.accent,
              height: 50,
              enabled: guiDuoc,
              dangTai: dangGui,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
