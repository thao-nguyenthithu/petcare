import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/features/search/widgets/date_range_sheet.dart';
import 'package:petcare_app/features/search/widgets/filter_pet_picker.dart';
import 'package:petcare_app/features/search/widgets/filter_price_range.dart';
import 'package:petcare_app/features/search/widgets/filter_weight_tiers.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Trang Bộ lọc mở từ nút lọc ở ô tìm
class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key, required this.boLoc});

  final BoLocTimKiem boLoc;

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  late BoLocTimKiem _boLoc = widget.boLoc;
  late MucLocDichVu _dichVu = _tabCua(widget.boLoc.dichVu);

  static MucLocDichVu _tabCua(MucLocDichVu? muc) {
    if (muc == null) return MucLocDichVu.datDiDao;
    return muc.loai == LoaiDichVu.catTia ? MucLocDichVu.catTiaTatCa : muc;
  }

  bool _daChonBeMeo(List<Pet> danhSachBe) => danhSachBe.any(
    (be) => _boLoc.beDaChon.contains(be.id) && be.species == PetSpecies.cat,
  );

  void _doiChonBe(Pet be) {
    setState(() {
      final chon = {..._boLoc.beDaChon};
      if (!chon.remove(be.id)) chon.add(be.id);
      _boLoc = _boLoc.copyWith(beDaChon: chon, soBe: 0);
    });
  }

  Future<void> _chonNgay() async {
    final ketQua = await showDateRangeSheet(
      context: context,
      banDau: KhoangNgay(tu: _boLoc.tuNgay, den: _boLoc.denNgay),
    );
    if (ketQua == null || !mounted) return;
    setState(
      () => _boLoc = _boLoc.copyWith(tuNgay: ketQua.tu, denNgay: ketQua.den),
    );
  }

  void _datLai() => setState(() {
    _boLoc = const BoLocTimKiem();
    _dichVu = MucLocDichVu.datDiDao;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final danhSachBe = ref.watch(myPetsProvider).asData?.value ?? const <Pet>[];
    return AppScreen(
      header: Column(
        children: [
          _Header(onDatLai: _datLai),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.stackGap,
          AppSpacing.screenPadding,
          AppSpacing.groupGap,
        ),
        children: [
          FilterPetPicker(
            danhSach: danhSachBe,
            daChon: _boLoc.beDaChon,
            chiNhanCho: _dichVu.chiNhanCho,
            soBeNhapTay: _boLoc.soBe,
            onDoiChon: _doiChonBe,
            onThemBe: () => context.push(AppRoutes.addPet),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          const AppDongKe(),
          const SizedBox(height: AppSpacing.stackGap),
          Text(l10n.dichVu, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.labelGap),
          _TabDichVu(
            dangChon: _dichVu,
            khoa: _daChonBeMeo(danhSachBe)
                ? const {MucLocDichVu.datDiDao}
                : const {},
            onChon: (v) => setState(() => _dichVu = v),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          if (_dichVu.loai == LoaiDichVu.catTia) ...[
            FilterWeightTiers(
              daTick: _boLoc.mucCan,
              theoBeDaChon: _mucCanCuaBeDaChon(danhSachBe),
              onDoi: (muc) =>
                  setState(() => _boLoc = _boLoc.copyWith(mucCan: muc)),
            ),
            const SizedBox(height: AppSpacing.stackGap),
          ],
          Text(_tieuDeNgay(l10n), style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.textGap),
          Text(l10n.moTaChonKhoangNgay, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.itemGap),
          Row(
            children: [
              Expanded(
                child: _ONgay(
                  nhan: _dichVu == MucLocDichVu.trongGiu
                      ? l10n.ngayNhanBe
                      : l10n.tuNgay,
                  ngay: _boLoc.tuNgay,
                  onTap: _chonNgay,
                ),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: _ONgay(
                  nhan: _dichVu == MucLocDichVu.trongGiu
                      ? l10n.ngayTraBe
                      : l10n.denNgay,
                  ngay: _boLoc.denNgay,
                  onTap: _chonNgay,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          FilterPriceRange(
            tieuDe: _dichVu.loai == LoaiDichVu.catTia
                ? l10n.giaMoiBe
                : l10n.giaMoiLuot,
            moTa: _moTaGia(l10n),
            giaTu: _boLoc.giaTu,
            giaDen: _boLoc.giaDen,
            onDoi: (tu, den) => setState(
              () => _boLoc = _boLoc.copyWith(giaTu: tu, giaDen: den),
            ),
          ),
        ],
      ),
      bottomBar: BottomActionBar(
        child: AppButton(
          text: l10n.apDung,
          onTap: () => context.pop(_boLoc.copyWith(dichVu: _dichVu)),
        ),
      ),
    );
  }

  // Mức cân suy từ các bé đã chọn
  Set<MucCan> _mucCanCuaBeDaChon(List<Pet> danhSach) => {
    for (final be in danhSach.where((p) => _boLoc.beDaChon.contains(p.id)))
      MucCanHienThi.tuCanNang(be.weightKg),
  };

  String _tieuDeNgay(AppLocalizations l10n) =>
      _dichVu == MucLocDichVu.trongGiu ? l10n.khoangNgayGuiBe : l10n.khoangNgay;

  String _moTaGia(AppLocalizations l10n) => switch (_dichVu) {
    MucLocDichVu.datDiDao => l10n.moTaGiaDatDiDao,
    MucLocDichVu.trongGiu => l10n.moTaGiaTrongGiu,
    MucLocDichVu.tamVaCatTia ||
    MucLocDichVu.chiTam ||
    MucLocDichVu.catTiaTatCa => l10n.moTaGiaGrooming,
  };
}

class _Header extends StatelessWidget {
  const _Header({required this.onDatLai});

  final VoidCallback onDatLai;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.labelGap,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
      ),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: AppSpacing.labelGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.boLoc, style: AppTextStyles.h3),
                Text(l10n.moTaBoLoc, style: AppTextStyles.captionSm),
              ],
            ),
          ),
          TextButton(
            onPressed: onDatLai,
            child: Text(
              l10n.datLai,
              style: AppTextStyles.label.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

// Ba dịch vụ dạng tab
class _TabDichVu extends StatelessWidget {
  const _TabDichVu({
    required this.dangChon,
    required this.onChon,
    this.khoa = const {},
  });

  // Trang lọc hỏi ba dịch vụ chính
  static const List<MucLocDichVu> _tab = [
    MucLocDichVu.datDiDao,
    MucLocDichVu.trongGiu,
    MucLocDichVu.catTiaTatCa,
  ];

  final MucLocDichVu dangChon;
  final ValueChanged<MucLocDichVu> onChon;

  final Set<MucLocDichVu> khoa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        for (final muc in _tab)
          Expanded(
            child: InkWell(
              onTap: khoa.contains(muc) ? null : () => onChon(muc),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.itemGap,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: muc == dangChon
                          ? AppColors.primaryColor
                          : AppColors.neutralLight,
                      width: muc == dangChon ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  muc.ten(l10n),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (muc == dangChon
                              ? AppTextStyles.labelSm
                              : AppTextStyles.captionSm)
                          .copyWith(
                            color: khoa.contains(muc)
                                ? AppColors.neutral
                                : (muc == dangChon
                                      ? AppColors.primaryColor
                                      : AppColors.textSecondary),
                          ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ONgay extends StatelessWidget {
  const _ONgay({required this.nhan, required this.ngay, required this.onTap});

  final String nhan;
  final DateTime? ngay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(nhan, style: AppTextStyles.captionSm),
        const SizedBox(height: AppSpacing.textGap),
        Material(
          color: AppColors.surface,
          elevation: 2,
          shadowColor: AppColors.shadow,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.itemGap,
                vertical: 14,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.labelGap),
                  Expanded(
                    child: Text(
                      ngay == null
                          ? '--'
                          : '${thuNgan(l10n, ngay!)} · ${ngayThang(ngay!)}',
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
