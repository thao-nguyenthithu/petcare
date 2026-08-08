import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/pet_summary.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _avatar = 44;
const double _rongNhanToiDa = 150;

class BookingPetNotes extends StatefulWidget {
  const BookingPetNotes({
    super.key,
    required this.pets,
    this.onSuaHoSo,
    this.tieuDe,
    this.moTa,
    this.ghiChuCuoi,
  });
  final List<Pet> pets;
  final void Function(Pet be)? onSuaHoSo;
  final String? tieuDe;
  final String? moTa;
  final String? ghiChuCuoi;

  @override
  State<BookingPetNotes> createState() => _BookingPetNotesState();
}

class _BookingPetNotesState extends State<BookingPetNotes> {
  String? _mo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.tieuDe ?? l10n.luuYChamSocTungBe, style: AppTextStyles.h3),
        const SizedBox(height: 6),
        if (widget.pets.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: AppNoteBox(text: l10n.luuYLayTuHoSoBe),
          )
        else ...[
          Text(
            widget.moTa ?? l10n.chamMotBeDeXemDayDu,
            style: AppTextStyles.captionSm,
          ),
          const SizedBox(height: 14),
          for (final (i, be) in widget.pets.indexed) ...[
            if (i != 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: AppDongKe(),
              ),
            _DongBe(
              be: be,
              mo: _mo == be.id,
              onTap: () => setState(() => _mo = _mo == be.id ? null : be.id),
              onSua: widget.onSuaHoSo == null
                  ? null
                  : () => widget.onSuaHoSo!(be),
            ),
          ],
          if (widget.ghiChuCuoi case final ghiChu?) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(ghiChu, style: AppTextStyles.captionSm)),
              ],
            ),
          ],
        ],
      ],
    );
  }
}

class _DongBe extends StatelessWidget {
  const _DongBe({
    required this.be,
    required this.mo,
    required this.onTap,
    required this.onSua,
  });

  final Pet be;
  final bool mo;
  final VoidCallback onTap;
  final VoidCallback? onSua;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = petPreventionStatus(be);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PetAvatar(imageUrl: be.avatar, name: be.name, size: _avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(be.name, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      petSummary(context, be),
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!mo) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (be.luuYChamSoc?.isNotEmpty ?? false)
                            Expanded(
                              child: Text(
                                be.luuYChamSoc!,
                                style: AppTextStyles.captionSm,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          else
                            const Spacer(),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _rongNhanToiDa,
                            ),
                            child: _ChipPhongBenh(be: be, trangThai: trangThai),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (mo && onSua != null)
                InkWell(
                  onTap: onSua,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 17,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              Icon(
                mo
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        if (mo) ...[
          const SizedBox(height: 10),
          if (be.luuYChamSoc?.isNotEmpty ?? false)
            _MucLuuY(
              icon: Icons.sticky_note_2_outlined,
              nhan: l10n.luuYChamSoc,
              noiDung: be.luuYChamSoc!,
            ),
          if (be.thuocDangDung?.isNotEmpty ?? false)
            _MucLuuY(
              icon: Icons.medication_outlined,
              nhan: l10n.thuocDangDung,
              noiDung: be.thuocDangDung!,
            ),
          if (be.benhNen?.isNotEmpty ?? false)
            _MucLuuY(
              icon: Icons.no_food_outlined,
              nhan: l10n.benhNenDiUng,
              noiDung: be.benhNen!,
            ),
          _MucLuuY(
            icon: petPreventionStyle(trangThai).icon ?? Icons.vaccines_outlined,
            nhan: l10n.phongBenh,
            noiDung: _moTaPhongBenh(context, be, trangThai),
            mau: petPreventionStyle(trangThai).mau,
            mauNoiDung: trangThai == PetPreventionStatus.quaHan
                ? AppColors.accent
                : null,
          ),
        ],
      ],
    );
  }
}

String _moTaPhongBenh(
  BuildContext context,
  Pet be,
  PetPreventionStatus trangThai,
) {
  final l10n = context.l10n;
  if (trangThai != PetPreventionStatus.quaHan) {
    return petPreventionLabelChiTiet(context, be);
  }
  final muc = be.phongBenh.firstWhere(
    (m) => m.trangThai == PreventionStatus.quaHan,
  );
  final soNgay = muc.soNgayConLai ?? 0;
  return '${l10n.quaHanHangMucSoNgay(tenCuaHangMuc(context, muc), '${-soNgay}')}'
      ' · ${l10n.nccDuocTuChoiViLyDoNay}';
}

class _MucLuuY extends StatelessWidget {
  const _MucLuuY({
    required this.icon,
    required this.nhan,
    required this.noiDung,
    this.mau,
    this.mauNoiDung,
  });

  final IconData icon;
  final String nhan;
  final String noiDung;
  final Color? mau;
  final Color? mauNoiDung;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: mau ?? AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                nhan,
                style: AppTextStyles.captionSm.copyWith(
                  color: mau ?? AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(noiDung, style: AppTextStyles.label.copyWith(color: mauNoiDung)),
        ],
      ),
    );
  }
}

class _ChipPhongBenh extends StatelessWidget {
  const _ChipPhongBenh({required this.be, required this.trangThai});

  final Pet be;
  final PetPreventionStatus trangThai;

  @override
  Widget build(BuildContext context) {
    final kieu = petPreventionStyle(trangThai);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kieu.icon case final icon?) ...[
          Icon(icon, size: 13, color: kieu.mau),
          const SizedBox(width: 3),
        ],
        Flexible(
          child: Text(
            petPreventionLabel(context, be),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.captionSm.copyWith(color: kieu.mau),
          ),
        ),
      ],
    );
  }
}
