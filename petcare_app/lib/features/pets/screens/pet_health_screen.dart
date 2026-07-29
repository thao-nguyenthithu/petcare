import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/pets/data/mock_preventions.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/features/pets/screens/prevention_detail_screen.dart';
import 'package:petcare_app/features/pets/widgets/add_prevention_sheet.dart';
import 'package:petcare_app/features/pets/widgets/pet_documents_section.dart';
import 'package:petcare_app/features/pets/widgets/pet_general_health_section.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/step_progress_bar.dart';
import 'package:petcare_app/features/pets/widgets/prevention_section.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';

// Tham số từ bước 1 sang bước 2
class PetHealthArgs {
  const PetHealthArgs({required this.tenBe, required this.loaiBe, this.petSua});

  final String tenBe;
  final PetSpecies loaiBe;

  // Có bé đang sửa thì bước 2 điền sẵn
  final Pet? petSua;
}

// Bước 2 trong 2 của luồng thêm thú cưng
class PetHealthScreen extends StatefulWidget {
  const PetHealthScreen({
    super.key,
    required this.tenBe,
    required this.loaiBe,
    this.petSua,
  });

  final String tenBe;
  final PetSpecies loaiBe;
  final Pet? petSua;

  @override
  State<PetHealthScreen> createState() => _PetHealthScreenState();
}

class _PetHealthScreenState extends State<PetHealthScreen> {
  final _benhNenController = TextEditingController();
  final _thuocController = TextEditingController();

  // Mặc định theo trường hợp phổ biến nhất
  late bool _daTrietSan = widget.petSua?.daTrietSan ?? false;
  late bool _dangDieuTri = widget.petSua?.dangDieuTri ?? false;

  // Sửa thì lấy đúng dữ liệu của bé, thêm mới thì dùng danh sách mẫu
  late final List<PreventionRecord> _phongBenh = [
    ...(widget.petSua?.phongBenh ?? MockPreventions.danhSach),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.petSua case final pet?) {
      _benhNenController.text = pet.benhNen ?? '';
      _thuocController.text = pet.thuocDangDung ?? '';
    }
  }

  @override
  void dispose() {
    _benhNenController.dispose();
    _thuocController.dispose();
    super.dispose();
  }

  // Ảnh phiếu của mọi lần trong mọi hạng mục gom về mục Giấy tờ của bé
  List<PetDocument> get _giayTo => giayToCuaBe(_phongBenh);

  // Chọn hạng mục ở sheet
  Future<void> _themHangMuc() async {
    final chon = await showAddPreventionSheet(
      context,
      tenBe: widget.tenBe,
      loaiBe: widget.loaiBe,
      daCo: _phongBenh,
    );
    if (chon == null || !mounted) return;
    final muc = chon.muc;
    final hangMuc = PreventionRecord(
      id: 'v${DateTime.now().microsecondsSinceEpoch}',
      ma: muc.ma,
      tenTuNhap: chon.tenTuNhap,
      hinhThuc: muc.hinhThuc,
      dinhKy: muc.dinhKy,
      chuKyDeXuat: muc.chuKyDeXuat,
      lanThucHien: const [],
    );
    setState(() => _phongBenh.add(hangMuc));
    await _moChiTiet(hangMuc);
  }

  // Mở chi tiết hạng mục
  Future<void> _moChiTiet(PreventionRecord hangMuc) async {
    final ketQua = await context.push<PreventionDetailResult>(
      AppRoutes.preventionDetail,
      extra: PreventionDetailArgs(hangMuc: hangMuc, tenBe: widget.tenBe),
    );
    if (ketQua == null || !mounted) return;
    setState(() {
      final viTri = _phongBenh.indexWhere((m) => m.id == ketQua.hangMuc.id);
      if (viTri < 0) return;
      switch (ketQua.hanhDong) {
        case PreventionDetailAction.luu:
          _phongBenh[viTri] = ketQua.hangMuc;
        case PreventionDetailAction.xoa:
          _phongBenh.removeAt(viTri);
      }
    });
  }

  // Mở cả chồng ảnh của một hạng mục
  Future<void> _xemGiayTo(PetDocumentGroup nhom) => showPhotoViewer(
    context,
    anh: [for (final muc in nhom.anh) muc.anh],
    phuDe: preventionPhotoLabel(context, nhom.hangMuc),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.sucKhoeCuaBe(widget.tenBe),
              subtitle: l10n.buocTrenTong('2', '2'),
            ),
            const StepProgressBar(
              buoc: 2,
              tong: 2,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                0,
                AppSpacing.screenPadding,
                AppSpacing.itemGap,
              ),
            ),
            const AppDongKe(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.blockGap,
                ),
                children: [
                  AppNoteBox(text: l10n.ghiChuHoSoTiemChung),
                  const SizedBox(height: AppSpacing.blockGap),
                  PetGeneralHealthSection(
                    daTrietSan: _daTrietSan,
                    dangDieuTri: _dangDieuTri,
                    onDoiTrietSan: (v) => setState(() => _daTrietSan = v),
                    onDoiSucKhoe: (v) => setState(() => _dangDieuTri = v),
                    benhNenController: _benhNenController,
                    thuocController: _thuocController,
                  ),
                  const AppDongKe(dem: true),
                  PreventionSection(
                    phongBenh: _phongBenh,
                    onChonMui: _moChiTiet,
                    onThemMui: _themHangMuc,
                  ),
                  const AppDongKe(dem: true),
                  PetDocumentsSection(giayTo: _giayTo, onXemNhom: _xemGiayTo),
                ],
              ),
            ),
            BottomActionBar(
              child: AppButton(
                text: l10n.luuHoSoCuaBe(widget.tenBe),
                onTap: () => baoDangPhatTrien(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
