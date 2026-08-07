import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/booking/providers/don_hien_hanh.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';
import 'package:petcare_app/features/booking/widgets/boarding_early_end_parts.dart';
import 'package:petcare_app/features/booking/widgets/booking_time_dropdown.dart';
import 'package:petcare_app/shared/widgets/cancel_policy_link.dart';
import 'package:petcare_app/shared/widgets/chip_chon.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

enum _LyDo { doiKeHoach, viecGiaDinh, khac }

// Màn Kết thúc sớm và đón bé về của kỳ trông giữ
class BoardingEarlyEndScreen extends ConsumerStatefulWidget {
  const BoardingEarlyEndScreen({super.key, required this.banChup});

  final OwnerBookingDetail banChup;

  @override
  ConsumerState<BoardingEarlyEndScreen> createState() =>
      _BoardingEarlyEndScreenState();
}

class _BoardingEarlyEndScreenState
    extends ConsumerState<BoardingEarlyEndScreen> {
  late final DateTime _ngayNhan = widget.banChup.mocNhanBe ?? nowVn();
  late final DateTime _ngayTraGoc = widget.banChup.mocTraBe ?? _ngayNhan;
  final DateTime _homNay = nowVn();

  DateTime? _ngayChon;
  KhungGio? _gioChon;
  _LyDo? _lyDo;
  bool _dangChot = false;
  final _moTa = TextEditingController();

  late OwnerBookingDetail don;

  int get _tongDem => don.soDem ?? 1;
  int get _giaMotDem => don.tongTien ~/ _tongDem;

  bool get _chonNgayGoc =>
      _ngayChon != null && cungNgay(_ngayChon!, _ngayTraGoc);

  int get _soDemO =>
      _ngayChon == null ? _tongDem : soNgayLech(_ngayNhan, _ngayChon!);

  int get _soDemCat => _tongDem - _soDemO;

  int get _tienO => _soDemO * _giaMotDem;

  int get _phiCat => (_soDemCat * _giaMotDem * 0.5).round();

  int get _tienHoan => don.tongTien - _tienO - _phiCat;

  bool get _duDieuKienChot =>
      _ngayChon != null &&
      !_chonNgayGoc &&
      _gioChon != null &&
      _lyDo != null &&
      (_lyDo != _LyDo.khac || _moTa.text.trim().isNotEmpty);

  @override
  void dispose() {
    _moTa.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    don = donHienHanh(context, ref, widget.banChup);
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.ketThucSomVaDonBeVe,
            subtitle: '${don.maDon} · ${l10n.soBe('${don.pets.length}')}',
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        children: [
          FlatSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dangODemTrongKy('${don.demHienTai ?? 1}', '$_tongDem'),
                  style: AppTextStyles.captionSm,
                ),
                const SizedBox(height: 14),
                EarlyEndOrderCard(don: don),
              ],
            ),
          ),
          const FlatDivider(),
          FlatSection(child: _chonNgay(context)),
          const FlatDivider(),
          FlatSection(child: _chonGio(context)),
          const FlatDivider(),
          FlatSection(child: _lyDoKhoi(context)),
          const FlatDivider(),
          FlatSection(child: _tinhLaiTien(context)),
        ],
      ),
      bottomBar: BottomActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              text: _chonNgayGoc
                  ? l10n.khongCoThayDoiDeXacNhan
                  : l10n.xacNhanKetThucSom,
              color: AppColors.accent,
              enabled: _duDieuKienChot,
              dangTai: _dangChot,
              onTap: _chot,
            ),
            const SizedBox(height: 4),
            AppButton(
              text: l10n.giuNguyenKyTrongGiu,
              flat: true,
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chonNgay(BuildContext context) {
    final l10n = context.l10n;
    final ngayGocNhan = ngayThang(_ngayTraGoc);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.banMuonDonBeVao, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < 7; i++) ...[
              if (i != 0) const SizedBox(width: 6),
              Expanded(
                child: EarlyEndDayCell(
                  ngay: _homNay.add(Duration(days: i)),
                  homNay: _homNay,
                  ngayTraGoc: _ngayTraGoc,
                  chon: _ngayChon,
                  onChon: (d) => setState(() {
                    _ngayChon = d;
                    _gioChon = null;
                  }),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        EarlyEndLegend(),
        const SizedBox(height: 10),
        Text(
          _chonNgayGoc
              ? l10n.vuaChonNgayTraGoc(ngayGocNhan)
              : l10n.giaiThichChonNgayDon(ngayGocNhan),
          style: AppTextStyles.captionSm.copyWith(
            color: _chonNgayGoc ? AppColors.accent : null,
          ),
        ),
      ],
    );
  }

  Widget _chonGio(BuildContext context) {
    final l10n = context.l10n;
    final ngay = _ngayChon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.gioDonTheoGioLamViec(don.tenNcc), style: AppTextStyles.h3),
        const SizedBox(height: 14),
        if (ngay == null)
          AppNoteBox(text: l10n.chonNgayTruocDeXemGio)
        else
          BookingTimeDropdown(
            khung: sinhKhungGio(ngay: ngay, bayGio: _homNay),
            chon: _gioChon,
            moTaChon: (_) => l10n.gioNayThanhGioHenTraMoi,
            onChon: (k) => setState(() => _gioChon = k),
          ),
        const SizedBox(height: 12),
        AppNoteBox(text: l10n.ghiChuKetThucSom),
        const SizedBox(height: 10),
        CancelPolicyLink(nhan: l10n.chinhSachHuyVaDonTraBe),
      ],
    );
  }

  Widget _lyDoKhoi(BuildContext context) {
    final l10n = context.l10n;
    final nhan = {
      _LyDo.doiKeHoach: l10n.doiKeHoach,
      _LyDo.viecGiaDinh: l10n.viecGiaDinh,
      _LyDo.khac: l10n.khac,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.lyDoKetThucSom, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final ly in _LyDo.values)
              ChipChon(
                nhan: nhan[ly]!,
                chon: _lyDo == ly,
                onTap: () => setState(() => _lyDo = ly),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                mauNenChon: AppColors.cardMint,
                mauChuChon: AppColors.primaryColor,
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _moTa,
          maxLines: 2,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: l10n.moTaThemBatBuocKhiKhac),
        ),
        const SizedBox(height: 8),
        Text(l10n.lyDoGuiChoNccKetThucSom, style: AppTextStyles.captionSm),
      ],
    );
  }

  Widget _tinhLaiTien(BuildContext context) {
    final l10n = context.l10n;
    final giaDem = dinhDangTien(_giaMotDem);
    final chuaChon = _ngayChon == null;
    final duKy = chuaChon || _chonNgayGoc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tinhLaiTien, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        EarlyEndMoneyRow(
          nhan: duKy ? l10n.oDuKy : l10n.oToiNgay(ngayThang(_ngayChon!)),
          congThuc: l10n.congThucDem('${duKy ? _tongDem : _soDemO}', giaDem),
          tien: '${dinhDangTien(duKy ? don.tongTien : _tienO)}đ',
        ),
        const SizedBox(height: 12),
        if (duKy)
          EarlyEndMoneyRow(
            nhan: l10n.khongCoDemBiCat,
            congThuc: null,
            tien: '0đ',
          )
        else
          EarlyEndMoneyRow(
            nhan: l10n.demBiCatTrongKe('$_soDemCat'),
            congThuc: l10n.congThucDemCat(
              '$_soDemCat',
              giaDem,
              '${don.phanTramPhiHuy}',
            ),
            tien: '${dinhDangTien(_phiCat)}đ',
          ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(l10n.hoanVeVnpayNhan, style: AppTextStyles.h3),
            ),
            Text(
              '${dinhDangTien(duKy ? 0 : _tienHoan)}đ',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _chot() async {
    final ngay = _ngayChon;
    final gio = _gioChon;
    if (ngay == null || gio == null) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _dangChot = true);
    try {
      await BookingsApiService().ketThucSom(
        don.id,
        ngayTra: ngayIso(ngay),
        gioTra: gio.nhan,
      );
      if (!mounted) return;
      ref.refreshBookingData();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.daChotKetThucSomNhan)),
      );
      context.pop();
    } catch (loi) {
      if (!mounted) return;
      setState(() => _dangChot = false);
      messenger.showSnackBar(
        SnackBar(content: Text(messageFromError(loi) ?? l10n.loiKetNoiMayChu)),
      );
    }
  }
}
