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
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/features/sitter_order/widgets/session/pet_condition_chips.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn trả bé, chốt luôn kỳ giữ mà không phải chờ xác nhận
class SitterFinishBoardingScreen extends ConsumerStatefulWidget {
  const SitterFinishBoardingScreen({super.key, required this.args});

  final AnhBanGiao args;

  @override
  ConsumerState<SitterFinishBoardingScreen> createState() =>
      _SitterFinishBoardingScreenState();
}

class _SitterFinishBoardingScreenState
    extends ConsumerState<SitterFinishBoardingScreen> {
  late List<Uint8List> _anhBe = [...widget.args.anhBe];
  late List<Uint8List> _anhDoDung = [...widget.args.anhDoDung];
  final Set<String> _tinhTrang = {};
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
    AppRoutes.sitterHandoverCameraPath(_don.bookingId, LoaiBanGiao.traBe.ma),
  );

  Future<void> _traBe() async {
    final id = _don.bookingId;
    setState(() => _dangGui = true);
    final trangThai = await chayHanhDongLayKetQua(
      context,
      ref,
      id,
      (s) => s.ketThucLayTrangThai(
        id,
        anh: anhMultipart(_anhBe, 'checkout'),
        anhDoDung: anhMultipart(_anhDoDung, 'item'),
        ghiChu: _ghiChu.text.trim(),
        nhanTinhTrang: _tinhTrang.toList(),
      ),
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (trangThai == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.daTraBeVaKetThuc)));
    dieuHuongSauKetThuc(context, id, trangThai);
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
                      Text(l10n.xacNhanTraBe, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonTrongGiuNBeNDem(
                          _don.maDon,
                          '${_don.pets.length}',
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
            child: SessionStats(
              cot: [
                (so: l10n.soDemNhan('${_phien.soDem}'), nhan: l10n.kyGiuNhan),
                (so: ky?.gioChuNuoiToiDon ?? '', nhan: l10n.chuNuoiToiDon),
                (so: l10n.nAnh('${_phien.soAnhDaGui}'), nhan: l10n.daGui),
              ],
            ),
          ),
          const FlatDivider(),
          FlatSection(
            child: PhotoPickerGrid(
              tieuDe: l10n.anhTraBeChoChuNuoiTrenTran(
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
              tieuDe: l10n.anhDoDungTraLaiTrenTran(
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
            child: PetConditionChips(
              tieuDe: l10n.tinhTrangCacBeTrongKy,
              ma: maTinhTrangCaKy,
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
                Text(l10n.ghiChuVaKhuyenNghi, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                TextField(
                  controller: _ghiChu,
                  minLines: 3,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: l10n.hintGhiChuKhuyenNghiTrongGiu,
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
                        l10n.moTaTraBeLaHoanThanhNgay('${_don.gioGiuTien}'),
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
              text: l10n.traBeVaKetThuc,
              height: 50,
              color: AppColors.accent,
              enabled: _duAnh,
              dangTai: _dangGui,
              onTap: _traBe,
            ),
          ),
        ),
      ),
    );
  }
}
