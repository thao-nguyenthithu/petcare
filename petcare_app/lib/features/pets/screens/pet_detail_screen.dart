import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/pet_breeds.dart';
import 'package:petcare_app/features/pets/data/pet_summary.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';
import 'package:petcare_app/features/pets/data/prevention_summary.dart';
import 'package:petcare_app/features/pets/widgets/info_row_group.dart';
import 'package:petcare_app/features/pets/widgets/pet_care_note_card.dart';
import 'package:petcare_app/features/pets/widgets/pet_detail_hero.dart';
import 'package:petcare_app/features/pets/widgets/pet_documents_section.dart';
import 'package:petcare_app/features/pets/widgets/pet_overdue_alert.dart';
import 'package:petcare_app/features/pets/widgets/block_delete_pet_sheet.dart';
import 'package:petcare_app/features/pets/widgets/delete_pet_sheet.dart';
import 'package:petcare_app/features/pets/widgets/prevention_summary_rows.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

class PetDetailArgs {
  const PetDetailArgs({required this.pet, this.maDon});

  final Pet pet;
  final String? maDon;
}

// Hồ sơ chi tiết một bé, dùng chung cho chủ nuôi và người cung cấp
class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key, required this.args});

  final PetDetailArgs args;

  Pet get _pet => args.pet;
  bool get _laNcc => args.maDon != null;

  // Hạng mục quá hạn lâu nhất
  PreventionRecord? get _mucQuaHan {
    final quaHan = _pet.phongBenh
        .where((muc) => muc.trangThai == PreventionStatus.quaHan)
        .toList();
    if (quaHan.isEmpty) return null;
    return quaHan.reduce(
      (a, b) => (a.soNgayConLai ?? 0) <= (b.soNgayConLai ?? 0) ? a : b,
    );
  }

  List<PetDocument> get _giayTo => giayToCuaBe(_pet.phongBenh);

  // Mở cả chồng ảnh của một hạng mục
  Future<void> _xemGiayTo(BuildContext context, PetDocumentGroup nhom) =>
      showPhotoViewer(
        context,
        anh: [for (final muc in nhom.anh) muc.anh],
        phuDe: preventionPhotoLabel(context, nhom.hangMuc),
      );

  Future<void> _xoaHoSo(BuildContext context) async {
    // Bé còn đơn chưa kết thúc thì chặn ngay, chưa hỏi xoá
    if (_pet.donDangChay case final don?) {
      final xemDon = await showBlockDeletePetSheet(context, _pet, don);
      if (xemDon && context.mounted) baoDangPhatTrien(context);
      return;
    }
    final dongY = await showDeletePetSheet(context, _pet);
    if (dongY && context.mounted) baoDangPhatTrien(context);
  }

  // Sửa hồ sơ dùng lại chính form thêm bé
  void _suaHoSo(BuildContext context) =>
      context.push(AppRoutes.addPet, extra: _pet);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final quaHan = _mucQuaHan;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: _laNcc ? l10n.hoSoCuaBe(_pet.name) : _pet.name,
              subtitle: _laNcc
                  ? l10n.donMaBanDaNhan(args.maDon!)
                  : l10n.hoSoThuCungCuaBan,
              // Chỉ chủ nuôi mới sửa được hồ sơ bé của mình
              action: _laNcc
                  ? null
                  : IconButton(
                      onPressed: () => _suaHoSo(context),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppColors.primaryColor,
                      tooltip: l10n.sua,
                    ),
            ),
            const AppDongKe(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.groupGap),
                children: [
                  PetDetailHero(pet: _pet),
                  // Dải ảnh của bé chỉ có ở bản chủ nuôi
                  if (!_laNcc && _pet.anh.isNotEmpty) _DaiAnhBe(pet: _pet),
                  const AppDongKe(),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chủ nuôi mới cần nhắc việc quá hạn
                        if (!_laNcc && quaHan != null) ...[
                          PetOverdueAlert(muc: quaHan),
                          const SizedBox(height: AppSpacing.cardPadding),
                        ],
                        if (_pet.luuYChamSoc case final luuY?) ...[
                          PetCareNoteCard(
                            tieuDe: _laNcc
                                ? l10n.luuYChamSocTuChuNuoi
                                : l10n.luuYChamSoc,
                            noiDung: luuY,
                            ghiChu: _laNcc ? null : l10n.ghiChuLuuYHienVoiNCC,
                          ),
                          const SizedBox(height: AppSpacing.cardPadding),
                        ],
                        Text(l10n.thongTinCoBan, style: AppTextStyles.h3),
                        InfoRowGroup(dong: _thongTinCoBan(context)),
                        const SizedBox(height: AppSpacing.cardPadding),
                        Text(l10n.mucSucKhoe, style: AppTextStyles.h3),
                        InfoRowGroup(dong: _sucKhoe(context)),
                        const SizedBox(height: AppSpacing.cardPadding),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.phongBenhDinhKy,
                                style: AppTextStyles.h3,
                              ),
                            ),
                            if (!_laNcc)
                              Text(
                                l10n.soMuc('${_pet.phongBenh.length}'),
                                style: AppTextStyles.captionSm,
                              ),
                          ],
                        ),
                        if (_pet.phongBenh.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.itemGap,
                            ),
                            child: Text(
                              l10n.chuaCoHangMucNao,
                              style: AppTextStyles.captionSm,
                            ),
                          )
                        else
                          PreventionSummaryRows(danhSach: _pet.phongBenh),
                        const SizedBox(height: AppSpacing.cardPadding),
                        Text(l10n.giayToCuaBe, style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.itemGap),
                        if (_giayTo.isEmpty)
                          Text(l10n.chuaCapNhat, style: AppTextStyles.captionSm)
                        else
                          PetDocumentsSection(
                            giayTo: _giayTo,
                            onXemNhom: (nhom) => _xemGiayTo(context, nhom),
                            chiLuoiAnh: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BottomActionBar(
              child: _laNcc
                  ? AppButton(
                      text: l10n.nhanChoChuNuoi,
                      outlined: true,
                      color: AppColors.primaryColor,
                      onTap: () => baoDangPhatTrien(context),
                    )
                  : AppButton(
                      text: l10n.xoaHoSoCuaBe(_pet.name),
                      icon: Icons.delete_outline,
                      outlined: true,
                      color: AppColors.accent,
                      onTap: () => _xoaHoSo(context),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<InfoRow> _thongTinCoBan(BuildContext context) {
    final l10n = context.l10n;
    final loai = _pet.species == PetSpecies.dog ? l10n.cho : l10n.meo;
    final gioiTinh = _pet.gender == PetGender.male ? l10n.duc : l10n.cai;
    return [
      (
        nhan: l10n.loaiVaGiong,
        giaTri: '$loai ${tenGiong(context, _pet.breed)}',
      ),
      (nhan: l10n.canNang, giaTri: l10n.soKgCanNang(canNangGon(_pet.weightKg))),
      (
        nhan: l10n.gioiTinhVaTuoiNhan,
        giaTri: _pet.birthDate == null
            ? gioiTinh
            : l10n.gioiTinhVaTuoiGiaTri(gioiTinh, tuoiBe(context, _pet)),
      ),
      (
        nhan: l10n.trietSan,
        giaTri: _pet.daTrietSan ? l10n.roi : l10n.chuaTrietSan,
      ),
    ];
  }

  List<InfoRow> _sucKhoe(BuildContext context) {
    final l10n = context.l10n;
    return [
      (
        nhan: l10n.tinhTrang,
        giaTri: _pet.dangDieuTri ? l10n.dangDieuTri : l10n.binhThuong,
      ),
      (nhan: l10n.benhNenDiUngNhan, giaTri: _pet.benhNen ?? l10n.khongCo),
      (nhan: l10n.thuocDangDung, giaTri: _pet.thuocDangDung ?? l10n.khongCo),
    ];
  }
}

// Dải ảnh của bé ngay dưới phần đầu màn
class _DaiAnhBe extends StatelessWidget {
  const _DaiAnhBe({required this.pet});

  final Pet pet;

  static const double _canh = 76;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _canh,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.itemGap,
        ),
        itemCount: pet.anh.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.labelGap),
        itemBuilder: (_, i) => Material(
          color: AppColors.cardMint,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => showPhotoViewer(
              context,
              anh: pet.anh,
              viTri: i,
              phuDe: context.l10n.anhCuaBeTen(pet.name),
            ),
            child: SizedBox(
              width: _canh,
              height: _canh,
              child: PhotoThumb(anh: pet.anh[i], canh: _canh),
            ),
          ),
        ),
      ),
    );
  }
}
