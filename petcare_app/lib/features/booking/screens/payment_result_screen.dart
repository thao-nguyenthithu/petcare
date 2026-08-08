import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/booking_slot.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/features/booking/widgets/payment_result_bottom.dart';
import 'package:petcare_app/features/booking/widgets/payment_result_card.dart';
import 'package:petcare_app/features/booking/widgets/payment_result_header.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

// Màn kết quả sau khi rời cổng VNPay
class PaymentResultScreen extends ConsumerStatefulWidget {
  const PaymentResultScreen({super.key, required this.args});

  final PaymentResultArgs args;

  @override
  ConsumerState<PaymentResultScreen> createState() =>
      _PaymentResultScreenState();
}

class _PaymentResultScreenState extends ConsumerState<PaymentResultScreen> {
  Timer? _dongHo;
  late Duration _con;

  @override
  void initState() {
    super.initState();
    _con = _hanBanDau();
    _dongHo = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _con = _con - const Duration(seconds: 1);
        if (_con.isNegative) _con = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _dongHo?.cancel();
    super.dispose();
  }

  Duration _hanBanDau() {
    final args = widget.args;
    if (!args.thanhCong) {
      final hetHan = args.hetHanGiuCho;
      if (hetHan == null) return Duration.zero;
      final con = hetHan.difference(nowVn());
      return con.isNegative ? Duration.zero : con;
    }
    final mocServer = args.don?.batDau;
    if (mocServer != null) {
      return hanNhanDon(mocServer.difference(nowVn()));
    }
    final ngay = args.draft.ngay;
    final gio = args.draft.gio;
    if (ngay == null || gio == null) return const Duration(hours: 12);
    final gioHen = DateTime(ngay.year, ngay.month, ngay.day, gio.gio, gio.phut);
    return hanNhanDon(gioHen.difference(nowVn()));
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final thanhCong = args.thanhCong;
    return Scaffold(
      backgroundColor: thanhCong
          ? AppColors.primaryColor
          : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(top: 32, bottom: 24),
          children: [
            Center(child: PaymentResultRing(thanhCong: thanhCong)),
            const SizedBox(height: 22),
            FlatSection(
              child: PaymentResultTitle(args: args, con: _con),
            ),
            const SizedBox(height: 22),
            FlatSection(child: PaymentOrderCard(args: args)),
            const SizedBox(height: 18),
            FlatSection(
              child: PaymentReminder(args: args, con: _con),
            ),
            const SizedBox(height: 22),
            FlatSection(
              child: PaymentResultButtons(args: args, con: _con),
            ),
          ],
        ),
      ),
    );
  }
}
