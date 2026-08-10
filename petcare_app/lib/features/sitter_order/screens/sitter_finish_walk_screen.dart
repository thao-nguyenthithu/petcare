import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/walking_session.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';

// Màn kết thúc phiên dắt, phải có ít nhất một ảnh
class SitterFinishWalkScreen extends ConsumerStatefulWidget {
  const SitterFinishWalkScreen({super.key, required this.phien});

  final WalkingSession phien;

  @override
  ConsumerState<SitterFinishWalkScreen> createState() =>
      _SitterFinishWalkScreenState();
}

class _SitterFinishWalkScreenState
    extends ConsumerState<SitterFinishWalkScreen> {
  final List<Uint8List> _anh = [];
  final _ghiChu = TextEditingController();
  bool _dangGui = false;

  WalkingSession get _phien => widget.phien;

  @override
  void dispose() {
    _ghiChu.dispose();
    super.dispose();
  }

  // Ảnh đi cùng lượt kết thúc, gửi rời là ghi hai lần
  Future<void> _ketThuc() async {
    final id = _phien.don.bookingId;
    setState(() => _dangGui = true);
    final trangThai = await chayHanhDongLayKetQua(
      context,
      ref,
      id,
      (s) => s.ketThucLayTrangThai(
        id,
        anh: anhMultipart(_anh, 'finish'),
        ghiChu: _ghiChu.text.trim(),
        km: _phien.kmDaDi,
      ),
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (trangThai == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.daGuiXacNhan)));
    dieuHuongSauKetThuc(context, id, trangThai);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = _phien.don;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: const Padding(
        padding: EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 6),
        child: Row(children: [AppBackButton()]),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.ketThucDichVu, style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  l10n.maDonDichVuNBe(
                    don.maDon,
                    _tenNgan(don.tenDichVu),
                    '${don.pets.length}',
                  ),
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const FlatDivider(),
          FlatSection(child: _TongKet(phien: _phien)),
          const FlatDivider(),
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.anhKetThucBatBuoc('$soAnhKetThucToiThieu'),
                  style: AppTextStyles.label,
                ),
                const SizedBox(height: 14),
                PhotoPickerGrid(
                  anh: _anh,
                  tran: soAnhKetThucToiDa,
                  soCot: 3,
                  batBuocChup: true,
                  onDoi: (ds) => setState(() {
                    _anh
                      ..clear()
                      ..addAll(ds);
                  }),
                ),
                const SizedBox(height: 22),
                Text(l10n.ghiChuGuiChuNuoi, style: AppTextStyles.label),
                const SizedBox(height: 14),
                TextField(
                  controller: _ghiChu,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(hintText: l10n.hintGhiChuKetThuc),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.schedule_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.moTaChuNuoiCoNGioXacNhan('${don.gioGiuTien}'),
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
              text: l10n.ketThucVaTraBe,
              height: 50,
              enabled: _anh.length >= soAnhKetThucToiThieu,
              dangTai: _dangGui,
              onTap: _ketThuc,
            ),
          ),
        ),
      ),
    );
  }
}

String _tenNgan(String tenDichVu) => tenDichVu.split('·').first.trim();

class _TongKet extends StatelessWidget {
  const _TongKet({required this.phien});

  final WalkingSession phien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return IntrinsicHeight(
      child: Row(
        children: [
          _Cot(so: l10n.nPhut('${phien.phutDaDat}'), nhan: l10n.thoiLuong),
          const _Vach(),
          _Cot(so: l10n.soKm(soLeKm(phien.kmDaDi)), nhan: l10n.quangDuong),
          const _Vach(),
          _Cot(so: l10n.nAnh('${phien.soAnhDaGui}'), nhan: l10n.daGui),
        ],
      ),
    );
  }
}

class _Cot extends StatelessWidget {
  const _Cot({required this.so, required this.nhan});

  final String so;
  final String nhan;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            so,
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryColor),
          ),
          const SizedBox(height: 3),
          Text(nhan, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}

class _Vach extends StatelessWidget {
  const _Vach();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: AppColors.neutralLight);
}
