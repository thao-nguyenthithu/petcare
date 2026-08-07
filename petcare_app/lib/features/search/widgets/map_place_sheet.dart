import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/services/tra_cuu_dia_chi_service.dart';
import 'package:petcare_app/features/search/data/noi_tim_quanh.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_search_field.dart';

enum ChonNoiTim { viTriHienTai, ghimTrenBanDo, themDiaChiMoi }

class KetQuaChonNoiTim {
  const KetQuaChonNoiTim({this.noiTim, this.hanhDong});

  final NoiTimQuanh? noiTim;
  final ChonNoiTim? hanhDong;
}

Future<KetQuaChonNoiTim?> showMapPlaceSheet({
  required BuildContext context,
  required List<SavedAddress> diaChiDaLuu,
  required String? idDangChon,
}) {
  return showModalBottomSheet<KetQuaChonNoiTim>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        _MapPlaceSheet(diaChiDaLuu: diaChiDaLuu, idDangChon: idDangChon),
  );
}

class _MapPlaceSheet extends StatefulWidget {
  const _MapPlaceSheet({required this.diaChiDaLuu, required this.idDangChon});

  final List<SavedAddress> diaChiDaLuu;
  final String? idDangChon;

  @override
  State<_MapPlaceSheet> createState() => _MapPlaceSheetState();
}

class _MapPlaceSheetState extends State<_MapPlaceSheet> {
  static const Duration _doTre = Duration(milliseconds: 400);

  final TextEditingController _controller = TextEditingController();
  Timer? _henGio;
  List<GoiYDiaDiem> _goiY = const [];
  bool _dangTim = false;

  @override
  void dispose() {
    _henGio?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _khiGo(String giaTri) {
    _henGio?.cancel();
    final khoa = giaTri.trim();
    if (khoa.length < 2) {
      setState(() {
        _goiY = const [];
        _dangTim = false;
      });
      return;
    }
    setState(() => _dangTim = true);
    _henGio = Timer(_doTre, () => _tim(khoa));
  }

  Future<void> _tim(String khoa) async {
    final ketQua = await TraCuuDiaChiService.timDiaDiem(khoa);
    if (!mounted || khoa != _controller.text.trim()) return;
    setState(() {
      _goiY = ketQua;
      _dangTim = false;
    });
  }

  void _chonGoiY(GoiYDiaDiem goiY) {
    final phan = goiY.ten.split(',').map((e) => e.trim()).toList();
    Navigator.pop(
      context,
      KetQuaChonNoiTim(
        noiTim: NoiTimQuanh(
          nguon: NguonNoiTim.ghimTrenBanDo,
          viTri: goiY.viTri,
          moTa: phan.take(2).join(', '),
          moTaPhu: phan.length > 2 ? phan.sublist(2).take(2).join(', ') : null,
        ),
      ),
    );
  }

  void _chonDiaChi(SavedAddress dc) {
    Navigator.pop(
      context,
      KetQuaChonNoiTim(
        noiTim: NoiTimQuanh(
          nguon: NguonNoiTim.diaChiLuu,
          viTri: dc.lat != null && dc.lng != null
              ? LatLng(dc.lat!, dc.lng!)
              : NoiTimQuanh.macDinh,
          moTa: _moTa(dc),
          moTaPhu: dc.isDefault
              ? context.l10n.diaChiMacDinhCuaBan
              : dc.phuongXa,
          idDiaChi: dc.id,
        ),
      ),
    );
  }

  String _moTa(SavedAddress dc) =>
      [dc.soNha, dc.phuongXa].where((e) => e.isNotEmpty).join(', ');

  String _tenNhan(SavedAddress dc) => switch (dc.label) {
    NhanDiaChi.nha => context.l10n.nha,
    NhanDiaChi.congTy => context.l10n.congTy,
    NhanDiaChi.khac => dc.customLabel ?? context.l10n.khac,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingWide,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(l10n.timQuanhDau, style: AppTextStyles.h3),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPaddingWide,
            ),
            child: AppSearchField(
              controller: _controller,
              onChanged: _khiGo,
              hintText: l10n.nhapDiaChiHoacTenKhuVuc,
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                if (_dangTim)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.stackGap),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_goiY.isNotEmpty)
                  for (final g in _goiY)
                    _Dong(
                      icon: Icons.place_outlined,
                      tieuDe: g.ten.split(',').first.trim(),
                      moTa: g.ten,
                      onTap: () => _chonGoiY(g),
                    )
                else ...[
                  _Dong(
                    icon: Icons.my_location_rounded,
                    tieuDe: l10n.viTriHienTai,
                    moTa: l10n.canQuyenTruyCapViTri,
                    onTap: () => Navigator.pop(
                      context,
                      const KetQuaChonNoiTim(hanhDong: ChonNoiTim.viTriHienTai),
                    ),
                  ),
                  if (widget.diaChiDaLuu.isNotEmpty) ...[
                    const AppDongKe(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenPaddingWide,
                        AppSpacing.itemGap,
                        AppSpacing.screenPaddingWide,
                        AppSpacing.textGap,
                      ),
                      child: Text(
                        l10n.diaChiDaLuu,
                        style: AppTextStyles.captionSm,
                      ),
                    ),
                    for (final dc in widget.diaChiDaLuu)
                      _Dong(
                        icon: dc.label == NhanDiaChi.nha
                            ? Icons.home_outlined
                            : Icons.location_on_outlined,
                        tieuDe: '${_tenNhan(dc)} · ${_moTa(dc)}',
                        moTa: dc.isDefault ? l10n.diaChiMacDinhCuaBan : dc.tinh,
                        dangChon: dc.id == widget.idDangChon,
                        onTap: () => _chonDiaChi(dc),
                      ),
                  ],
                  const AppDongKe(),
                  _Dong(
                    icon: Icons.location_on_outlined,
                    tieuDe: l10n.chonTrenBanDo,
                    moTa: l10n.keoGhimToiDungCho,
                    onTap: () => Navigator.pop(
                      context,
                      const KetQuaChonNoiTim(
                        hanhDong: ChonNoiTim.ghimTrenBanDo,
                      ),
                    ),
                  ),
                  _Dong(
                    icon: Icons.add_rounded,
                    tieuDe: l10n.themDiaChiMoi,
                    onTap: () => Navigator.pop(
                      context,
                      const KetQuaChonNoiTim(
                        hanhDong: ChonNoiTim.themDiaChiMoi,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.itemGap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({
    required this.icon,
    required this.tieuDe,
    required this.onTap,
    this.moTa,
    this.dangChon = false,
  });

  final IconData icon;
  final String tieuDe;
  final String? moTa;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPaddingWide,
          vertical: AppSpacing.itemGap,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: dangChon
                  ? AppColors.primaryColor
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tieuDe,
                    style: AppTextStyles.label.copyWith(
                      color: dangChon
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (moTa != null && moTa!.isNotEmpty)
                    Text(
                      moTa!,
                      style: AppTextStyles.captionSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (dangChon)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
