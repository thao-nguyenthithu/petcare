import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/chip_chon.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

typedef _HangLuat = ({String trai, String phai, Color mau});

typedef _MucLuat = ({String tieuDe, List<_HangLuat> hang, String? chuThich});

class CancelPolicyScreen extends ConsumerStatefulWidget {
  const CancelPolicyScreen({super.key});

  @override
  ConsumerState<CancelPolicyScreen> createState() => _CancelPolicyScreenState();
}

class _CancelPolicyScreenState extends ConsumerState<CancelPolicyScreen> {
  ServiceType _tab = ServiceType.walking;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cauHinh = ref.watch(cauHinhNghiepVuProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.chinhSachHuyDon,
              subtitle: l10n.apDungKhiBanDat,
              leNgang: leMucPhang,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                leMucPhang,
                AppSpacing.textGap,
                leMucPhang,
                AppSpacing.itemGap,
              ),
              child: Row(
                children: [
                  for (final (i, t) in const [
                    ServiceType.walking,
                    ServiceType.grooming,
                    ServiceType.boarding,
                  ].indexed) ...[
                    if (i != 0) const SizedBox(width: 10),
                    ChipChon(
                      nhan: switch (t) {
                        ServiceType.walking => l10n.datDiDao,
                        ServiceType.grooming => l10n.tamCatTiaNgan,
                        ServiceType.boarding => l10n.trongGiu,
                      },
                      chon: _tab == t,
                      onTap: () => setState(() => _tab = t),
                    ),
                  ],
                ],
              ),
            ),
            const AppDongKe(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                children: [
                  for (final (i, muc) in _mucCua(
                    context,
                    _tab,
                    cauHinh,
                  ).indexed) ...[
                    if (i != 0) const FlatDivider(),
                    FlatSection(child: _KhoiMuc(muc: muc)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_MucLuat> _mucCua(
    BuildContext context,
    ServiceType tab,
    CauHinhNghiepVu cauHinh,
  ) {
    final l10n = context.l10n;
    final phiHuy = l10n.phiPhanTram('${cauHinh.phiHuyMuonPhanTram}');
    const xanh = AppColors.primaryColor;
    const cam = AppColors.accent;
    const den = AppColors.textPrimary;
    final nccHuy = (
      tieuDe: l10n.nccHuyTieuDe,
      hang: [(trai: l10n.batKeLucNao, phai: l10n.hoan100, mau: xanh)],
      chuThich: null,
    );
    final huyMuon = (
      tieuDe: l10n.huyMuonNhieuLan,
      hang: const <_HangLuat>[],
      chuThich: l10n.giaiThichHuyMuonNhieuLan('${cauHinh.cuaSoPhatNgay}'),
    );
    final heThongTuHuy = (
      tieuDe: l10n.heThongTuHuyTieuDe,
      hang: [
        if (tab != ServiceType.boarding)
          (
            trai: l10n.nccChuaToiSau30,
            phai: l10n.heThongTuHuyHoan100,
            mau: xanh,
          ),
        (
          trai: tab == ServiceType.boarding
              ? l10n.quaGioHenChuaNhanBe
              : l10n.quaGioHenChuaGiaoBe,
          phai: l10n.heThongTuHuyKhongMatPhi,
          mau: den,
        ),
      ],
      chuThich: l10n.giaiThichHeThongTuHuy,
    );
    if (tab != ServiceType.boarding) {
      return [
        (
          tieuDe: l10n.banHuyDon,
          hang: [
            (trai: l10n.nccChuaNhanDon, phai: l10n.mienPhi, mau: xanh),
            (trai: l10n.truoc12TruaHomTruoc, phai: l10n.mienPhi, mau: xanh),
            (trai: l10n.donDatGap30Phut, phai: l10n.mienPhi, mau: xanh),
            (trai: l10n.muonHonCacMoc, phai: phiHuy, mau: cam),
          ],
          chuThich: l10n.hoanTienVeTaiKhoan,
        ),
        nccHuy,
        (
          tieuDe: l10n.khongCoMatOGioHen,
          hang: [
            (trai: l10n.banBiBaoVangMat, phai: phiHuy, mau: cam),
            (trai: l10n.beThieuRoMomHoacDayXich, phai: phiHuy, mau: cam),
            (trai: l10n.nccToiMuonQua15, phai: l10n.banHuyMienPhi, mau: xanh),
          ],
          chuThich: l10n.giaiThichVangMatThieuDungCu(
            '${cauHinh.phiHuyMuonPhanTram}',
          ),
        ),
        heThongTuHuy,
        huyMuon,
      ];
    }
    return [
      (
        tieuDe: l10n.banHuyDon,
        hang: [
          (trai: l10n.nccChuaNhanDon, phai: l10n.mienPhi, mau: xanh),
          (trai: l10n.ky7DemHuyTruoc, phai: l10n.mienPhi, mau: xanh),
          (trai: l10n.kyTren7DemHuyTruoc, phai: l10n.mienPhi, mau: xanh),
          (trai: l10n.donDatGap30Phut, phai: l10n.mienPhi, mau: xanh),
          (
            trai: l10n.muonHonCacMoc,
            phai: l10n.phiPhanTramToiDaNDem(
              '${cauHinh.phiHuyMuonPhanTram}',
              '$demTinhPhiToiDa',
            ),
            mau: cam,
          ),
        ],
        chuThich: l10n.hoanTienVeTaiKhoan,
      ),
      (
        tieuDe: l10n.ketThucSomGiuaKy,
        hang: [
          (trai: l10n.demDaO, phai: l10n.nguyenGia, mau: AppColors.textPrimary),
          (trai: l10n.demBiCat7Ke, phai: phiHuy, mau: cam),
          (trai: l10n.demXaHon7Ke, phai: l10n.hoanDu, mau: xanh),
        ],
        chuThich: l10n.giaiThichGioDon,
      ),
      nccHuy,
      (
        tieuDe: l10n.khongCoMatOMocNhanBe,
        hang: [
          (trai: l10n.banVangMatKhongMangBe, phai: phiHuy, mau: cam),
          (
            trai: l10n.banBaoNccKhongCoNhaSau15,
            phai: l10n.banHuyMienPhi,
            mau: xanh,
          ),
        ],
        chuThich: null,
      ),
      heThongTuHuy,
      huyMuon,
    ];
  }
}

// Chính sách huỷ đơn phía người chăm
class SitterCancelPolicyScreen extends ConsumerWidget {
  const SitterCancelPolicyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cauHinh = ref.watch(cauHinhNghiepVuProvider);
    final banNhan = '${100 - cauHinh.phiNenTangPhanTram}';
    final nhanPhiHuy = l10n.nhanPhanTramPhiHuy(banNhan);
    const xanh = AppColors.primaryColor;
    const cam = AppColors.accent;
    const den = AppColors.textPrimary;
    final muc = <_MucLuat>[
      (
        tieuDe: l10n.banNhanHoacTuChoi,
        hang: [
          (trai: l10n.conDuoi6Gio, phai: l10n.han30Phut, mau: den),
          (trai: l10n.con6Toi24Gio, phai: l10n.han2Gio, mau: den),
          (trai: l10n.con1Toi7Ngay, phai: l10n.han12Gio, mau: den),
          (trai: l10n.conTren7Ngay, phai: l10n.han24Gio, mau: den),
        ],
        chuThich: l10n.giaiThichTuChoiTrongHan,
      ),
      (
        tieuDe: l10n.banHuyDonDaNhan,
        hang: [
          (trai: l10n.huyChuaXuatPhat, phai: l10n.tinh1LanTyLeHuy, mau: cam),
          (
            trai: l10n.daXuatPhatRoiBoDon,
            phai: l10n.treoPhatChoHoTroSoat,
            mau: cam,
          ),
          (trai: l10n.imLangBoDon, phai: l10n.tinhTyLeHuyVaCanhCao, mau: cam),
        ],
        chuThich: l10n.giaiThichThangBaMuc,
      ),
      (
        tieuDe: l10n.khiNaoBiAnHoSo,
        hang: [
          (
            trai: l10n.nguongCanhCaoVaTyLeHuy(
              '${cauHinh.canhCaoBiAn}',
              '${cauHinh.cuaSoPhatNgay}',
              '${cauHinh.tranTyLeHuy}',
            ),
            phai: l10n.tamAnTheoBac,
            mau: cam,
          ),
          (
            trai: l10n.tamAnLan4Trong6Thang,
            phai: l10n.khoaHoSoVinhVien,
            mau: cam,
          ),
        ],
        chuThich: l10n.giaiThichTamAn('${cauHinh.donToiThieuXetTyLeHuy}'),
      ),
      (
        tieuDe: l10n.chuNuoiHuyTieuDe,
        hang: [
          // Câu mở đầu mục: hàng không có vế phải
          (trai: l10n.moTaChuNuoiHuyMocDuoi, phai: '', mau: den),
          (trai: l10n.donDatVaTamTia, phai: l10n.moc12TruaHomTruoc, mau: den),
          (
            trai: l10n.donTrongGiu7DemXuong,
            phai: l10n.moc12Trua1NgayTruocNhanBe,
            mau: den,
          ),
          (
            trai: l10n.donTrongGiuTren7Dem,
            phai: l10n.mocTruocNhanBe7Ngay,
            mau: den,
          ),
          (trai: l10n.donDatGapSauMoc, phai: l10n.moc30PhutTuKhiNhan, mau: den),
          (trai: l10n.huyTrongHanMienPhi, phai: l10n.banNhan0d, mau: den),
          (trai: l10n.huySauHanMienPhi, phai: nhanPhiHuy, mau: xanh),
          (trai: l10n.chuNuoiVangMatSau15, phai: nhanPhiHuy, mau: xanh),
          (trai: l10n.beThieuRoMomHoacDayXich, phai: nhanPhiHuy, mau: xanh),
          (
            trai: l10n.ketThucSomGiuaKyTrongGiu,
            phai: l10n.demDaODuGiaVaPhanTramDemCat(
              '${cauHinh.phiHuyMuonPhanTram}',
            ),
            mau: xanh,
          ),
        ],
        chuThich: l10n.giaiThichPhiHuyChia(
          banNhan,
          '${cauHinh.phiNenTangPhanTram}',
          '${cauHinh.phiHuyMuonPhanTram}',
        ),
      ),
      (
        tieuDe: l10n.heThongTuHuyTieuDe,
        hang: [
          (
            trai: l10n.banKhongToiSau30,
            phai: l10n.tinhTyLeHuyVaCanhCao,
            mau: cam,
          ),
          (
            trai: l10n.banDaToiMaChuaGiaoBe,
            phai: l10n.heThongHuyKhongAiMatPhi,
            mau: den,
          ),
        ],
        chuThich: l10n.giaiThichHeThongTuHuyNcc(banNhan),
      ),
      (
        tieuDe: l10n.truongHopKhongTinhLoi,
        hang: [
          (trai: l10n.tuChoiTrongHan, phai: l10n.khongTinhTyLeHuy, mau: xanh),
          (
            trai: l10n.tuChoiViThieuDungCu,
            phai: l10n.khongTinhTyLeHuy,
            mau: xanh,
          ),
          (
            trai: l10n.banDaToiMaChuaGiaoBe,
            phai: l10n.khongTinhTyLeHuy,
            mau: xanh,
          ),
        ],
        chuThich: null,
      ),
      (
        tieuDe: l10n.tyLeHuyTinhTheNao,
        hang: const [],
        chuThich: l10n.giaiThichTyLeHuy(
          '${cauHinh.cuaSoPhatNgay}',
          '${cauHinh.donToiThieuXetTyLeHuy}',
        ),
      ),
      (
        tieuDe: l10n.tyLeNhanDonTinhTheNao,
        hang: const [],
        chuThich: l10n.giaiThichTyLeNhanDon('${cauHinh.cuaSoPhatNgay}'),
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppScreenHeader(
              title: l10n.chinhSachHuyDon,
              subtitle: l10n.apDungKhiBanNhanDon,
              leNgang: leMucPhang,
            ),
            const AppDongKe(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                children: [
                  for (final (i, m) in muc.indexed) ...[
                    if (i != 0) const FlatDivider(),
                    FlatSection(child: _KhoiMuc(muc: m)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KhoiMuc extends StatelessWidget {
  const _KhoiMuc({required this.muc});

  final _MucLuat muc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(muc.tieuDe, style: AppTextStyles.h3),
        for (final h in muc.hang) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  h.trai,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (h.phai.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.itemGap),
                Flexible(
                  child: Text(
                    h.phai,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.label.copyWith(color: h.mau),
                  ),
                ),
              ],
            ],
          ),
        ],
        if (muc.chuThich case final chu?) ...[
          const SizedBox(height: 12),
          Text(chu, style: AppTextStyles.captionSm),
        ],
      ],
    );
  }
}
