import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/prevention_items.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';
import 'package:petcare_app/features/pets/widgets/prevention_item_dropdown.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Hạng mục chủ nuôi vừa chọn
typedef ChonHangMucResult = ({PreventionItem muc, String? tenTuNhap});

// Sheet chọn hạng mục trước khi khai chi tiết
Future<ChonHangMucResult?> showAddPreventionSheet(
  BuildContext context, {
  required String tenBe,
  required PetSpecies loaiBe,
  required List<PreventionRecord> daCo,
}) {
  return showModalBottomSheet<ChonHangMucResult>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius20),
      ),
    ),
    builder: (_) => _NoiDung(tenBe: tenBe, loaiBe: loaiBe, daCo: daCo),
  );
}

class _NoiDung extends StatefulWidget {
  const _NoiDung({
    required this.tenBe,
    required this.loaiBe,
    required this.daCo,
  });

  final String tenBe;
  final PetSpecies loaiBe;
  final List<PreventionRecord> daCo;

  @override
  State<_NoiDung> createState() => _NoiDungState();
}

class _NoiDungState extends State<_NoiDung> {
  final _tenTuNhapController = TextEditingController();
  PreventionItem? _chon;

  bool _moDanhSach = false;

  // Chiều cao vùng cuộn danh sách
  static const double _caoDanhSach = 288;

  double _caoDanhSachThuc(MediaQueryData mq) {
    final conLai = mq.size.height - mq.viewInsets.bottom - _caoPhanConLai;
    return conLai < _caoDanhSachToiThieu
        ? _caoDanhSachToiThieu
        : (conLai < _caoDanhSach ? conLai : _caoDanhSach);
  }

  static const double _caoPhanConLai = 300;
  static const double _caoDanhSachToiThieu = 140;

  bool get _tuNhapTen => _chon?.ma == maHangMucKhac;

  // Hạng mục đã tạo trong sổ hay chưa
  ({bool daCo, int soLan}) _tinhTrang(PreventionItem muc) {
    final trung = widget.daCo.where((e) => e.ma == muc.ma);
    return (
      daCo: trung.isNotEmpty,
      soLan: trung.fold(0, (tong, e) => tong + e.soLan),
    );
  }

  bool get _chonDuoc =>
      _chon != null &&
      (!_tuNhapTen || _tenTuNhapController.text.trim().isNotEmpty);

  @override
  void dispose() {
    _tenTuNhapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mq = MediaQuery.of(context);
    final danhMuc = danhMucHangMuc(widget.loaiBe);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        0,
        AppSpacing.screenPadding,
        AppSpacing.groupGap + mq.viewPadding.bottom + mq.viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.themHangMucChoBe(widget.tenBe), style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.itemGap),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PreventionItemDropdown(
                    nhan: _chon == null
                        ? l10n.chonHangMuc
                        : tenHangMuc(context, _chon!.ma),
                    daChon: _chon != null,
                    dangMo: _moDanhSach,
                    danhMuc: danhMuc,
                    cao: _caoDanhSachThuc(mq),
                    chon: _chon,
                    tinhTrang: _tinhTrang,
                    onMoDong: () => setState(() => _moDanhSach = !_moDanhSach),
                    onChon: (muc) => setState(() {
                      _chon = muc;
                      // Chọn xong thu gọn lại cho gọn sheet
                      _moDanhSach = false;
                      if (muc.ma != maHangMucKhac) {
                        _tenTuNhapController.clear();
                      }
                    }),
                  ),
                  if (_tuNhapTen) ...[
                    const SizedBox(height: AppSpacing.itemGap),
                    AppTextField(
                      label: l10n.tenHangMucTuNhap,
                      hint: l10n.hintTenHangMuc,
                      controller: _tenTuNhapController,
                      isRequired: true,
                      onChanged: (_) => setState(() {}),
                      height: AppTextField.caoGon,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.itemGap),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.labelGap),
                      Expanded(
                        child: Text(
                          l10n.ghiChuHangMucDaCo,
                          style: AppTextStyles.captionSm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          AppButton(
            text: l10n.them,
            enabled: _chonDuoc,
            onTap: () => Navigator.of(context).pop((
              muc: _chon!,
              tenTuNhap: _tuNhapTen ? _tenTuNhapController.text.trim() : null,
            )),
          ),
        ],
      ),
    );
  }
}
