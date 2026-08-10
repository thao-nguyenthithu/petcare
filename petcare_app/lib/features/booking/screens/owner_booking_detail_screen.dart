import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail_map.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';
import 'package:petcare_app/features/booking/services/booking_error_mapper.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/features/booking/widgets/boarding_arrival_block.dart';
import 'package:petcare_app/features/booking/widgets/boarding_directions.dart';
import 'package:petcare_app/features/booking/widgets/boarding_refund_invoice.dart';
import 'package:petcare_app/shared/widgets/booking_detail_hero.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_actions.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_facts.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_bottom_bar.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_notes.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_status.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_title_bar.dart';
import 'package:petcare_app/features/booking/widgets/boarding_pickup_block.dart';
import 'package:petcare_app/features/booking/widgets/booking_invoice.dart';
import 'package:petcare_app/shared/widgets/booking_pet_notes.dart';
import 'package:petcare_app/features/booking/widgets/booking_safety_rules.dart';
import 'package:petcare_app/features/booking/widgets/booking_sitter_row.dart';
import 'package:petcare_app/features/booking/widgets/cancelled_booking_body.dart';
import 'package:petcare_app/shared/widgets/confirm_detail_rows.dart';
import 'package:petcare_app/features/booking/widgets/grooming_pet_packages.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/mo_chi_duong.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/location_viewer.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';

// Trang chi tiết đơn phía chủ nuôi sau khi đã trả tiền
class OwnerBookingDetailScreen extends ConsumerWidget {
  const OwnerBookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = bookingDetailProvider(bookingId);
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: switch (ref.watch(provider)) {
          AsyncData(:final value) => _ThanDon(
            don: chiTietTuApi(
              context,
              value,
              ref.watch(cauHinhNghiepVuProvider),
            ),
            onRefresh: () => ref.read(provider.future),
          ),
          AsyncError(:final error) => _KhungTrong(
            child: AppNetworkError(
              onRetry: () => ref.invalidate(provider),
              message: moTaLoiDatLich(context, error),
            ),
          ),
          _ => const _KhungTrong(child: AppSkeletonList(soThe: 4, caoThe: 96)),
        },
      ),
    );
  }
}

class _KhungTrong extends StatelessWidget {
  const _KhungTrong({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 6, leMucPhang, 12),
          child: Row(
            children: [
              const AppBackButton(),
              const SizedBox(width: 10),
              Text(context.l10n.chiTietDon, style: AppTextStyles.h3),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _ThanDon extends ConsumerWidget {
  const _ThanDon({required this.don, required this.onRefresh});

  final OwnerBookingDetail don;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        BookingDetailTitleBar(don: don),
        if (don.daHuy)
          Expanded(
            child: CancelledBookingBody(
              don: don,
              onXemBe: () => moDanhSachBe(context, don),
              onXemThem: () =>
                  context.push(AppRoutes.searchPath(dichVu: don.loai.name)),
              onChonNcc: (ncc) => moHoSoGoiY(context, ncc),
            ),
          )
        else
          Expanded(
            child: AppRefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 14, bottom: 24),
                children: [
                  FlatSection(
                    child: BookingDetailHero(
                      pets: don.pets,
                      loai: don.loai,
                      tenDichVu: don.tenDichVu,
                      onXemBe: () => moDanhSachBe(context, don),
                    ),
                  ),
                  const FlatDivider(),
                  FlatSection(child: BookingDetailStatus(don: don)),
                  if (don.dangGiaoBe) ...[
                    const FlatDivider(),
                    FlatSection(child: BoardingArrivalBlock(don: don)),
                  ],
                  if (don.dangNhanBeVe) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: BoardingArrivalBlock(don: don, cuoiKy: true),
                    ),
                  ],
                  if (don.dangDiDonBe && don.viTri != null) ...[
                    const SizedBox(height: 16),
                    FlatSection(
                      child: MapPreview(
                        viTri: don.viTri!,
                        icon: Icons.directions_outlined,
                        nhan: context.l10n.moLaiChiDuong,
                        onDoi: () => moChiDuong(context, don.viTri!),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FlatSection(child: BoardingPickupBlock(don: don)),
                  ],
                  if (don.chuNuoiPhaiDi &&
                      don.dangChoToiGio &&
                      !don.daToiNoi &&
                      don.viTri != null) ...[
                    const SizedBox(height: 16),
                    FlatSection(
                      child: MapPreview(
                        viTri: don.viTri!,
                        icon: Icons.directions_outlined,
                        khoa: !don.chiDuongDaMo,
                        nhan: don.gioMoChiDuong == null
                            ? context.l10n.mangBeToiNhaNguoiCham
                            : context.l10n.chiDuongMoLuc(
                                don.gioMoChiDuong!,
                                don.ngayMoChiDuong ?? '',
                              ),
                        onDoi: () => showLocationViewer(
                          context,
                          don.viTri!,
                          tieuDe: don.diaDiem,
                          diaChi: don.diaChiDayDu ?? don.diaDiemPhu,
                          dongPhu: [
                            if (don.gioNhanBe case final gio?)
                              context.l10n.gioHenNhanBeLuc(gio),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FlatSection(
                      child: BoardingDirections(
                        don: don,
                        onXuatPhat: () => chuNuoiXuatPhat(
                          context,
                          ref,
                          don,
                          daXuatPhat: don.tinhTrang == TinhTrangDon.dangToi,
                        ),
                      ),
                    ),
                  ],
                  if (don.dangChay &&
                      don.coTheoDoiBanDo &&
                      don.viTri != null) ...[
                    const SizedBox(height: 16),
                    FlatSection(
                      child: MapPreview(
                        viTri: don.viTri!,
                        icon: Icons.my_location,
                        nhan: context.l10n.theoDoiTrucTiepTrenBanDo,
                        onDoi: () => context.push(
                          AppRoutes.bookingLiveTracking,
                          extra: don,
                        ),
                      ),
                    ),
                  ],
                  if (don.dangChay && don.xacMinh.isNotEmpty) ...[
                    const FlatDivider(),
                    FlatSection(child: SessionVerifyRows(muc: don.xacMinh)),
                  ],
                  if (don.dienBien.isNotEmpty) ...[
                    const FlatDivider(),
                    FlatSection(child: SessionTimeline(moc: don.dienBien)),
                  ],
                  if (don.daXong) ...[
                    const FlatDivider(),
                    FlatSection(child: RatingInviteBlock(don: don)),
                  ],
                  if (don.ketQua case final kq?) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: SessionStats(
                        cot: soLieuDonChuNuoi(context, don, kq),
                      ),
                    ),
                  ],
                  if (don.coAnhTruocSau) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: SessionPhotoLog(
                        anh: don.anhTruoc,
                        tong: don.anhTruoc.length,
                        soCot: 2,
                        tieuDe: context.l10n.anhTruocKhiLam(
                          '${don.anhTruoc.length}',
                        ),
                        onXemTatCa: () => moAnhMinhChung(context, don),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FlatSection(
                      child: SessionPhotoLog(
                        anh: don.anhSau,
                        tong: don.anhSau.length,
                        soCot: 2,
                        tieuDe: context.l10n.anhSauKhiLam(
                          '${don.anhSau.length}',
                        ),
                      ),
                    ),
                  ] else if (don.anhNhatKy.isNotEmpty) ...[
                    const FlatDivider(),
                    FlatSection(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SessionPhotoLog(
                            anh: don.anhNhatKy,
                            tong: don.tongAnh,
                            tieuDe: don.chuNuoiPhaiDi && don.dangChay
                                ? context.l10n.capNhatTuNguoiCham
                                : null,
                            nhanXemTatCa: don.chuNuoiPhaiDi
                                ? context.l10n.xemTatCaNAnh('${don.tongAnh}')
                                : null,
                            onXemTatCa: () {
                              switch (don.loai) {
                                case ServiceType.grooming:
                                  moAnhMinhChung(context, don);
                                case ServiceType.boarding:
                                  context.push(
                                    AppRoutes.bookingStayLog,
                                    extra: don,
                                  );
                                case ServiceType.walking:
                                  moAnhMinhChung(context, don);
                              }
                            },
                          ),
                          if (don.ghiChuMoiNhat case final ghiChu?) ...[
                            const SizedBox(height: 12),
                            Text('"$ghiChu"', style: AppTextStyles.label),
                            if (don.gioGhiChuMoiNhat case final gio?) ...[
                              const SizedBox(height: 4),
                              Text(gio, style: AppTextStyles.captionSm),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (!don.dangChay &&
                      (don.ghiChuNcc != null || don.daXong)) ...[
                    const FlatDivider(),
                    FlatSection(child: SitterFinishNote(don: don)),
                  ],
                  const FlatDivider(),
                  FlatSection(
                    child: BookingSitterRow(
                      ten: don.tenNcc,
                      avatarUrl: don.avatarNcc,
                      rating: don.ratingNcc,
                      soDanhGia: don.soDanhGiaNcc,
                      onXemHoSo: () => moHoSoNcc(context, don),
                      onNhanTin: don.daNhanDon
                          ? () => moChatCuaDon(context, don.id, laChuNuoi: true)
                          : null,
                    ),
                  ),
                  if (!don.daBatDau && don.goiTungBe.isNotEmpty) ...[
                    const FlatDivider(),
                    FlatSection(child: GroomingPetPackages(muc: don.goiTungBe)),
                  ],
                  const FlatDivider(),
                  FlatSection(
                    child: ConfirmDetailRows(
                      tieuDe: context.l10n.thongTinDon,
                      nhanHanhDong: context.l10n.banDo,
                      dong: _dongThongTin(context),
                    ),
                  ),
                  if (!don.daBatDau) ...[
                    if (don.canMucAnToan) ...[
                      const FlatDivider(),
                      const FlatSection(child: BookingSafetyRules()),
                    ],
                    if (don.pets.isNotEmpty && don.goiTungBe.isEmpty) ...[
                      const FlatDivider(),
                      FlatSection(child: BookingPetNotes(pets: don.pets)),
                    ],
                  ],
                  const FlatDivider(),
                  FlatSection(
                    child: don.daChotKetThucSom
                        ? BoardingRefundInvoice(
                            daTra: don.tongTien,
                            dongTru: don.dongHoanTien,
                            tienHoan: don.tienHoan ?? 0,
                          )
                        : BookingInvoice(
                            dong: don.dongTien,
                            tong: don.tongTien,
                            daNhanDon: don.daNhanDon,
                            hienChinhSachHuy:
                                !don.daBatDau ||
                                (don.chuNuoiPhaiDi && don.dangChay),
                            nhanChinhSachHuy: don.chuNuoiPhaiDi
                                ? context.l10n.chinhSachHuyVaDonTraBe
                                : null,
                            mocHuy: mocHuyCuaDon(context, don),
                          ),
                  ),
                ],
              ),
            ),
          ),
        BookingDetailBottomBar(don: don),
      ],
    );
  }

  List<DongChiTiet> _dongThongTin(BuildContext context) {
    final l10n = context.l10n;
    return [
      (
        icon: Icons.calendar_today_outlined,
        nhan: _nhanThoiGian(context),
        giaTri: [
          don.moTaThoiGian,
          if (don.moTaTraBe == null && _gioKetThucThat() != null)
            l10n.hoanThanhLucGio(_gioKetThucThat()!)
          else if (don.gioXongDuKien case final gio?)
            l10n.duKienXongKhoang(gio),
        ],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
      if (don.moTaTraBe case final traBe?)
        (
          icon: Icons.event_available_outlined,
          nhan: l10n.traBe,
          giaTri: [
            traBe,
            if (_gioKetThucThat() case final gio?) l10n.hoanThanhLucGio(gio),
          ],
          phu: don.moTaTraGoc == null ? null : l10n.lichTraGoc(don.moTaTraGoc!),
          onSua: null,
          duoiXanh: don.daChotKetThucSom && don.demHienTai != null
              ? l10n.ketThucSomODem('${don.demHienTai}', '${don.soDem ?? 0}')
              : don.soDem == null
              ? null
              : l10n.soDemNhan('${don.soDem}'),
        ),
      (
        icon: Icons.location_on_outlined,
        nhan: _nhanDiaDiem(context),
        giaTri: [don.diaDiem, ?don.diaDiemPhu],
        phu: null,
        onSua: don.viTri == null || don.chuNuoiPhaiDi
            ? null
            : () => showLocationViewer(context, don.viTri!, chiDuong: false),
        duoiXanh: null,
      ),
      (
        icon: Icons.notes_rounded,
        nhan: l10n.ghiChuChoNguoiCham,
        giaTri: [don.ghiChu.isEmpty ? l10n.khongCoNoiDung : don.ghiChu],
        phu: null,
        onSua: null,
        duoiXanh: null,
      ),
    ];
  }

  String? _gioKetThucThat() =>
      don.choBanChot || don.daXong ? don.gioHoanThanh : null;

  String _nhanThoiGian(BuildContext context) {
    final l10n = context.l10n;
    return switch (don.loai) {
      ServiceType.walking || ServiceType.grooming => l10n.thoiGian,
      ServiceType.boarding =>
        don.moTaTraBe == null ? l10n.lichGiu : l10n.nhanBe,
    };
  }

  String _nhanDiaDiem(BuildContext context) {
    final l10n = context.l10n;
    return switch (don.loai) {
      ServiceType.walking => l10n.diemDon,
      ServiceType.boarding => l10n.trongTai,
      ServiceType.grooming => l10n.lamTai,
    };
  }
}
