import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/features/search/data/search_suggestions.dart';
import 'package:petcare_app/features/search/providers/search_history_provider.dart';
import 'package:petcare_app/features/search/providers/search_results_provider.dart';
import 'package:petcare_app/features/search/widgets/search_field.dart';
import 'package:petcare_app/features/search/widgets/search_result_view.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/service_category_row.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.maDichVu, this.maSapXep});

  final String? maDichVu;
  final String? maSapXep;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const Duration _doTre = Duration(milliseconds: 300);

  final TextEditingController _controller = TextEditingController();
  Timer? _henGio;

  String _tuKhoa = '';
  String _tuKhoaTim = '';
  bool _daVaoKetQua = false;

  late BoLocTimKiem _boLoc = BoLocTimKiem(
    dichVu: _dichVuTuMa(widget.maDichVu),
    sapXep: _sapXepTuMa(widget.maSapXep),
  );

  @override
  void initState() {
    super.initState();
    _daVaoKetQua = widget.maDichVu != null || widget.maSapXep != null;
  }

  static MucLocDichVu? _dichVuTuMa(String? ma) => switch (ma) {
    'walking' => MucLocDichVu.datDiDao,
    'boarding' => MucLocDichVu.trongGiu,
    'grooming' => MucLocDichVu.catTiaTatCa,
    _ => null,
  };

  static SapXepKetQua _sapXepTuMa(String? ma) => switch (ma) {
    'nearest' => SapXepKetQua.ganNhat,
    'rating' => SapXepKetQua.danhGiaCao,
    'completed' => SapXepKetQua.nhieuDon,
    'cancelRate' => SapXepKetQua.itHuyMuon,
    _ => SapXepKetQua.deXuat,
  };

  @override
  void dispose() {
    _henGio?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _khiGo(String giaTri) {
    _henGio?.cancel();
    final khoa = giaTri.trim();
    _henGio = Timer(_doTre, () {
      if (mounted) setState(() => _tuKhoa = khoa);
    });
    if (khoa.isEmpty) {
      setState(() {
        _tuKhoa = '';
        _tuKhoaTim = '';
      });
    }
  }

  void _timTheoTuKhoa(String tuKhoa) {
    _henGio?.cancel();
    final khoa = tuKhoa.trim();
    if (khoa.isEmpty) return;
    FocusScope.of(context).unfocus();
    _controller.text = khoa;
    ref.read(lichSuTimProvider.notifier).them(khoa);
    setState(() {
      _tuKhoa = khoa;
      _tuKhoaTim = khoa;
      _daVaoKetQua = true;
    });
  }

  void _datBoLoc(BoLocTimKiem moi) {
    final be = ref.read(myPetsProvider).asData?.value ?? const <Pet>[];
    setState(() => _boLoc = moi.chuanHoaLoai(be));
  }

  void _locTheoDichVu(LoaiDichVu loai) {
    FocusScope.of(context).unfocus();
    _datBoLoc(_boLoc.copyWith(dichVu: loai.mucLoc));
    setState(() => _daVaoKetQua = true);
  }

  Future<void> _xoaLichSuTim() async {
    final dongY = await showConfirmDialog(
      context,
      title: context.l10n.xoaLichSuTim,
      message: context.l10n.moTaXoaLichSuTim,
      confirmLabel: context.l10n.xoa,
      icon: Icons.delete_outline_rounded,
      danger: true,
    );
    if (!dongY || !mounted) return;
    await ref.read(lichSuTimProvider.notifier).xoaHet();
  }

  bool get _dangApBoLoc =>
      _boLoc.dichVu != null ||
      _boLoc.beDaChon.isNotEmpty ||
      _boLoc.soNgay > 0 ||
      _boLoc.soBe > 0 ||
      _boLoc.mucCan.isNotEmpty ||
      _boLoc.giaTu != null ||
      _boLoc.giaDen != null;

  Future<void> _moTrangBoLoc() async {
    FocusScope.of(context).unfocus();
    final ketQua = await context.push<BoLocTimKiem>(
      AppRoutes.searchFilter,
      extra: _boLoc,
    );
    if (ketQua == null || !mounted) return;
    _datBoLoc(ketQua);
    setState(() => _daVaoKetQua = true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      header: SearchField(
        controller: _controller,
        onChanged: _khiGo,
        onSubmitted: _timTheoTuKhoa,
        onFilter: _moTrangBoLoc,
        filterActive: _dangApBoLoc,
        autofocus: !_daVaoKetQua,
      ),
      body: _noiDung(),
    );
  }

  Widget _noiDung() {
    final l10n = context.l10n;
    if (!_daVaoKetQua) {
      final pets = ref.watch(myPetsProvider).asData?.value ?? const <Pet>[];
      final lichSu = ref.watch(lichSuTimProvider).asData?.value ?? const [];
      if (_tuKhoa.isEmpty) {
        return _GoiYBanDau(
          lichSuTim: lichSu,
          goiYChoBan: SearchSuggestions.choBan(l10n, pets),
          onChonTuKhoa: _timTheoTuKhoa,
          onChonDanhMuc: _locTheoDichVu,
          onXoaLichSu: _xoaLichSuTim,
        );
      }
      final goiY = SearchSuggestions.theoTuKhoa(l10n, _tuKhoa, lichSu);
      if (goiY.isEmpty) {
        return _GoiYTuKhoa(goiY: [_tuKhoa], onChonTuKhoa: _timTheoTuKhoa);
      }
      return _GoiYTuKhoa(goiY: goiY, onChonTuKhoa: _timTheoTuKhoa);
    }
    return _danhSachKetQua();
  }

  ({double? lat, double? lng}) get _tamTim {
    final ds = ref.watch(savedAddressesProvider).asData?.value ?? const [];
    if (ds.isEmpty) return (lat: null, lng: null);
    final macDinh = ds.firstWhere((e) => e.isDefault, orElse: () => ds.first);
    return (lat: macDinh.lat, lng: macDinh.lng);
  }

  Widget _danhSachKetQua() {
    final tam = _tamTim;
    final yeuCau = YeuCauTim(
      boLoc: _boLoc,
      tuKhoa: _tuKhoaTim.isEmpty ? null : _tuKhoaTim,
      lat: tam.lat,
      lng: tam.lng,
    );
    final async = ref.watch(ketQuaTimProvider(yeuCau));
    final trang = async.asData?.value;
    return SearchResultView(
      nguoiCham: trang?.items ?? const [],
      tongSo: trang?.total ?? 0,
      dangTai: async.isLoading,
      coLoi: async.hasError,
      onThuLai: () => ref.invalidate(ketQuaTimProvider(yeuCau)),
      dangTaiThem: trang?.dangTaiThem ?? false,
      boLoc: _boLoc,
      onDoiBoLoc: _datBoLoc,
      onTaiThem: () => ref.read(ketQuaTimProvider(yeuCau).notifier).taiThem(),
      onChonTuKhoa: _timTheoTuKhoa,
    );
  }
}

class _GoiYBanDau extends StatelessWidget {
  const _GoiYBanDau({
    required this.lichSuTim,
    required this.goiYChoBan,
    required this.onChonTuKhoa,
    required this.onChonDanhMuc,
    required this.onXoaLichSu,
  });

  final List<String> lichSuTim;
  final List<String> goiYChoBan;
  final ValueChanged<String> onChonTuKhoa;
  final ValueChanged<LoaiDichVu> onChonDanhMuc;
  final VoidCallback onXoaLichSu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      children: [
        if (lichSuTim.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(l10n.timKiemGanDay, style: AppTextStyles.h3),
              ),
              TextButton(
                onPressed: onXoaLichSu,
                child: Text(
                  l10n.xoa,
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.textGap),
          _HangChip(tuKhoas: lichSuTim, onChon: onChonTuKhoa),
          const SizedBox(height: AppSpacing.groupGap),
        ],
        Text(l10n.goiYDanhChoBan, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.titleGap),
        const SizedBox(height: AppSpacing.textGap),
        _HangChip(tuKhoas: goiYChoBan, onChon: onChonTuKhoa),
        const SizedBox(height: AppSpacing.groupGap),
        Text(l10n.danhMuc, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.titleGap),
        ServiceCategoryRow(onChon: onChonDanhMuc),
      ],
    );
  }
}

class _GoiYTuKhoa extends StatelessWidget {
  const _GoiYTuKhoa({required this.goiY, required this.onChonTuKhoa});

  final List<String> goiY;
  final ValueChanged<String> onChonTuKhoa;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      itemCount: goiY.length,
      itemBuilder: (context, index) => _DongGoiY(
        tuKhoa: goiY[index],
        onTap: () => onChonTuKhoa(goiY[index]),
      ),
    );
  }
}

class _HangChip extends StatelessWidget {
  const _HangChip({required this.tuKhoas, this.onChon});

  final List<String> tuKhoas;
  final ValueChanged<String>? onChon;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.labelGap,
      runSpacing: AppSpacing.labelGap,
      children: [
        for (final tuKhoa in tuKhoas)
          ActionChip(
            label: Text(tuKhoa),
            // Bỏ vùng chạm 48px mặc định, nếu không chip bị kéo cao và thưa
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () =>
                onChon == null ? baoDangPhatTrien(context) : onChon!(tuKhoa),
          ),
      ],
    );
  }
}

// Một dòng gợi ý từ khoá kèm icon kính lúp
class _DongGoiY extends StatelessWidget {
  const _DongGoiY({required this.tuKhoa, required this.onTap});

  final String tuKhoa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Text(
                tuKhoa,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
