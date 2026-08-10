import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/dispute_reasons.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/utils/anh_multipart.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/dispute_booking_facts.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';

const int _moTaToiThieu = 20;

// Chủ nuôi báo sự cố, tức mở hồ sơ khiếu nại của đơn (bộ luật mục 7)
class OwnerDisputeScreen extends ConsumerStatefulWidget {
  const OwnerDisputeScreen({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  ConsumerState<OwnerDisputeScreen> createState() => _OwnerDisputeScreenState();
}

class _OwnerDisputeScreenState extends ConsumerState<OwnerDisputeScreen> {
  final _moTa = TextEditingController();
  List<Uint8List> _anh = [];
  String? _maLyDo;
  bool _dangGui = false;

  @override
  void dispose() {
    _moTa.dispose();
    super.dispose();
  }

  int get _thieuKyTu => _moTaToiThieu - _moTa.text.trim().length;

  bool get _guiDuoc => _maLyDo != null && _thieuKyTu <= 0;

  Future<void> _gui() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _dangGui = true);
    try {
      await BookingsApiService().moKhieuNai(
        widget.don.id,
        moTa: _moTa.text.trim(),
        maLyDo: _maLyDo,
        anh: anhMultipart(_anh, 'dispute'),
      );
      if (!mounted) return;
      ref.refreshBookingData();
      messenger.showSnackBar(SnackBar(content: Text(l10n.daMoHoSoKhieuNai)));
      nav.pop();
    } catch (loi) {
      if (!mounted) return;
      setState(() => _dangGui = false);
      messenger.showSnackBar(
        SnackBar(content: Text(messageFromError(loi) ?? l10n.loiKetNoiMayChu)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          DisputeBookingFacts(
            tenDichVu: widget.don.tenDichVu,
            maDon: widget.don.maDon,
            tenBe: [for (final be in widget.don.pets) be.name],
            nhanDoiPhuong: l10n.nguoiCham,
            tenDoiPhuong: widget.don.tenNcc,
            thoiGian: widget.don.moTaThoiGian,
          ),
          const SizedBox(height: AppSpacing.blockGap),
          Text(l10n.banGapVanDeGi, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.labelGap),
          Wrap(
            spacing: AppSpacing.labelGap,
            runSpacing: AppSpacing.labelGap,
            children: [
              for (final ma in maSuCoChuNuoi)
                AppFilterChip(
                  label: nhanSuCoChuNuoi(context, ma),
                  selected: _maLyDo == ma,
                  onTap: () => setState(() => _maLyDo = ma),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.blockGap),
          Text(l10n.moTaChiTietBatBuoc, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.itemGap),
          AppCard(
            nen: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: TextField(
              controller: _moTa,
              maxLines: 5,
              minLines: 4,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: l10n.hintMoTaKhieuNai,
                hintStyle: AppTextStyles.body,
              ),
            ),
          ),
          if (_thieuKyTu > 0) ...[
            const SizedBox(height: AppSpacing.textGap),
            Text(
              l10n.conThieuNKyTu('$_thieuKyTu'),
              style: AppTextStyles.captionSm,
            ),
          ],
          const SizedBox(height: AppSpacing.blockGap),
          PhotoPickerGrid(
            tieuDe: l10n.anhKhieuNaiTrenTran(
              '${_anh.length}',
              '$soAnhMoKhieuNai',
            ),
            anh: _anh,
            tran: soAnhMoKhieuNai,
            onDoi: (ds) => setState(() => _anh = ds),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          _CanhBaoGiuTien(text: l10n.moKhieuNaiGiuTien),
        ],
      ),
      bottomBar: _BottomBar(
        guiDuoc: _guiDuoc,
        dangGui: _dangGui,
        onGui: _gui,
      ),
    );
  }
}

class _CanhBaoGiuTien extends StatelessWidget {
  const _CanhBaoGiuTien({required this.text});

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
    required this.guiDuoc,
    required this.dangGui,
    required this.onGui,
  });

  final bool guiDuoc;
  final bool dangGui;
  final VoidCallback onGui;

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
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                text: l10n.huy,
                outlined: true,
                height: 50,
                mauChu: AppColors.textSecondary,
                enabled: !dangGui,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              flex: 2,
              child: AppButton(
                text: l10n.guiBaoCaoSuCo,
                color: AppColors.accent,
                height: 50,
                enabled: guiDuoc,
                dangTai: dangGui,
                onTap: onGui,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
