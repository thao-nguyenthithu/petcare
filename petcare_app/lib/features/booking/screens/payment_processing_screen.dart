import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/features/booking/data/payment_session.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/booking/providers/payment_provider.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:url_launcher/url_launcher.dart';

const Duration _nhipHoi = Duration(seconds: 2);

enum _Buoc { moCong, dangTra, xacNhan, loi }

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  const PaymentProcessingScreen({super.key, required this.args});

  final PaymentResultArgs args;

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  Timer? _dongHo;
  Timer? _hoiLai;
  Duration _con = Duration.zero;
  bool _dangHoi = false;
  bool _daRoiMan = false;
  _Buoc _buoc = _Buoc.moCong;

  PaymentSession? _phien;

  String get _bookingId => widget.args.don!.id;

  @override
  void initState() {
    super.initState();
    _con = _conLai();
    _dongHo = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _con = _conLai());
      if (_con == Duration.zero) _sangKetQua(false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _moCong());
  }

  void _batNhipHoi() {
    _hoiLai?.cancel();
    _hoiLai = Timer.periodic(_nhipHoi, (_) => _hoiTrangThai());
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    _hoiLai?.cancel();
    super.dispose();
  }

  Duration _conLai() {
    final hetHan = widget.args.don?.hetHanTraTien;
    if (hetHan == null) return Duration.zero;
    final con = hetHan.difference(nowVn());
    return con.isNegative ? Duration.zero : con;
  }

  Future<void> _moCong() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _buoc = _Buoc.moCong);
    _hoiLai?.cancel();
    try {
      final phien = await ref
          .read(paymentProvider.notifier)
          .moPhien(_bookingId);
      if (!mounted) return;
      _phien = phien;
      if (phien.tuDongThanhCong) {
        setState(() => _buoc = _Buoc.xacNhan);
        await _hoiTrangThai();
        if (mounted && !_daRoiMan) _batNhipHoi();
        return;
      }
      if (phien.quaCongGiaLap) {
        await context.push(AppRoutes.bookingMockPayment, extra: phien);
        if (!mounted) return;
        setState(() => _buoc = _Buoc.xacNhan);
        await _hoiTrangThai();
        if (mounted && !_daRoiMan) {
          setState(() => _buoc = _Buoc.dangTra);
          _batNhipHoi();
        }
        return;
      }
      final da = await launchUrl(
        Uri.parse(phien.payUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      if (da) {
        setState(() => _buoc = _Buoc.dangTra);
        _batNhipHoi();
      } else {
        setState(() => _buoc = _Buoc.loi);
        _batNhipHoi();
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.khongMoDuocCongThanhToan)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _buoc = _Buoc.loi);
      _batNhipHoi();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.khongMoDuocCongThanhToan)),
      );
    }
  }

  Future<void> _hoiTrangThai() async {
    if (_dangHoi || _daRoiMan || !mounted) return;
    _dangHoi = true;
    try {
      final tt = await ref.read(paymentProvider.notifier).trangThai(_bookingId);
      if (!mounted) return;
      switch (tt.ketCuc) {
        case KetCucTraTien.thanhCong:
          _sangKetQua(true, maGiaoDich: tt.maGiaoDich);
        case KetCucTraTien.thatBai:
          if (tt.donDaChet || (_phien != null && tt.txnRef == _phien!.txnRef)) {
            _sangKetQua(false, maGiaoDich: tt.maGiaoDich);
          }
        case KetCucTraTien.conCho:
          break;
      }
    } catch (_) {
    } finally {
      _dangHoi = false;
    }
  }

  void _sangKetQua(bool thanhCong, {String? maGiaoDich}) {
    if (_daRoiMan || !mounted) return;
    _daRoiMan = true;
    _dongHo?.cancel();
    _hoiLai?.cancel();
    if (thanhCong) ref.refreshBookingData();
    context.pushReplacement(
      AppRoutes.bookingPaymentResult,
      extra: PaymentResultArgs(
        draft: widget.args.draft,
        thanhCong: thanhCong,
        don: widget.args.don,
        thoiDiem: nowVn(),
        maGiaoDich: maGiaoDich,
      ),
    );
  }

  Future<void> _boGiuCho() async {
    _dongHo?.cancel();
    _hoiLai?.cancel();
    _daRoiMan = true;
    final draft = widget.args.draft;
    try {
      await ref.read(paymentProvider.notifier).boGiuCho(
        _bookingId,
        draft.sitter.id,
        [for (final be in draft.pets) be.id],
      );
    } catch (_) {
      if (!mounted) return;
      final ok = await _daTraXong();
      if (!mounted) return;
      if (ok != null) {
        _daRoiMan = false;
        _sangKetQua(true, maGiaoDich: ok.isEmpty ? null : ok);
        return;
      }
    }
    if (!mounted) return;
    context.pop();
  }

  Future<String?> _daTraXong() async {
    try {
      final tt = await ref.read(paymentProvider.notifier).trangThai(_bookingId);
      if (tt.ketCuc != KetCucTraTien.thanhCong) return null;
      return tt.maGiaoDich ?? '';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.args.draft;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_buoc != _Buoc.loi)
                  const SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                else
                  Icon(Icons.error_outline, size: 56, color: AppColors.accent),
                const SizedBox(height: 26),
                Text(
                  switch (_buoc) {
                    _Buoc.moCong => l10n.dangMoCongThanhToan,
                    _Buoc.dangTra => l10n.dangChoThanhToan,
                    _Buoc.xacNhan => l10n.dangXacNhanThanhToan,
                    _Buoc.loi => l10n.chuaMoDuocCong,
                  },
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1,
                ),
                const SizedBox(height: 10),
                Text(
                  switch (_buoc) {
                    _Buoc.moCong => l10n.moTaDangMoCong,
                    _Buoc.dangTra => l10n.moTaDangChoThanhToan,
                    _Buoc.xacNhan => l10n.moTaDangXacNhan,
                    _Buoc.loi => l10n.moTaChuaMoDuocCong,
                  },
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSm,
                ),
                const SizedBox(height: 18),
                _KhoiDongHo(con: _con, soTien: draft.tongTien),
                const SizedBox(height: 26),
                if (_buoc == _Buoc.dangTra) ...[
                  AppButton(
                    text: l10n.toiDaThanhToanXong,
                    onTap: _hoiTrangThai,
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: _moCong,
                    child: Text(
                      l10n.moLaiCongThanhToan,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ] else if (_buoc == _Buoc.loi)
                  AppButton(text: l10n.moLaiCongThanhToan, onTap: _moCong),
                TextButton(
                  onPressed: _boGiuCho,
                  child: Text(
                    l10n.huy,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KhoiDongHo extends StatelessWidget {
  const _KhoiDongHo({required this.con, required this.soTien});

  final Duration con;
  final int soTien;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(color: AppColors.neutral),
      ),
      child: Column(
        children: [
          Text('${dinhDangTien(soTien)}đ', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Text(
            l10n.giuKhungGioTrongVong(dongHoPhutGiay(con)),
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSm,
          ),
        ],
      ),
    );
  }
}
