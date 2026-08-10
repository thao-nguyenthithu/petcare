import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/widgets/handover_notice_box.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn chốt bàn giao lúc nhận bé, cũng là chỗ mốc kỳ giữ được chốt
class SitterHandoverScreen extends ConsumerStatefulWidget {
  const SitterHandoverScreen({super.key, required this.args});

  final AnhBanGiao args;

  @override
  ConsumerState<SitterHandoverScreen> createState() =>
      _SitterHandoverScreenState();
}

class _SitterHandoverScreenState extends ConsumerState<SitterHandoverScreen> {
  late List<Uint8List> _anhBe = [...widget.args.anhBe];
  late List<Uint8List> _anhDoDung = [...widget.args.anhDoDung];
  final _ghiChu = TextEditingController();
  bool _dangGui = false;

  BoardingSession get _phien => widget.args.phien;
  SitterOrderDetail get _don => _phien.don;

  bool get _duAnh => _anhBe.length >= _don.pets.length;

  @override
  void dispose() {
    _ghiChu.dispose();
    super.dispose();
  }

  void _chupThem() => context.pushReplacement(
    AppRoutes.sitterHandoverCameraPath(_don.bookingId, LoaiBanGiao.nhanBe.ma),
  );

  Future<void> _nhanBe() async {
    final id = _don.bookingId;
    setState(() => _dangGui = true);
    final xong = await chayHanhDongDon(
      context,
      ref,
      id,
      (s) => s.batDauPhien(
        id,
        anh: anhMultipart(_anhBe, 'handover'),
        anhDoDung: anhMultipart(_anhDoDung, 'item'),
        moTa: _ghiChu.text.trim(),
      ),
      nhanBaoXong: context.l10n.daNhanDuBe,
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (xong) context.pushReplacement(AppRoutes.sitterOrderDetailPath(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ky = _don.trongGiu;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.xacNhanBanGiao, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonTrongGiuNBeNhanLuc(
                          _don.maDon,
                          '${_don.pets.length}',
                          _don.gioHen,
                        ),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const FlatDivider(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: HandoverNoticeBox(
              chinh: l10n.anhDaChupLucSoatRoiChot(_phien.gioChupAnh ?? ''),
              phu: l10n.heThongGhiNhanChuNuoiToiLuc(
                _don.tenChuNuoi,
                ky?.gioNhanBe ?? '',
              ),
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: PhotoPickerGrid(
              tieuDe: l10n.anhLucNhanBeTrenTran(
                '${_anhBe.length}',
                '${_phien.tranAnhBe}',
              ),
              anh: _anhBe,
              tran: _phien.tranAnhBe,
              onDoi: (ds) => setState(() => _anhBe = ds),
              onThemTuyBien: _chupThem,
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: PhotoPickerGrid(
              tieuDe: l10n.anhDoDungLucNhanTrenTran(
                '${_anhDoDung.length}',
                '$soAnhDoDungToiDa',
              ),
              anh: _anhDoDung,
              tran: soAnhDoDungToiDa,
              onDoi: (ds) => setState(() => _anhDoDung = ds),
              onThemTuyBien: _chupThem,
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ghiChuLucNhanBe, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                TextField(
                  controller: _ghiChu,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.hintGhiChuLucNhanBe,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.moTaBamNhanBeLaChotMoc,
                        style: AppTextStyles.captionSm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutralLight)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
            child: AppButton(
              text: l10n.nhanBeVaBatDauKyGiu('${_don.pets.length}'),
              height: 50,
              enabled: _duAnh,
              dangTai: _dangGui,
              onTap: _nhanBe,
            ),
          ),
        ),
      ),
    );
  }
}
