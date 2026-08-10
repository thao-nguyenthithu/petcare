import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_absence.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/shared/widgets/photo_picker_grid.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/icon_text_row.dart';
import 'package:petcare_app/shared/widgets/order_summary_head.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

class SitterAbsenceScreen extends ConsumerStatefulWidget {
  const SitterAbsenceScreen({super.key, required this.bao});

  final BaoVangMat bao;

  @override
  ConsumerState<SitterAbsenceScreen> createState() => _SitterAbsenceState();
}

class _SitterAbsenceState extends ConsumerState<SitterAbsenceScreen> {
  List<Uint8List> _anh = [];
  bool _dangGui = false;

  BaoVangMat get bao => widget.bao;

  bool get _toiBao => bao.loai == LoaiBaoVangMat.toiBao;

  bool get _trongGiu => bao.don.laTrongGiu;

  bool get _duAnh => _anh.length >= soAnhVangMatToiThieu;


  Future<void> _guiBao() async {
    final id = bao.don.bookingId;
    setState(() => _dangGui = true);
    final xong = await chayHanhDongDon(
      context,
      ref,
      id,
      (s) => s.baoVangMat(id, anh: anhMultipart(_anh, 'no-show')),
    );
    if (!mounted) return;
    setState(() => _dangGui = false);
    if (xong) context.pushReplacement(AppRoutes.sitterOrderDetailPath(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = bao.don;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
            child: Row(
              children: [
                const AppBackButton(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _trongGiu
                            ? (_toiBao
                                  ? l10n.chuNuoiChuaMangBeToi
                                  : l10n.chuNuoiBaoBanKhongCoNha)
                            : (_toiBao
                                  ? l10n.chuNuoiKhongCoMat
                                  : l10n.chuNuoiBaoBanChuaToi),
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonDichVuSoBe(
                          don.maDon,
                          don.tenDichVu.split(' · ').first,
                          '${don.pets.length}',
                        ),
                        style: AppTextStyles.captionSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 24),
        children: [
          FlatSection(
            child: Text(
              !_toiBao
                  ? l10n.moTaDonDaHuyDuocPhanDoi('$gioHanPhanDoiVangMat')
                  : _trongGiu
                  ? l10n.moTaDieuKienBaoChuaMangBeToi('$phutAnHanNhanBe')
                  : l10n.moTaDieuKienBaoVangMat('$phutChoBatBuoc'),
              style: AppTextStyles.captionSm,
            ),
          ),
          const SizedBox(height: 16),
          FlatSection(child: _TomTatDon(bao: bao)),
          const SizedBox(height: 14),
          const FlatSection(child: AppDongKe()),
          const SizedBox(height: 14),
          for (final dong in _dongBangChung(context, bao))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FlatSection(
                child: IconTextRow(icon: Icons.check_circle_outline, chu: dong),
              ),
            ),
          const SizedBox(height: 2),
          const FlatSection(child: AppDongKe()),
          const SizedBox(height: 14),
          if (_toiBao) ...[
            FlatSection(
              child: PhotoPickerGrid(
                tieuDe: l10n.anhTaiDiemHenTrenTran(
                  '${_anh.length}',
                  '$soAnhVangMatToiDa',
                ),
                anh: _anh,
                tran: soAnhVangMatToiDa,
                onDoi: (ds) => setState(() => _anh = ds),
                batBuocChup: true,
              ),
            ),
            const SizedBox(height: 10),
            FlatSection(
              child: Text(
                l10n.nhacAnhTaiDiemHen('$soAnhVangMatToiThieu'),
                style: AppTextStyles.captionSm,
              ),
            ),
            const SizedBox(height: 16),
          ],
          FlatSection(child: _KhoiTien(bao: bao)),
          const SizedBox(height: 16),
          FlatSection(
            child: _DongGhiChu(
              chu: !_toiBao
                  ? l10n.moTaHanPhanDoi('$gioHanPhanDoiVangMat')
                  : _trongGiu
                  ? l10n.moTaTamGiuDenKyCho(
                      '${bao.don.gioGiuTien}',
                      '$gioHanPhanDoiVangMat',
                    )
                  : l10n.moTaTamGiuChoPhanDoi(
                      '${bao.don.gioGiuTien}',
                      '$gioHanPhanDoiVangMat',
                    ),
            ),
          ),
        ],
      ),
      bottomBar: _ThanhNut(
        toiBao: _toiBao,
        trongGiu: _trongGiu,
        guiDuoc: _duAnh,
        dangGui: _dangGui,
        onGui: _guiBao,
      ),
    );
  }
}

// Hai dòng bằng chứng, mỗi chiều một bộ
List<String> _dongBangChung(BuildContext context, BaoVangMat bao) {
  final l10n = context.l10n;
  // Trông giữ thì chủ nuôi là bên đi nên bằng chứng từ máy họ
  if (bao.don.laTrongGiu) {
    if (bao.loai == LoaiBaoVangMat.toiBao) {
      return [
        l10n.bangChungBanSanSangTaiNha(bao.gioCoMat ?? '', '${bao.phutDaCho}'),
        l10n.bangChungChuNuoiChuaXacThucViTri,
      ];
    }
    return [
      l10n.bangChungGpsChuNuoiTaiNha(bao.gioChuNuoiToiNha ?? ''),
      l10n.bangChungChuNuoiChoRoiBao(bao.gioChuNuoiChoDen ?? ''),
    ];
  }
  if (bao.loai == LoaiBaoVangMat.toiBao) {
    return [
      l10n.bangChungBanCoMat(bao.gioCoMat ?? '', '${bao.phutDaCho}'),
      l10n.bangChungViTriKhop('${bao.metSaiLech}'),
    ];
  }
  return [
    l10n.bangChungChuNuoiBao(
      bao.don.tenChuNuoi,
      bao.gioChuNuoiBao ?? '',
      '${bao.phutQuaHen}',
    ),
    l10n.bangChungViTriCuoiCuaBan(
      bao.gioViTriCuoi ?? '',
      soLeKm(bao.kmViTriCuoi),
      '$metGeofenceViTri',
    ),
  ];
}

const int metGeofenceViTri = 200;

class _TomTatDon extends StatelessWidget {
  const _TomTatDon({required this.bao});

  final BaoVangMat bao;

  @override
  Widget build(BuildContext context) {
    final don = bao.don;
    return OrderSummaryHead(
      pets: don.pets,
      moTaThoiGian: don.moTaThoiGian,
      tenDoiTac: don.tenChuNuoi,
    );
  }
}

class _KhoiTien extends StatelessWidget {
  const _KhoiTien({required this.bao});

  final BaoVangMat bao;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final toiBao = bao.loai == LoaiBaoVangMat.toiBao;
    final trongGiu = bao.don.laTrongGiu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          !toiBao
              ? l10n.ketQua
              : trongGiu
              ? l10n.banDuocDenViMatKyCho
              : l10n.banDuocDenViChuNuoiVangMat,
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 14),
        if (toiBao) ...[
          _Hang(
            nhan: trongGiu
                ? l10n.kyGiuNDem('${bao.don.trongGiu?.soDem ?? 0}')
                : l10n.tongGiaDon,
            giaTri: '${dinhDangTien(bao.don.tongTien)}đ',
          ),
          _Hang(
            nhan: l10n.chuNuoiChiuPhanTram('${bao.don.phanTramPhiHuy}'),
            giaTri: '-${dinhDangTien(bao.phiHuyChuNuoiChiu)}đ',
          ),
          _Hang(
            nhan: l10n.phiNenTangPhanTram('${bao.don.phanTramPhiNenTang}'),
            giaTri: '-${dinhDangTien(bao.phiNenTangTrenPhiHuy)}đ',
          ),
          _Hang(
            nhan: l10n.banNhan,
            giaTri: '${dinhDangTien(bao.banNhan)}đ',
            dam: true,
          ),
        ] else ...[
          _Hang(
            nhan: trongGiu ? l10n.chuNuoiDuocHoan100 : l10n.chuNuoiDuocHoan,
            giaTri: '${dinhDangTien(bao.don.tongTien)}đ',
          ),
          _Hang(nhan: l10n.banNhan, giaTri: '0đ'),
          _Hang(nhan: l10n.ghiVaoHoSo, giaTri: l10n.motLanHuy, dam: true),
        ],
      ],
    );
  }
}

class _Hang extends StatelessWidget {
  const _Hang({required this.nhan, required this.giaTri, this.dam = false});

  final String nhan;
  final String giaTri;
  final bool dam;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nhan,
              style: dam ? AppTextStyles.label : AppTextStyles.captionSm,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            giaTri,
            style: dam
                ? AppTextStyles.h3.copyWith(color: AppColors.primaryColor)
                : AppTextStyles.label,
          ),
        ],
      ),
    );
  }
}

class _DongGhiChu extends StatelessWidget {
  const _DongGhiChu({required this.chu});

  final String chu;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.shield_outlined,
          size: 17,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(chu, style: AppTextStyles.captionSm)),
      ],
    );
  }
}

// Hai lối ra: gửi báo hoặc lùi lại
class _ThanhNut extends StatelessWidget {
  const _ThanhNut({
    required this.toiBao,
    required this.trongGiu,
    required this.guiDuoc,
    required this.dangGui,
    required this.onGui,
  });

  final bool toiBao;
  final bool trongGiu;
  final bool guiDuoc;
  final bool dangGui;
  final VoidCallback onGui;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!toiBao)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    l10n.khongPhanDoiDuocLanNay,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.captionSm,
                  ),
                )
              else ...[
                AppButton(
                  text: trongGiu
                      ? l10n.guiBaoCaoChuaMangBeToi
                      : l10n.guiBaoCaoVangMat,
                  color: AppColors.accent,
                  height: 50,
                  enabled: guiDuoc,
                  dangTai: dangGui,
                  onTap: onGui,
                ),
                const SizedBox(height: 8),
              ],
              AppButton(
                text: toiBao ? l10n.choThem : l10n.dong,
                flat: true,
                height: 50,
                color: AppColors.textSecondary,
                onTap: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
