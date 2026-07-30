import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/pets/services/pet_error_mapper.dart';
import 'package:petcare_app/features/pets/screens/prevention_dose_form_screen.dart';
import 'package:petcare_app/features/pets/widgets/prevention_timeline.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Tham số vào màn chi tiết một hạng mục phòng bệnh
class PreventionDetailArgs {
  const PreventionDetailArgs({
    required this.hangMuc,
    required this.tenBe,
    this.petId,
  });

  final PreventionRecord hangMuc;
  final String tenBe;
  final String? petId;
}

enum PreventionDetailAction { luu, xoa }

typedef PreventionDetailResult = ({
  PreventionDetailAction hanhDong,
  PreventionRecord hangMuc,
});

// Chi tiết một hạng mục theo dòng thời gian
class PreventionDetailScreen extends ConsumerStatefulWidget {
  const PreventionDetailScreen({super.key, required this.args});

  final PreventionDetailArgs args;

  @override
  ConsumerState<PreventionDetailScreen> createState() =>
      _PreventionDetailScreenState();
}

class _PreventionDetailScreenState
    extends ConsumerState<PreventionDetailScreen> {
  late PreventionRecord _hangMuc = widget.args.hangMuc;

  String? _idVuaGhi;
  String? get _petId => widget.args.petId;

  bool get _trongRong => _hangMuc.lanThucHien.isEmpty;

  // Thoát màn thì trả hạng mục mới nhất về cho danh sách phòng bệnh
  void _thoat() =>
      context.pop((hanhDong: PreventionDetailAction.luu, hangMuc: _hangMuc));

  // Mở form ghi lần mới hoặc sửa
  Future<void> _moForm([PreventionDose? lan]) async {
    final ketQua = await context.push<PreventionRecord>(
      AppRoutes.preventionDose,
      extra: PreventionDoseFormArgs(
        tenBe: widget.args.tenBe,
        hangMuc: _hangMuc,
        lanSua: lan,
        petId: _petId,
      ),
    );
    if (ketQua == null || !mounted) return;
    // Lần vừa ghi hoặc vừa sửa
    final idCu = {for (final e in _hangMuc.lanThucHien) e.id};
    final them = ketQua.lanThucHien.where((e) => !idCu.contains(e.id));
    final idMoi = ketQua.lanThucHien.map((e) => e.id).toSet();
    setState(() {
      _hangMuc = ketQua;
      _idVuaGhi = them.isNotEmpty
          ? them.first.id
          : (idMoi.contains(lan?.id) ? lan?.id : null);
    });
  }

  String get _ghiChuXoa {
    final l10n = context.l10n;
    if (_trongRong) return l10n.ghiChuXoaKhongMatGi;
    return l10n.ghiChuXoaCaHangMucSoLan('${_hangMuc.soLan}');
  }

  Future<void> _xoaHangMuc() async {
    final l10n = context.l10n;
    final dongY = await showConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: _trongRong ? l10n.xoaHangMucNay : l10n.xoaCaHangMucNay,
      message: _ghiChuXoa,
      confirmLabel: l10n.xoa,
      danger: true,
    );
    if (!dongY || !mounted) return;
    if (_petId case final id?) {
      try {
        await ref.read(myPetsProvider.notifier).xoaHangMuc(id, _hangMuc.id);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(moTaLoiThuCung(context, e))));
        return;
      }
      if (!mounted) return;
    }
    context.pop((hanhDong: PreventionDetailAction.xoa, hangMuc: _hangMuc));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _thoat();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              AppScreenHeader(
                title: preventionTitle(context, _hangMuc),
                subtitle: _trongRong
                    ? l10n.beChuaGhiLanNao(widget.args.tenBe)
                    : l10n.beVaSoLan(widget.args.tenBe, '${_hangMuc.soLan}'),
                onBack: _thoat,
              ),
              const AppDongKe(),
              Expanded(
                child: _trongRong ? _ThanRong(onThem: _moForm) : _thanCoLan(),
              ),
              _ThanhXoa(
                nhan: _trongRong ? l10n.xoaHangMucNay : l10n.xoaCaHangMucNay,
                ghiChu: _ghiChuXoa,
                onXoa: _xoaHangMuc,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thanCoLan() {
    final l10n = context.l10n;
    final hanMoi = _idVuaGhi == null ? null : _hangMuc.ngayNhacLai;
    final quaHan = _hangMuc.trangThai == PreventionStatus.quaHan;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        // Quá hạn thì cảnh báo trước
        if (quaHan) ...[
          AppNoteBox(
            kieu: NoteKind.canhBao,
            coNen: true,
            text: l10n.moTaQuaHanChiTiet(
              '${-_hangMuc.soNgayConLai!}',
              ngayThangNam(_hangMuc.ngayNhacLai!),
            ),
          ),
          const SizedBox(height: AppSpacing.cardPadding),
        ],
        AppButton(
          text: quaHan ? l10n.ghiLanDaLam : l10n.them,
          icon: Icons.add,
          color: quaHan ? AppColors.accent : null,
          onTap: _moForm,
        ),
        const SizedBox(height: AppSpacing.cardPadding),
        const AppDongKe(),
        const SizedBox(height: AppSpacing.cardPadding),
        Text(l10n.dongThoiGian, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.cardPadding),
        PreventionTimeline(hangMuc: _hangMuc, onChonLan: _moForm),
        const SizedBox(height: AppSpacing.cardPadding),
        if (hanMoi != null) ...[
          const SizedBox(height: AppSpacing.labelGap),
          AppNoteBox(text: l10n.chamDeSuaXoaLan),
        ],
      ],
    );
  }
}

// Hạng mục vừa tạo, chưa ghi lần nào
class _ThanRong extends StatelessWidget {
  const _ThanRong({required this.onThem});

  final VoidCallback onThem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenEdgeGap,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      children: [
        AppEmptyState(
          gon: true,
          icon: Icons.event_note_outlined,
          iconColor: AppColors.textSecondary,
          circleColor: AppColors.background,
          title: l10n.hangMucDaTaoChuaCoLan,
          action: AppButton(text: l10n.them, icon: Icons.add, onTap: onThem),
        ),
      ],
    );
  }
}

// Thanh xoá dưới đáy
class _ThanhXoa extends StatelessWidget {
  const _ThanhXoa({
    required this.nhan,
    required this.ghiChu,
    required this.onXoa,
  });

  final String nhan;
  final String ghiChu;
  final VoidCallback onXoa;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            AppButton(
              text: nhan,
              icon: Icons.delete_outline,
              outlined: true,
              color: AppColors.accent,
              radius: AppRadius.radius14,
              onTap: onXoa,
            ),
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              ghiChu,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionSm,
            ),
          ],
        ),
      ),
    );
  }
}
