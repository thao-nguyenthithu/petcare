import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';
import 'package:petcare_app/features/booking/screens/review_screen.dart';
import 'package:petcare_app/features/booking/services/booking_error_mapper.dart';
import 'package:petcare_app/features/booking/widgets/booking_detail_actions.dart';
import 'package:petcare_app/features/booking/widgets/booking_help_sheet.dart';
import 'package:petcare_app/features/booking/widgets/confirm_done_sheet.dart';
import 'package:petcare_app/features/booking/widgets/owner_cancel_sheet.dart';
import 'package:petcare_app/features/booking/widgets/owner_late_sheet.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

class BookingDetailBottomBar extends ConsumerWidget {
  const BookingDetailBottomBar({super.key, required this.don});

  final OwnerBookingDetail don;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (don.dangChay && (don.dangDiDonBe || don.dangNhanBeVe))
                AppButton(
                  text: l10n.nhanChoNguoiCham,
                  outlined: true,
                  mauChu: AppColors.primaryColor,
                  height: 50,
                  onTap: () => moChatCuaDon(context, don.id, laChuNuoi: true),
                )
              else if (don.dangChay && don.chuNuoiPhaiDi)
                AppButton(
                  text: don.daChotKetThucSom || don.laNgayCuoiKy
                      ? (don.chiDuongDonDaMo
                            ? l10n.xuatPhatDonBe
                            : l10n.xuatPhatDonBeMoLuc(
                                don.gioMoChiDuongDon ?? '',
                              ))
                      : l10n.nhanChoNguoiCham,
                  outlined:
                      (don.daChotKetThucSom || don.laNgayCuoiKy) &&
                      !don.chiDuongDonDaMo,
                  height: 50,
                  enabled:
                      !(don.daChotKetThucSom || don.laNgayCuoiKy) ||
                      (don.chiDuongDonDaMo && don.viTri != null),
                  onTap: () {
                    if (don.daChotKetThucSom || don.laNgayCuoiKy) {
                      chuNuoiXuatPhat(context, ref, don);
                    } else {
                      moChatCuaDon(context, don.id, laChuNuoi: true);
                    }
                  },
                )
              else if (don.dangChay)
                AppButton(
                  text: don.loai == ServiceType.walking
                      ? l10n.theoDoiTrucTiepTrenBanDo
                      : l10n.xemAnhCapNhat,
                  height: 50,
                  onTap: () {
                    if (don.loai == ServiceType.walking) {
                      context.push(AppRoutes.bookingLiveTracking, extra: don);
                    } else {
                      moAnhMinhChung(context, don);
                    }
                  },
                )
              else if (don.choBanChot)
                AppButton(
                  text: l10n.xacNhanHoanThanh,
                  color: AppColors.accent,
                  height: 50,
                  onTap: () => _chotDon(context, ref, don),
                )
              else if (don.daXong && !don.daDanhGia)
                AppButton(
                  text: l10n.danhGiaDichVu,
                  color: AppColors.accent,
                  height: 50,
                  onTap: () => context.push(
                    AppRoutes.bookingReview,
                    extra: (don: donDeDanhGia(don), sao: 0),
                  ),
                )
              else if (don.daXong)
                AppButton(
                  text: l10n.datLaiDichVuNay,
                  height: 50,
                  onTap: () => moHoSoNcc(context, don),
                )
              else if (don.daHuy)
                AppButton(
                  text: don.thongTinHuy?.ben == BenHuy.chuNuoi
                      ? l10n.datLaiDichVuNay
                      : l10n.timNguoiChamKhac,
                  height: 50,
                  onTap: () => don.thongTinHuy?.ben == BenHuy.chuNuoi
                      ? moHoSoNcc(context, don)
                      : context.push(
                          AppRoutes.searchPath(dichVu: don.loai.name),
                        ),
                )
              else if (don.chuaDocDuoc)
                AppButton(
                  text: l10n.lienHeHoTro,
                  outlined: true,
                  height: 50,
                  mauChu: AppColors.primaryColor,
                  onTap: () => showBookingHelpSheet(context, don),
                )
              else
                AppButton(
                  text: don.daNhanDon
                      ? l10n.nhanChoNguoiCham
                      : l10n.xemHoSoNguoiCham,
                  outlined: true,
                  height: 50,
                  mauChu: AppColors.primaryColor,
                  onTap: () => don.daNhanDon
                      ? moChatCuaDon(context, don.id, laChuNuoi: true)
                      : moHoSoNcc(context, don),
                ),
              const SizedBox(height: 4),
              if (don.dangKhieuNai)
                _LienKet(
                  nhan: l10n.xemHoSoKhieuNai,
                  onTap: () => moHoSoKhieuNai(context, don),
                )
              else if (don.dangChay && don.dangDiDonBe)
                _LienKet(
                  nhan: l10n.toiToiDonMuon,
                  onTap: () => showOwnerLateSheet(context, ref, don),
                )
              else if (don.dangChay && don.dangNhanBeVe)
                const SizedBox.shrink()
              else if (don.dangChay && don.chuNuoiPhaiDi)
                _LienKet(
                  nhan: don.daChotKetThucSom || don.laNgayCuoiKy
                      ? l10n.nhanChoNguoiCham
                      : l10n.ketThucSomNhan,
                  onTap: () => don.daChotKetThucSom || don.laNgayCuoiKy
                      ? moChatCuaDon(context, don.id, laChuNuoi: true)
                      : context.push(AppRoutes.bookingEarlyEnd, extra: don),
                )
              else if (don.dangChay)
                const SizedBox.shrink()
              else if (don.choBanChot)
                _LienKet(
                  nhan: l10n.baoSuCo,
                  onTap: () => moBaoSuCo(context, don),
                )
              else if (don.daXong && don.daDanhGia)
                _LienKet(
                  nhan: l10n.baoSuCo,
                  onTap: () => moBaoSuCo(context, don),
                )
              else if (don.daXong)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LienKet(
                      nhan: l10n.datLaiDichVuNayNhan,
                      onTap: () => moHoSoNcc(context, don),
                    ),
                    Text('·', style: AppTextStyles.captionSm),
                    _LienKet(
                      nhan: l10n.baoSuCo,
                      onTap: () => moBaoSuCo(context, don),
                    ),
                  ],
                )
              else if (don.daHuy || don.chuaDocDuoc)
                _LienKet(
                  nhan: l10n.lienHeHoTro,
                  onTap: () => showBookingHelpSheet(context, don),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (don.chuNuoiPhaiDi &&
                        don.dangChoToiGio &&
                        !don.daToiNoi) ...[
                      _LienKet(
                        nhan: l10n.toiMangBeToiMuon,
                        onTap: () => showOwnerLateSheet(context, ref, don),
                      ),
                      Text('·', style: AppTextStyles.captionSm),
                    ],
                    if (don.dangGiaoBe)
                      _LienKet(
                        nhan: l10n.nguoiChamKhongCoNhaMoLuc(
                          don.gioMoBaoKhongCoNha ?? '',
                        ),
                        onTap: null,
                      )
                    else if (don.choNhanBeQuaLau)
                      _LienKet(
                        nhan: l10n.nguoiChamKhongCoNha,
                        mau: AppColors.accent,
                        onTap: () =>
                            context.push(AppRoutes.bookingNoShow, extra: don),
                      )
                    else
                      _LienKet(
                        nhan: don.coTheBaoChuaToi
                            ? l10n.nguoiChamChuaToi
                            : !(don.chinhSachHuy?.coTheHuy ?? true)
                            ? l10n.khongHuyDuocNua
                            : don.daNhanDon
                            ? l10n.huyDon
                            : l10n.huyYeuCau,
                        mau: don.coTheBaoChuaToi ? AppColors.accent : null,
                        onTap: don.coTheBaoChuaToi
                            ? () => context.push(
                                AppRoutes.bookingNoShow,
                                extra: don,
                              )
                            : (don.chinhSachHuy?.coTheHuy ?? true)
                            ? () => huyDonCuaToi(context, ref, don)
                            : null,
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LienKet extends StatelessWidget {
  const _LienKet({required this.nhan, required this.onTap, this.mau});

  final String nhan;
  final VoidCallback? onTap;
  final Color? mau;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        nhan,
        style: AppTextStyles.captionSm.copyWith(
          color: mau ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

// Sheet huỷ đơn
Future<void> huyDonCuaToi(
  BuildContext context,
  WidgetRef ref,
  OwnerBookingDetail don,
) async {
  final cs = don.chinhSachHuy;
  final ly = await showOwnerCancelSheet(context, (
    maDon: don.maDon,
    tenDichVu: don.tenDichVu,
    pets: don.pets,
    moTaThoiGian: don.moTaThoiGian,
    tenNcc: don.tenNcc,
    tongTien: don.tongTien,
    phiHuy: cs?.phiHuy ?? 0,
    tienHoan: cs?.tienHoan ?? don.tongTien,
    mienPhi: cs?.mienPhi ?? true,
  ));
  if (ly == null || !context.mounted) return;
  try {
    await showAppLoading(
      context,
      () => ref
          .read(bookingDetailProvider(don.id).notifier)
          .huy(lyDo: ly.ma, moTa: ly.moTa),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(moTaLoiDatLich(context, e))));
  }
}

Future<void> _chotDon(
  BuildContext context,
  WidgetRef ref,
  OwnerBookingDetail don,
) async {
  final ok = await showConfirmDoneSheet(
    context,
    soBe: don.pets.length,
    soAnh: don.ketQua?.soAnh ?? don.tongAnh,
    gioGiuTien: don.gioGiuTien,
  );
  if (!ok || !context.mounted) return;
  try {
    await showAppLoading(
      context,
      () => ref.read(bookingDetailProvider(don.id).notifier).xacNhanHoanThanh(),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(moTaLoiDatLich(context, e))));
  }
}
