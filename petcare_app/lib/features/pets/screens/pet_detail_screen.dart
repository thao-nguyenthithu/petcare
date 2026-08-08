import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_breeds.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/pets/services/pet_error_mapper.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';
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
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Ai đang mở hồ sơ bé
enum VaiXemHoSoBe { chuNuoi, nguoiCham }

class PetDetailArgs {
  const PetDetailArgs({
    required this.petId,
    this.maDon,
    this.pet,
    this.vai = VaiXemHoSoBe.chuNuoi,
  });

  final String petId;
  final String? maDon;
  final Pet? pet;
  final VaiXemHoSoBe vai;
}

// Hồ sơ chi tiết một bé, dùng chung cho chủ nuôi và người cung cấp
class PetDetailScreen extends ConsumerWidget {
  const PetDetailScreen({super.key, required this.args});

  final PetDetailArgs args;

  bool get _laNcc => args.vai == VaiXemHoSoBe.nguoiCham;
  bool get _chiXem => args.maDon != null;

  // Hạng mục quá hạn lâu nhất
  PreventionRecord? _mucQuaHan(Pet pet) {
    final quaHan = pet.phongBenh
        .where((muc) => muc.trangThai == PreventionStatus.quaHan)
        .toList();
    if (quaHan.isEmpty) return null;
    return quaHan.reduce(
      (a, b) => (a.soNgayConLai ?? 0) <= (b.soNgayConLai ?? 0) ? a : b,
    );
  }

  List<PetDocument> _giayTo(Pet pet) => giayToCuaBe(pet.phongBenh);

  // Mở cả chồng ảnh của một hạng mục
  Future<void> _xemGiayTo(BuildContext context, PetDocumentGroup nhom) =>
      showPhotoViewer(
        context,
        anh: [for (final muc in nhom.anh) muc.anh],
        phuDe: preventionPhotoLabel(context, nhom.hangMuc),
      );

  // Xoá hồ sơ
  Future<void> _xoaHoSo(BuildContext context, WidgetRef ref, Pet pet) async {
    if (pet.donDangChay case final don?) {
      final xemDon = await showBlockDeletePetSheet(context, pet, don);
      if (xemDon && context.mounted) baoDangPhatTrien(context);
      return;
    }
    final dongY = await showDeletePetSheet(context, pet);
    if (!dongY || !context.mounted) return;
    try {
      await ref.read(myPetsProvider.notifier).xoa(pet.id);
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(moTaLoiThuCung(context, e))));
      }
    }
  }

  // Sửa hồ sơ dùng lại chính form thêm bé
  void _suaHoSo(BuildContext context, Pet pet) =>
      context.push(AppRoutes.addPet, extra: pet);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pet = ref.watch(petTheoIdProvider(args.petId)) ?? args.pet;
    if (pet == null) {
      return const Scaffold(
        body: SafeArea(child: AppSkeletonList(soThe: 4, caoThe: 96)),
      );
    }
    final quaHan = _mucQuaHan(pet);
    final giayTo = _giayTo(pet);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: _laNcc ? l10n.hoSoCuaBe(pet.name) : pet.name,
              subtitle: switch ((_laNcc, args.maDon)) {
                (true, final ma?) => l10n.donMaBanDaNhan(ma),
                (true, _) => l10n.hoSoCuaBe(pet.name),
                (false, final ma?) => l10n.trongDonMa(ma),
                (false, _) => l10n.hoSoThuCungCuaBan,
              },
              action: _laNcc || _chiXem
                  ? null
                  : IconButton(
                      onPressed: () => _suaHoSo(context, pet),
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
                  PetDetailHero(pet: pet),
                  // Dải ảnh của bé chỉ có ở bản chủ nuôi
                  if (!_laNcc && pet.anh.isNotEmpty) _DaiAnhBe(pet: pet),
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
                        if (pet.luuYChamSoc case final luuY?) ...[
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
                        InfoRowGroup(dong: _thongTinCoBan(context, pet)),
                        const SizedBox(height: AppSpacing.cardPadding),
                        Text(l10n.mucSucKhoe, style: AppTextStyles.h3),
                        InfoRowGroup(dong: _sucKhoe(context, pet)),
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
                                l10n.soMuc('${pet.phongBenh.length}'),
                                style: AppTextStyles.captionSm,
                              ),
                          ],
                        ),
                        if (pet.phongBenh.isEmpty)
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
                          PreventionSummaryRows(danhSach: pet.phongBenh),
                        const SizedBox(height: AppSpacing.cardPadding),
                        Text(l10n.giayToCuaBe, style: AppTextStyles.label),
                        const SizedBox(height: AppSpacing.itemGap),
                        if (giayTo.isEmpty)
                          Text(l10n.chuaCapNhat, style: AppTextStyles.captionSm)
                        else
                          PetDocumentsSection(
                            giayTo: giayTo,
                            onXemNhom: (nhom) => _xemGiayTo(context, nhom),
                            chiLuoiAnh: true,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_laNcc)
              BottomActionBar(
                child: AppButton(
                  text: l10n.nhanChoChuNuoi,
                  outlined: true,
                  color: AppColors.primaryColor,
                  onTap: () => baoDangPhatTrien(context),
                ),
              )
            else if (!_chiXem)
              BottomActionBar(
                child: AppButton(
                  text: l10n.xoaHoSoCuaBe(pet.name),
                  icon: Icons.delete_outline,
                  outlined: true,
                  color: AppColors.accent,
                  onTap: () => _xoaHoSo(context, ref, pet),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<InfoRow> _thongTinCoBan(BuildContext context, Pet pet) {
    final l10n = context.l10n;
    final loai = tenLoai(l10n, pet.species);
    final gioiTinh = pet.gender == PetGender.male ? l10n.duc : l10n.cai;
    return [
      (nhan: l10n.loaiVaGiong, giaTri: '$loai ${tenGiong(context, pet.breed)}'),
      (nhan: l10n.canNang, giaTri: l10n.soKgCanNang(canNangGon(pet.weightKg))),
      (
        nhan: l10n.gioiTinhVaTuoiNhan,
        giaTri: pet.birthDate == null
            ? gioiTinh
            : l10n.gioiTinhVaTuoiGiaTri(gioiTinh, tuoiBe(context, pet)),
      ),
      (
        nhan: l10n.trietSan,
        giaTri: pet.daTrietSan ? l10n.roi : l10n.chuaTrietSan,
      ),
    ];
  }

  List<InfoRow> _sucKhoe(BuildContext context, Pet pet) {
    final l10n = context.l10n;
    return [
      (
        nhan: l10n.tinhTrang,
        giaTri: pet.dangDieuTri ? l10n.dangDieuTri : l10n.binhThuong,
      ),
      (nhan: l10n.benhNenDiUngNhan, giaTri: pet.benhNen ?? l10n.khongCo),
      (nhan: l10n.thuocDangDung, giaTri: pet.thuocDangDung ?? l10n.khongCo),
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
