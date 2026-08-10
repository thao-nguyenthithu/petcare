import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/widgets/handover_notice_box.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/pet_condition_chips.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn gửi cập nhật hằng ngày của kỳ trông giữ
class SitterDailyUpdateScreen extends ConsumerStatefulWidget {
  const SitterDailyUpdateScreen({super.key, required this.phien});

  final BoardingSession phien;

  @override
  ConsumerState<SitterDailyUpdateScreen> createState() =>
      _SitterDailyUpdateScreenState();
}

class _SitterDailyUpdateScreenState
    extends ConsumerState<SitterDailyUpdateScreen> {
  List<Uint8List> _anh = [];
  final Set<String> _tinhTrang = {};
  final _loiNhan = TextEditingController();
  bool _dangGui = false;

  BoardingSession get _phien => widget.phien;

  bool get _guiDuoc => _anh.isNotEmpty;

  @override
  void dispose() {
    _loiNhan.dispose();
    super.dispose();
  }


  Future<void> _gui() async {
    final id = _phien.don.bookingId;
    setState(() => _dangGui = true);
    final xong = await chayHanhDongDon(
      context,
      ref,
      id,
      (s) => s.capNhatNgay(
        id,
        anh: anhMultipart(_anh, 'daily'),
        loiNhan: _loiNhan.text.trim(),
        nhanTinhTrang: _tinhTrang.toList(),
      ),
      nhanBaoXong: context.l10n.daGuiCapNhat,
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (xong) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = _phien.don;
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
                      Text(l10n.capNhatHomNay, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonTrongGiuNBeNgay(
                          don.maDon,
                          '${don.pets.length}',
                          '${_phien.demHienTai}',
                          '${_phien.soDem}',
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
              chinh: l10n.anhDaChupLucChuNuoiNhanNgay(_phien.gioChupAnh ?? ''),
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: PhotoPickerGrid(
              tieuDe: l10n.anhHomNayTrenTran(
                '${_anh.length}',
                '$soAnhCapNhatToiDa',
              ),
              anh: _anh,
              tran: soAnhCapNhatToiDa,
              onDoi: (ds) => setState(() => _anh = ds),
                batBuocChup: true,
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: PetConditionChips(
              tieuDe: l10n.cacBeHomNayTheNao,
              ma: maTinhTrangHangNgay,
              dangChon: _tinhTrang,
              onDoi: (ma, chon) => setState(
                () => chon ? _tinhTrang.add(ma) : _tinhTrang.remove(ma),
              ),
            ),
          ),
          const SizedBox(height: 20),
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.loiNhanChoChuNuoi, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                TextField(
                  controller: _loiNhan,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.hintLoiNhanCapNhat,
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
                        l10n.moTaMoiNgayMotCapNhat,
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
              text: l10n.guiChoChuNuoi,
              height: 50,
              enabled: _guiDuoc,
              dangTai: _dangGui,
              onTap: _gui,
            ),
          ),
        ),
      ),
    );
  }
}
