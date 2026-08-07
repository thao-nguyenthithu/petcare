import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

const int _phanNhan = 5;
const int _phanGiaTri = 6;
const int _phanNhanDai = 3;
const int _phanGiaTriDai = 7;

// Thẻ tóm tắt đơn và biên nhận giao dịch
class PaymentOrderCard extends StatelessWidget {
  const PaymentOrderCard({super.key, required this.args});

  final PaymentResultArgs args;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = args.draft;
    final thanhCong = args.thanhCong;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius20),
        border: Border.all(color: AppColors.neutralLight),
      ),
      child: Column(
        children: [
          _Hang(
            nhan: l10n.maDonNhan,
            giaTri: args.maDon ?? l10n.chuaCo,
            mauGiaTri: args.maDon == null ? AppColors.textSecondary : null,
          ),
          _Hang(nhan: l10n.dichVu, giaTri: moTaDichVuDraft(context, draft)),
          _Hang(nhan: l10n.nguoiCham, giaTri: draft.sitter.fullName),
          _HangNhieuDong(nhan: _nhanLich(context), dong: _dongLich(context)),
          _Hang(nhan: l10n.thuCung, giaTri: l10n.soBe('${draft.pets.length}')),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: AppDongKe(),
          ),
          _Hang(
            nhan: thanhCong ? l10n.tongThanhToan : l10n.canThanhToan,
            giaTri: '${dinhDangTien(args.don?.tongTien ?? draft.tongTien)}đ',
            dam: true,
            mauGiaTri: AppColors.accent,
          ),
          const SizedBox(height: 6),
          if (args.maGiaoDich != null)
            _Hang(nhan: l10n.maGiaoDichVnpay, giaTri: args.maGiaoDich!),
          _Hang(nhan: l10n.thoiGian, giaTri: _mocThoiGian(args.thoiDiem)),
          _Hang(
            nhan: l10n.trangThaiTien,
            giaTri: thanhCong ? l10n.dangGiuOTaiKhoanTrungGian : l10n.thatBai,
            mauGiaTri: thanhCong ? AppColors.honey : AppColors.accent,
          ),
        ],
      ),
    );
  }

  String _nhanLich(BuildContext context) {
    final l10n = context.l10n;
    return switch (args.draft.loai) {
      ServiceType.walking => l10n.thoiGian,
      ServiceType.boarding => l10n.lichGiu,
      ServiceType.grooming => l10n.gioHenLabel,
    };
  }

  List<String> _dongLich(BuildContext context) {
    final l10n = context.l10n;
    final draft = args.draft;
    final ngay = draft.ngay;
    final gio = draft.gio;
    if (ngay == null || gio == null) return [l10n.chuaCapNhat];
    if (draft.loai != ServiceType.boarding) {
      return ['${nhanNgayDraft(context, ngay)} · ${gio.nhan}'];
    }
    final tra = draft.ngayTra;
    final gioTra = draft.gioTra;
    if (tra == null || gioTra == null) return [l10n.chuaCapNhat];
    return [
      l10n.nhanBeNgayGio(nhanNgayDraft(context, ngay), gio.nhan),
      l10n.traBeNgayGio(nhanNgayDraft(context, tra), gioTra.nhan),
      l10n.soDemNhan('${draft.soDem}'),
    ];
  }

  String _mocThoiGian(DateTime d) {
    final gio12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final phut = d.minute.toString().padLeft(2, '0');
    final giay = d.second.toString().padLeft(2, '0');
    final buoi = d.hour < 12 ? 'SA' : 'CH';
    return '${ngayThangNam(d)} $gio12:$phut:$giay $buoi';
  }
}

class _Hang extends StatelessWidget {
  const _Hang({
    required this.nhan,
    required this.giaTri,
    this.dam = false,
    this.mauGiaTri,
  });

  final String nhan;
  final String giaTri;
  final bool dam;
  final Color? mauGiaTri;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: _phanNhan,
            child: Text(
              nhan,
              style: dam ? AppTextStyles.label : AppTextStyles.captionSm,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: _phanGiaTri,
            child: Text(
              giaTri,
              textAlign: TextAlign.right,
              style: dam
                  ? AppTextStyles.h3.copyWith(color: mauGiaTri)
                  : AppTextStyles.label.copyWith(color: mauGiaTri),
            ),
          ),
        ],
      ),
    );
  }
}

class _HangNhieuDong extends StatelessWidget {
  const _HangNhieuDong({required this.nhan, required this.dong});

  final String nhan;
  final List<String> dong;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: _phanNhanDai,
            child: Text(nhan, style: AppTextStyles.captionSm),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: _phanGiaTriDai,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < dong.length; i++)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      dong[i],
                      maxLines: 1,
                      softWrap: false,
                      style: AppTextStyles.label.copyWith(
                        color: i == dong.length - 1 && dong.length > 1
                            ? AppColors.primaryColor
                            : null,
                      ),
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

String moTaDichVuDraft(BuildContext context, BookingDraft draft) {
  final l10n = context.l10n;
  final ten = serviceTypeNameDai(context, draft.loai);
  final phan = switch (draft.loai) {
    ServiceType.walking =>
      draft.phutMotLuot == null ? null : l10n.nPhut('${draft.phutMotLuot}'),
    ServiceType.boarding =>
      draft.soDem == 0 ? null : l10n.soDemNhan('${draft.soDem}'),
    ServiceType.grooming =>
      draft.phutGrooming == 0 ? null : l10n.nPhut('${draft.phutGrooming}'),
  };
  return phan == null ? ten : '$ten · $phan';
}

String nhanNgayDraft(BuildContext context, DateTime ngay) {
  final l10n = context.l10n;
  return '${thuDaiTheoSo(l10n, ngay.weekday)}, ${ngayThang(ngay)}';
}

String moTaThoiGianDraft(BuildContext context, BookingDraft draft) {
  final l10n = context.l10n;
  final ngay = draft.ngay;
  final gio = draft.gio;
  if (ngay == null || gio == null) return l10n.chuaCapNhat;
  final nhanNgay = nhanNgayDraft(context, ngay);
  if (draft.loai == ServiceType.grooming) {
    return l10n.ngayLucGio(nhanNgay, gio.nhan);
  }
  if (draft.loai != ServiceType.boarding) {
    final phut = draft.phutMotLuot ?? 0;
    final khung = phut == 0
        ? gio.nhan
        : l10n.khungGio(gio.nhan, gioKetThuc(gio, phut));
    return '$nhanNgay · $khung';
  }
  return '$nhanNgay · ${gio.nhan}';
}

String? moTaTraBeDraft(BuildContext context, BookingDraft draft) {
  if (draft.loai != ServiceType.boarding) return null;
  final tra = draft.ngayTra;
  final gioTra = draft.gioTra;
  if (tra == null || gioTra == null) return null;
  return '${nhanNgayDraft(context, tra)} · ${gioTra.nhan}';
}
