import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_service_area.dart';
import 'package:petcare_app/features/search/data/noi_tim_quanh.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

class MapConditionPanel extends StatelessWidget {
  const MapConditionPanel({
    super.key,
    required this.noiTim,
    required this.boLoc,
    required this.danhSachBe,
    required this.onDoiNoiTim,
    required this.onDoiBoLoc,
    required this.onChonNgay,
    required this.onXemKetQua,
    required this.onXoaHet,
  });

  final NoiTimQuanh? noiTim;
  final BoLocTimKiem boLoc;
  final List<Pet> danhSachBe;
  final VoidCallback onDoiNoiTim;
  final ValueChanged<BoLocTimKiem> onDoiBoLoc;
  final VoidCallback onChonNgay;
  final VoidCallback onXemKetQua;
  final VoidCallback onXoaHet;

  bool get _duDieuKien => noiTim != null;

  bool get _daChonBeMeo => danhSachBe.any(
    (be) => boLoc.beDaChon.contains(be.id) && be.species == PetSpecies.cat,
  );

  String _nhanNgay(AppLocalizations l10n) {
    final tu = boLoc.tuNgay;
    final den = boLoc.denNgay;
    if (tu == null || den == null) return l10n.chonNgay;
    return l10n.khoangNgayGon(ngayThang(tu), ngayThang(den));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.timQuanhDau, style: AppTextStyles.h3),
                ),
                TextButton(
                  onPressed: onXoaHet,
                  child: Text(
                    l10n.xoaHet,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            _ONoiTim(noiTim: noiTim, onDoi: onDoiNoiTim),
            const SizedBox(height: AppSpacing.itemGap),
            Text(l10n.dichVu, style: AppTextStyles.captionSm),
            const SizedBox(height: AppSpacing.labelGap),
            Wrap(
              spacing: AppSpacing.labelGap,
              runSpacing: AppSpacing.labelGap,
              children: [
                for (final muc in mucLocChinh)
                  _ChipChon(
                    nhan: muc.ten(l10n),
                    chon: boLoc.dichVu == muc,
                    khoa: muc.chiNhanCho && _daChonBeMeo,
                    onTap: () => onDoiBoLoc(
                      boLoc.copyWith(dichVu: boLoc.dichVu == muc ? null : muc),
                    ),
                  ),
              ],
            ),
            if (boLoc.dichVu == MucLocDichVu.trongGiu) ...[
              const SizedBox(height: AppSpacing.itemGap),
              _BanKinh(
                km: boLoc.banKinhKm,
                onDoi: (v) => onDoiBoLoc(boLoc.copyWith(banKinhKm: v)),
              ),
            ],
            if (danhSachBe.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.itemGap),
              Text(l10n.datChoBeNao, style: AppTextStyles.captionSm),
              const SizedBox(height: AppSpacing.labelGap),
              Wrap(
                spacing: AppSpacing.labelGap,
                runSpacing: AppSpacing.labelGap,
                children: [
                  for (final be in danhSachBe)
                    _ChipBe(
                      be: be,
                      chon: boLoc.beDaChon.contains(be.id),
                      khoa: boLoc.epLoaiCho && be.species == PetSpecies.cat,
                      onTap: () {
                        final chon = {...boLoc.beDaChon};
                        if (!chon.remove(be.id)) chon.add(be.id);
                        onDoiBoLoc(boLoc.copyWith(beDaChon: chon, soBe: 0));
                      },
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.stackGap),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: _nhanNgay(l10n),
                    icon: Icons.calendar_today_outlined,
                    outlined: true,
                    height: 48,
                    onTap: onChonNgay,
                  ),
                ),
                const SizedBox(width: AppSpacing.itemGap),
                Expanded(
                  child: AppButton(
                    text: l10n.xemKetQua,
                    height: 48,
                    enabled: _duDieuKien,
                    onTap: onXemKetQua,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ONoiTim extends StatelessWidget {
  const _ONoiTim({required this.noiTim, required this.onDoi});

  final NoiTimQuanh? noiTim;
  final VoidCallback onDoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coNoi = noiTim != null && !noiTim!.laVungDangXem;
    return InkWell(
      onTap: onDoi,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.itemGap),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(color: AppColors.neutralLight, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 20,
              color: coNoi ? AppColors.primaryColor : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coNoi ? noiTim!.moTa! : l10n.chuaCoDiaChiNao,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    coNoi
                        ? (noiTim!.moTaPhu ?? '')
                        : l10n.chamDeNhapDiaChiTimQuanh,
                    style: AppTextStyles.captionSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              coNoi ? l10n.doi : l10n.nhap,
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BanKinh extends ConsumerWidget {
  const _BanKinh({required this.km, required this.onDoi});

  static const double _min = minServiceRadiusKm * 1.0;

  final double km;
  final ValueChanged<double> onDoi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final max = ref.watch(cauHinhNghiepVuProvider).banKinhTimToiDaKm * 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.banKinh, style: AppTextStyles.captionSm)),
            Text(
              l10n.soKm('${km.round()}'),
              style: AppTextStyles.label.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
        Slider(value: km, min: _min, max: max, onChanged: onDoi),
        Row(
          children: [
            Text(l10n.soKm('${_min.round()}'), style: AppTextStyles.captionSm),
            const Spacer(),
            Text(l10n.soKm('${max.round()}'), style: AppTextStyles.captionSm),
          ],
        ),
      ],
    );
  }
}

class _ChipChon extends StatelessWidget {
  const _ChipChon({
    required this.nhan,
    required this.chon,
    required this.onTap,
    this.khoa = false,
  });

  final String nhan;
  final bool chon;
  final VoidCallback onTap;
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    final the = Material(
      color: chon ? AppColors.cardMint : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: chon ? AppColors.primaryColor : AppColors.neutralLight,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: khoa ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            nhan,
            style: (chon ? AppTextStyles.labelSm : AppTextStyles.captionSm)
                .copyWith(
                  color: chon ? AppColors.primaryColor : AppColors.textPrimary,
                ),
          ),
        ),
      ),
    );
    return khoa ? Opacity(opacity: 0.4, child: the) : the;
  }
}

// Chip một bé: avatar tròn kèm tên
class _ChipBe extends StatelessWidget {
  const _ChipBe({
    required this.be,
    required this.chon,
    required this.onTap,
    this.khoa = false,
  });

  final Pet be;
  final bool chon;
  final VoidCallback onTap;
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    if (khoa) return Opacity(opacity: 0.4, child: _chip());
    return _chip();
  }

  Widget _chip() {
    return Material(
      color: chon ? AppColors.cardMint : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
          color: chon ? AppColors.primaryColor : AppColors.neutralLight,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: khoa ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PetAvatar(imageUrl: be.avatar, name: be.name, size: 24),
              const SizedBox(width: AppSpacing.labelGap),
              Text(
                be.name,
                style: (chon ? AppTextStyles.labelSm : AppTextStyles.captionSm)
                    .copyWith(
                      color: chon
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
