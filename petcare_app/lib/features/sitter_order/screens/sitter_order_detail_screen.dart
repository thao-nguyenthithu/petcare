import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_absence.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_orders_api_service.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/booking_detail_hero.dart';
import 'package:petcare_app/shared/widgets/booking_pet_notes.dart';
import 'package:petcare_app/shared/widgets/confirm_detail_rows.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_boarding_blocks.dart';
import 'package:petcare_app/features/sitter_order/widgets/sitter_grooming_blocks.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_cancelled_body.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_bottom_bar.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_earnings.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_facts.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_owner_row.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_route_block.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_status.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_title_bar.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_sheets.dart';
import 'package:petcare_app/features/sitter_order/widgets/detail/sitter_order_walk_blocks.dart';
import 'package:petcare_app/shared/widgets/walking_gear_commitment.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/utils/lay_vi_tri.dart';
import 'package:petcare_app/shared/utils/mo_chi_duong.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Chi tiết đơn, các tình huống dùng chung một bố cục
class SitterOrderDetailScreen extends ConsumerStatefulWidget {
  const SitterOrderDetailScreen({
    super.key,
    required this.don,
    required this.bookingId,
  });

  final SitterOrderDetail don;
  final String bookingId;

  @override
  ConsumerState<SitterOrderDetailScreen> createState() =>
      _SitterOrderDetailScreenState();
}

class _SitterOrderDetailScreenState
    extends ConsumerState<SitterOrderDetailScreen> {
  bool _daCamKet = false;

  SitterOrderDetail get _don => widget.don;

  String get _id => widget.bookingId;

  Future<bool> _goi(
    Future<void> Function(SitterOrdersApiService s) viec, {
    String? baoThanhCong,
  }) => chayHanhDongDon(context, ref, _id, viec, nhanBaoXong: baoThanhCong);

  Future<void> _chapNhan() async {
    await _goi(
      (s) => s.nhanDon(_id, camKetDungCu: _daCamKet),
      baoThanhCong: context.l10n.daChapNhanDon,
    );
  }

  Future<void> _tuChoi() async {
    final ly = await showSitterRejectSheet(context, _don);
    if (ly == null || !mounted) return;
    final xong = await _goi(
      (s) => s.tuChoi(_id, lyDo: ly.lyDo, moTa: ly.moTa),
      baoThanhCong: context.l10n.daTuChoiDon,
    );
    if (xong && mounted) context.pop(true);
  }

  Future<void> _boDon() async {
    final daDi = _don.daXuatPhat;
    final ly = await (daDi
        ? showSitterCannotProceedSheet(context, _don)
        : showSitterCancelSheet(context, _don));
    if (ly == null || !mounted) return;
    final xong = await _goi(
      (s) => daDi
          ? s.khongTheTiepNhan(
              _id,
              lyDo: ly.lyDo,
              moTa: ly.moTa,
              anh: anhMultipart(ly.anh, 'abort'),
            )
          : s.huyDon(_id, lyDo: ly.lyDo, moTa: ly.moTa),
      baoThanhCong: context.l10n.daHuyDon,
    );
    if (xong && mounted) context.pop(true);
  }

  // Mỗi đơn chỉ báo đến muộn một lần
  Future<void> _baoMuon() async {
    final phut = await showSitterLateSheet(context);
    if (phut == null || !mounted) return;
    await _goi(
      (s) => s.baoMuon(_id, phut: phut),
      baoThanhCong: context.l10n.daBaoDenMuon,
    );
  }

  Future<void> _xuatPhat() async {
    if (!_don.daXuatPhat) {
      final xong = await _goi((s) => s.xuatPhat(_id));
      if (!xong || !mounted) return;
    }
    if (_don.viTri case final viTri?) await moChiDuong(context, viTri);
  }

  Future<void> _daToi() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final (vt, loi) = await layViTriHienTai();
    if (!mounted) return;
    if (vt == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(chuLoiViTri(l10n, loi!)),
          action: canMoCaiDat(loi)
              ? SnackBarAction(
                  label: l10n.moCaiDat,
                  onPressed: () => moCaiDatViTri(loi),
                )
              : null,
        ),
      );
      return;
    }
    await _goi((s) => s.daToi(_id, lat: vt.latitude, lng: vt.longitude));
  }

  void _moManTacNghiep() =>
      context.push(AppRoutes.sitterActiveServicePath(_id));

  void _xemDonCho() => context.push(AppRoutes.sitterBookings);

  void _moChat() => moChatCuaDon(context, _id, laChuNuoi: false);

  @override
  Widget build(BuildContext context) {
    final don = _don;
    final chuNuoi = don.daBoDangDo
        ? null
        : FlatSection(
            child: SitterOrderOwnerRow(
              ten: don.tenChuNuoi,
              avatarUrl: don.avatarChuNuoi,
              soDonDaDat: don.soDonDaDat,
              onNhanTin: don.daNhanDon ? () => _moChat() : null,
            ),
          );
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: SitterOrderTitleBar(don: don),
      body: don.daBoDangDo
          ? SitterCancelledBody(
              don: don,
              onXemBe: () => _moDanhSachBe(context, don),
            )
          : AppRefreshIndicator(
              onRefresh: () => ref.read(chiTietDonNccProvider(_id).future),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 14, bottom: 24),
                children: [
                  FlatSection(
                    child: BookingDetailHero(
                      pets: don.pets,
                      loai: don.loai,
                      tenDichVu: don.tenDichVu,
                      onXemBe: () => _moDanhSachBe(context, don),
                    ),
                  ),
                  if (!don.daBoDangDo &&
                      !don.choChot &&
                      !don.daHoanThanh &&
                      !(don.laTrongGiu && don.dangDat)) ...[
                    const SizedBox(height: 16),
                    FlatSection(
                      child: SessionStats(cot: soLieuDonNcc(context, don)),
                    ),
                  ],
                  const FlatDivider(),
                  FlatSection(child: SitterOrderStatus(don: don)),
                  if (don.daBoDangDo || don.choChot || don.daHoanThanh) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: SessionStats(cot: soLieuDonNcc(context, don)),
                    ),
                  ],
                  if (don.laTrongGiu && don.dangDat) ...[
                    if (don.dienBien.isNotEmpty) ...[
                      const FlatDivider(),
                      FlatSection(child: SessionTimeline(moc: don.dienBien)),
                    ],
                    const SizedBox(height: 20),
                    FlatSection(
                      child: BoardingUpdateBlock(
                        don: don,
                        onNhatKy: () =>
                            context.push(AppRoutes.sitterEvidencePath(_id)),
                        onGuiCapNhat: () =>
                            context.push(AppRoutes.sitterDailyUpdatePath(_id)),
                        onMoManTrong: () => context.push(
                          AppRoutes.sitterActiveBoardingPath(_id),
                        ),
                      ),
                    ),
                  ],
                  if (don.trongGiu case final ky?) ...[
                    const FlatDivider(),
                    FlatSection(child: BoardingHandoverAlbum(ky: ky)),
                  ],
                  if (chuNuoi != null &&
                      !don.choChot &&
                      !don.daHoanThanh &&
                      (!don.dangDat || don.laTrongGiu)) ...[
                    const FlatDivider(),
                    chuNuoi,
                  ],
                  if (don.coKhoiDuongDi) ...[
                    const SizedBox(height: 16),
                    FlatSection(
                      child: SitterOrderRouteBlock(
                        don: don,
                        onXuatPhat: _xuatPhat,
                      ),
                    ),
                  ],
                  if (don.laGrooming &&
                      !don.daBoDangDo &&
                      !don.dangDat &&
                      !don.choChot) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: SitterGroomingPackages(
                        goiTungBe: don.grooming?.goiTungBe ?? const [],
                      ),
                    ),
                  ],
                  const FlatDivider(),
                  FlatSection(
                    child: ConfirmDetailRows(
                      tieuDe: context.l10n.thongTinDon,
                      dong: dongThongTinDonNcc(context, don),
                    ),
                  ),
                  if (don.laGrooming && don.dienBien.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    FlatSection(child: SessionTimeline(moc: don.dienBien)),
                  ],
                  if (don.laGrooming && don.dangDat) ...[
                    const SizedBox(height: 20),
                    FlatSection(
                      child: GroomingTaskList(
                        goiTungBe: don.grooming?.goiTungBe ?? const [],
                        onMoManLam: () => context.push(
                          AppRoutes.sitterActiveGroomingPath(_id),
                        ),
                      ),
                    ),
                  ],
                  if (don.laGrooming && don.tongAnhTruoc > 0) ...[
                    const SizedBox(height: 20),
                    FlatSection(
                      child: SessionPhotoLog(
                        anh: don.anhTruoc,
                        tong: don.tongAnhTruoc,
                        tieuDe: context.l10n.anhTruocKhiLam(
                          '${don.tongAnhTruoc}',
                        ),
                        soCot: 2,
                        onXemTatCa: () =>
                            context.push(AppRoutes.sitterEvidencePath(_id)),
                        onThem: don.dangDat
                            ? () => context.push(
                                AppRoutes.sitterEvidencePath(_id),
                              )
                            : null,
                      ),
                    ),
                  ],
                  if (don.laGrooming && don.tongAnhSau > 0) ...[
                    const SizedBox(height: 20),
                    FlatSection(
                      child: SessionPhotoLog(
                        anh: don.anhSau,
                        tong: don.tongAnhSau,
                        tieuDe: context.l10n.anhSauKhiLam('${don.tongAnhSau}'),
                        soCot: 2,
                      ),
                    ),
                  ],
                  if (don.laTrongGiu && don.daHoanThanh) ...[
                    if (don.trongGiu?.danhGia case final danhGia?) ...[
                      const FlatDivider(),
                      FlatSection(child: BoardingReviewBlock(danhGia: danhGia)),
                    ],
                    if (don.tongAnhNhatKy > 0) ...[
                      const FlatDivider(),
                      FlatSection(
                        child: SessionPhotoLog(
                          anh: don.anhNhatKy,
                          tong: don.tongAnhNhatKy,
                          nhanAnh: don.trongGiu?.nhanNgayAnh ?? const [],
                          onXemTatCa: () =>
                              context.push(AppRoutes.sitterEvidencePath(_id)),
                        ),
                      ),
                    ],
                  ],
                  if (don.dangDat && !don.laGrooming && !don.laTrongGiu) ...[
                    const SizedBox(height: 16),
                    FlatSection(
                      child: MapPreview(
                        viTri: don.viTri ?? const LatLng(21.0187, 105.8130),
                        icon: Icons.route_outlined,
                        nhan: context.l10n.daDiKmBatDauLuc(
                          context.l10n.soKm(soLeKm(don.kmDaDi ?? 0)),
                          don.gioBatDauPhien ?? '',
                        ),
                        onDoi: _moManTacNghiep,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (don.gioXacMinhDungCu case final gio?)
                      FlatSection(child: SitterGearVerified(gio: gio)),
                  ],
                  if (!don.daBoDangDo &&
                      !don.laGrooming &&
                      !(don.laTrongGiu &&
                          (don.dangDat || don.daHoanThanh))) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: BookingPetNotes(
                        pets: don.pets,
                        moTa: don.daNhanDon
                            ? context.l10n.chamDeXemThongTinVaHoSoBe
                            : context.l10n.chamDeXemThongTinCanThiet,
                        ghiChuCuoi: don.daNhanDon
                            ? context.l10n.banChotLucNhanDon
                            : null,
                      ),
                    ),
                  ],
                  if (don.canCamKetAnToan) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: WalkingGearCommitment(
                        soBe: don.pets.length,
                        daCam: _daCamKet,
                        onDoi: (v) => setState(() => _daCamKet = v),
                        tieuDe: context.l10n.camKetAnToan,
                        nhan: don.pets.length > 1
                            ? context.l10n.camKetGiuRoMomDayXichNBe(
                                '${don.pets.length}',
                              )
                            : context.l10n.camKetGiuRoMomDayXich,
                        moTa: context.l10n.moTaThaoRoMomGiuaChung,
                      ),
                    ),
                  ],
                  if (don.dangDat && !don.laGrooming && !don.laTrongGiu) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: SitterSessionPhotoLog(
                        don: don,
                        onGuiAnh: () =>
                            context.push(AppRoutes.sitterEvidencePath(_id)),
                        onXemTatCa: () =>
                            context.push(AppRoutes.sitterEvidencePath(_id)),
                      ),
                    ),
                  ],
                  if (chuNuoi != null &&
                      ((don.dangDat && !don.laTrongGiu) || don.choChot)) ...[
                    const FlatDivider(),
                    chuNuoi,
                  ],
                  const FlatDivider(),
                  FlatSection(child: SitterOrderEarnings(don: don)),
                ],
              ),
            ),
      bottomBar: SitterOrderBottomBar(
        don: don,
        daCamKet: _daCamKet,
        onChapNhan: _chapNhan,
        onTuChoi: _tuChoi,
        onXuatPhat: _xuatPhat,
        onDaToi: _daToi,
        // Trả bé tại nhà nên bấm là vào thẳng camera
        onKetThuc: () => don.laTrongGiu
            ? context.push(
                AppRoutes.sitterHandoverCameraPath(_id, LoaiBanGiao.traBe.ma),
              )
            : context.push(
                don.laGrooming
                    ? AppRoutes.sitterFinishGroomingPath(_id)
                    : AppRoutes.sitterFinishWalkPath(_id),
              ),
        // Grooming không đưa bé đi nên mở thẳng màn bắt đầu
        onNhanBe: () => switch (don.loai) {
          ServiceType.grooming => context.push(
            AppRoutes.sitterGroomingStartPath(_id),
          ),
          ServiceType.boarding => context.push(
            AppRoutes.sitterHandoverCameraPath(_id, LoaiBanGiao.nhanBe.ma),
          ),
          ServiceType.walking => context.push(AppRoutes.sitterCheckInPath(_id)),
        },
        onBaoVangMat: () => context.push(
          AppRoutes.sitterAbsencePath(_id, LoaiBaoVangMat.toiBao.ma),
        ),
        onNhanTin: () => _moChat(),
        onBaoMuon: _baoMuon,
        onBoDon: _boDon,
        onXemDonCho: _xemDonCho,
        onVeDanhSach: () => context.push(AppRoutes.sitterBookings),
        onXemVi: () => context.push(AppRoutes.sitterWallet),
        onBaoSuCo: () => context.push(AppRoutes.sitterIncidentPath(_id)),
      ),
    );
  }
}

// Danh sách bé, dùng chung trang với phía chủ nuôi
void _moDanhSachBe(BuildContext context, SitterOrderDetail don) {
  context.push(
    AppRoutes.bookingPets,
    extra: (maDon: don.maDon, tenDichVu: don.tenDichVu, pets: don.pets),
  );
}
