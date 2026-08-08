import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/features/search/widgets/date_range_sheet.dart';
import 'package:petcare_app/features/search/widgets/filter_dropdown_panel.dart';
import 'package:petcare_app/features/search/widgets/pet_count_sheet.dart';
import 'package:petcare_app/features/search/widgets/search_empty_result.dart';
import 'package:petcare_app/features/search/widgets/search_filter_bar.dart';
import 'package:petcare_app/features/search/widgets/sitter_result_card.dart';
import 'package:petcare_app/features/search/widgets/sort_filter_sheet.dart';
import 'package:petcare_app/shared/utils/diem_so.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

class SearchResultView extends StatefulWidget {
  const SearchResultView({
    super.key,
    required this.nguoiCham,
    required this.tongSo,
    required this.dangTai,
    required this.coLoi,
    required this.onThuLai,
    required this.dangTaiThem,
    required this.boLoc,
    required this.onDoiBoLoc,
    required this.onTaiThem,
    required this.onChonTuKhoa,
  });

  final List<SitterResult> nguoiCham;
  final int tongSo;
  final bool dangTai;
  final bool coLoi;
  final VoidCallback onThuLai;
  final bool dangTaiThem;
  final BoLocTimKiem boLoc;
  final ValueChanged<BoLocTimKiem> onDoiBoLoc;
  final VoidCallback onTaiThem;
  final ValueChanged<String> onChonTuKhoa;

  @override
  State<SearchResultView> createState() => _SearchResultViewState();
}

class _SearchResultViewState extends State<SearchResultView> {
  static const double _nguongTaiThem = 400;

  final ScrollController _cuon = ScrollController();

  BoLocTimKiem get _boLoc => widget.boLoc;
  OLoc? _oDangMo;

  @override
  void initState() {
    super.initState();
    _cuon.addListener(_khiCuon);
  }

  @override
  void dispose() {
    _cuon
      ..removeListener(_khiCuon)
      ..dispose();
    super.dispose();
  }

  void _khiCuon() {
    if (!_cuon.hasClients) return;
    final conLai = _cuon.position.maxScrollExtent - _cuon.position.pixels;
    if (conLai <= _nguongTaiThem) widget.onTaiThem();
  }

  void _doiLoc(BoLocTimKiem moi) {
    setState(() => _oDangMo = null);
    widget.onDoiBoLoc(moi);
  }

  Future<void> _moO(OLoc o) async {
    FocusScope.of(context).unfocus();
    switch (o) {
      case OLoc.ngay:
        setState(() => _oDangMo = null);
        final ketQua = await showDateRangeSheet(
          context: context,
          banDau: KhoangNgay(tu: _boLoc.tuNgay, den: _boLoc.denNgay),
        );
        if (ketQua == null || !mounted) return;
        _doiLoc(_boLoc.copyWith(tuNgay: ketQua.tu, denNgay: ketQua.den));
      case OLoc.soBe:
        setState(() => _oDangMo = null);
        final ketQua = await showPetCountSheet(
          context: context,
          banDau: _boLoc.soBeHieuLuc,
        );
        if (ketQua == null || !mounted) return;
        _doiLoc(_boLoc.copyWith(soBe: ketQua, beDaChon: const {}));
      case OLoc.dichVu:
      case OLoc.danhGia:
        setState(() => _oDangMo = _oDangMo == o ? null : o);
    }
  }

  Future<void> _moSapXep() async {
    FocusScope.of(context).unfocus();
    setState(() => _oDangMo = null);
    final ketQua = await showSortFilterSheet(context: context, boLoc: _boLoc);
    if (ketQua == null || !mounted) return;
    _doiLoc(ketQua);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ketQua = widget.nguoiCham;
    return Stack(
      children: [
        Column(
          children: [
            SearchFilterBar(
              nhanCuaO: (o) => _nhanO(l10n, o),
              oDangChon: _oDaLoc(),
              oDangMo: _oDangMo,
              tinCay: _boLoc.chiTinCay,
              nhanTinCay: l10n.nhanTinCay,
              onMoO: _moO,
              onDoiTinCay: (bat) => _doiLoc(_boLoc.copyWith(chiTinCay: bat)),
              onMoSapXep: _moSapXep,
              sapXepDangBat: _sapXepDangBat,
            ),
            const AppDongKe(),
            _DongDem(
              so: widget.tongSo,
              onMoBanDo: () {
                FocusScope.of(context).unfocus();
                context.push(AppRoutes.searchMap, extra: _boLoc);
              },
            ),
            Expanded(child: _vungDanhSach(ketQua)),
          ],
        ),
        if (_oDangMo != null)
          Positioned(
            top: SearchFilterBar.chieuCao,
            left: 0,
            right: 0,
            bottom: 0,
            child: _panel(l10n, _oDangMo!),
          ),
      ],
    );
  }

  Widget _vungDanhSach(List<SitterResult> ketQua) {
    if (ketQua.isEmpty) {
      if (widget.dangTai) {
        return const AppSkeletonList(soThe: 4, caoThe: 132);
      }
      if (widget.coLoi) return AppNetworkError(onRetry: widget.onThuLai);
      return SearchEmptyResult(onChonTuKhoa: widget.onChonTuKhoa);
    }
    return ListView.builder(
      controller: _cuon,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        AppSpacing.groupGap,
      ),
      itemCount: ketQua.length + (widget.dangTaiThem ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= ketQua.length) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.stackGap),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
          child: SitterResultCard(
            nguoiCham: ketQua[index],
            soNgayChon: _boLoc.soNgay,
          ),
        );
      },
    );
  }

  Widget _panel(AppLocalizations l10n, OLoc o) => switch (o) {
    OLoc.dichVu => FilterDropdownPanel<MucLocDichVu>(
      muc: [
        for (final muc in mucLocChinh)
          MucChonLoc(giaTri: muc, nhan: muc.ten(l10n)),
      ],
      dangChon: _boLoc.dichVu?.mucChinh,
      onChon: (v) => _doiLoc(_boLoc.copyWith(dichVu: v)),
      onDong: () => setState(() => _oDangMo = null),
    ),
    OLoc.danhGia => FilterDropdownPanel<double>(
      muc: [
        for (final diem in const [5.0, 4.0, 3.0, 2.0, 1.0])
          MucChonLoc(
            giaTri: diem,
            nhan: diem == 5.0 ? soDiem(diem) : l10n.diemTroLen(soDiem(diem)),
            dauDong: DaySao(so: diem.round()),
          ),
      ],
      dangChon: _boLoc.diemToiThieu,
      onChon: (v) => _doiLoc(_boLoc.copyWith(diemToiThieu: v)),
      onDong: () => setState(() => _oDangMo = null),
    ),
    OLoc.ngay || OLoc.soBe => const SizedBox.shrink(),
  };

  bool get _sapXepDangBat =>
      _boLoc.sapXep != SapXepKetQua.deXuat ||
      _boLoc.nhanCho ||
      _boLoc.nhanMeo ||
      _boLoc.chiTinCay ||
      _boLoc.dichVu == MucLocDichVu.chiTam;

  Set<OLoc> _oDaLoc() => {
    if (_boLoc.dichVu != null) OLoc.dichVu,
    if (_boLoc.soNgay > 0) OLoc.ngay,
    if (_boLoc.soBeHieuLuc > 0) OLoc.soBe,
    if (_boLoc.diemToiThieu != null) OLoc.danhGia,
  };

  String _nhanO(AppLocalizations l10n, OLoc o) => switch (o) {
    OLoc.dichVu => _boLoc.dichVu?.ten(l10n) ?? l10n.dichVu,
    OLoc.ngay =>
      _boLoc.soNgay == 0
          ? l10n.moiNgayLoc
          : '${ngayThang(_boLoc.tuNgay!)} - ${ngayThang(_boLoc.denNgay!)}',
    OLoc.soBe =>
      _boLoc.soBeHieuLuc == 0
          ? l10n.locSoBe
          : l10n.soBe('${_boLoc.soBeHieuLuc}'),
    OLoc.danhGia =>
      _boLoc.diemToiThieu == null
          ? l10n.danhGia
          : l10n.diemTroLen(soDiem(_boLoc.diemToiThieu!)),
  };
}

class _DongDem extends StatelessWidget {
  const _DongDem({required this.so, required this.onMoBanDo});

  final int so;
  final VoidCallback onMoBanDo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(l10n.soNguoiChamPhuHop(so), style: AppTextStyles.label),
          ),
          InkWell(
            onTap: onMoBanDo,
            child: Row(
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: AppSpacing.textGap),
                Text(
                  l10n.banDo,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
