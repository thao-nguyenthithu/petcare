import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/ai_scan.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_check_in.dart';
import 'package:petcare_app/features/sitter_order/services/checkin_scan_api_service.dart';
import 'package:petcare_app/features/sitter_order/services/checkin_scan_socket_service.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_actions.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_order_error_mapper.dart';
import 'package:petcare_app/features/sitter_order/widgets/ai_scan_parts.dart';
import 'package:petcare_app/shared/widgets/app_back_button.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/flat_section.dart';

const Duration _nhipHoiLai = Duration(seconds: 5);

const Duration _hanChoKetQua = Duration(seconds: 60);

class SitterAiScanScreen extends ConsumerStatefulWidget {
  const SitterAiScanScreen({super.key, required this.args, this.batchId});

  final CheckInArgs args;

  final String? batchId;

  @override
  ConsumerState<SitterAiScanScreen> createState() => _SitterAiScanScreenState();
}

class _SitterAiScanScreenState extends ConsumerState<SitterAiScanScreen> {
  final _api = CheckinScanApiService();

  CheckinScanSocketService? _socket;
  StreamSubscription<KetQuaLoQuet>? _subKetQua;
  Timer? _timerPoll;
  Timer? _timerHanCho;

  late KetQuaLoQuet _ketQua = KetQuaLoQuet.dangQuetLo(widget.batchId);
  bool _dangGoi = false;
  bool _quaHanCho = false;

  String get _bookingId => widget.args.don.bookingId;
  int get _soBe => widget.args.don.pets.length;

  @override
  void initState() {
    super.initState();
    _taiLai();
    if (widget.batchId != null) _moSocket();
    _timerPoll = Timer.periodic(_nhipHoiLai, (_) => _taiLai());
    _timerHanCho = Timer(_hanChoKetQua, _hetHanCho);
  }

  @override
  void dispose() {
    _timerPoll?.cancel();
    _timerHanCho?.cancel();
    _subKetQua?.cancel();
    _socket?.dong();
    super.dispose();
  }

  Future<void> _moSocket() async {
    final token = await TokenStorageService().getAccessToken();
    if (token == null || token.isEmpty || !mounted) return;
    final socket = CheckinScanSocketService(serverGoc: serverGoc, token: token);
    _socket = socket;
    _subKetQua = socket.ketQua.listen(_nhanKetQua);
    socket.ketNoi(bookingId: _bookingId);
  }

  void _nhanKetQua(KetQuaLoQuet kq) {
    if (kq.batchId != null && kq.batchId != widget.batchId) return;
    if (!mounted) return;
    setState(() => _ketQua = kq);
    _dungCho();
  }

  Future<void> _taiLai() async {
    final batchId = widget.batchId;
    try {
      final kq = batchId == null
          ? await _api.trangThaiQuet(_bookingId)
          : await _api.ketQuaLo(_bookingId, batchId);
      if (!mounted) return;
      setState(() {
        _ketQua = kq;
        _quaHanCho = false;
      });
      if (kq.man != ManQuetAi.dangQuet) _dungCho();
    } on Exception {
      // Hụt một nhịp chưa phải hỏng, còn nhịp sau và còn hạn
    }
  }

  void _hetHanCho() {
    if (!mounted || _ketQua.man != ManQuetAi.dangQuet) return;
    setState(() => _quaHanCho = true);
    _dungCho();
  }

  void _dungCho() {
    _timerPoll?.cancel();
    _timerHanCho?.cancel();
  }

  void _thuLai() {
    setState(() => _quaHanCho = false);
    _timerPoll = Timer.periodic(_nhipHoiLai, (_) => _taiLai());
    _timerHanCho = Timer(_hanChoKetQua, _hetHanCho);
    _taiLai();
  }

  void _chupLai(SlotQuet slot) {
    context.pushReplacement(
      AppRoutes.sitterCheckInCameraPath(
        _bookingId,
        o: slot.slotIndex,
        conLai: slot.soLanConLai,
      ),
    );
  }

  // Ký từng ô một, gửi dồn dễ chồng lượt ở server
  Future<bool> _kyCacSlot(List<SlotQuet> slots) async {
    try {
      for (final s in slots) {
        final kq = await _api.tuXacNhan(_bookingId, s.slotIndex);
        if (!mounted) return false;
        setState(() => _ketQua = kq);
      }
      return true;
    } on Exception catch (loi) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(moTaLoiDonNcc(context, loi))));
      return false;
    }
  }

  Future<void> _tuXacNhanMotBe(SlotQuet slot) async {
    setState(() => _dangGoi = true);
    await _kyCacSlot([slot]);
    if (mounted) setState(() => _dangGoi = false);
  }

  Future<void> _batDau() async {
    setState(() => _dangGoi = true);
    final xong = await _kyCacSlot(_ketQua.slotCanTuXacNhan);
    if (!xong || !mounted) {
      if (mounted) setState(() => _dangGoi = false);
      return;
    }
    final batDau = await chayHanhDongDon(
      context,
      ref,
      _bookingId,
      (s) => s.batDauPhien(_bookingId),
    );
    if (!mounted) return;
    setState(() => _dangGoi = false);
    if (batDau) context.go(AppRoutes.sitterActiveServicePath(_bookingId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final don = widget.args.don;
    final dangQuet = _ketQua.man == ManQuetAi.dangQuet;
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
                      Text(l10n.anhCheckIn, style: AppTextStyles.h3),
                      const SizedBox(height: 2),
                      Text(
                        l10n.maDonDichVuSoBe(
                          don.maDon,
                          don.tenDichVu.split(' · ').first,
                          '$_soBe',
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
        padding: const EdgeInsets.only(top: 18, bottom: 24),
        children: [
          FlatSection(child: _dongKetLuan(l10n)),
          const SizedBox(height: 16),
          for (final slot in _ketQua.slotBe)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FlatSection(
                child: AiScanHangBe(slot: slot, dangQuet: dangQuet),
              ),
            ),
          if (dangQuet && _ketQua.slots.isEmpty && !_quaHanCho)
            const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 4),
          if (_ketQua.slots.isNotEmpty) ...[
            if (dangQuet) ...[
              FlatSection(
                child: Text(
                  l10n.anhDaGuiSo('${_ketQua.slots.length}'),
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: 12),
            ],
            AiScanDaiAnh(slots: _ketQua.slots),
          ],
          if (_ketQua.man == ManQuetAi.hetLanChup) ...[
            const FlatDivider(),
            FlatSection(
              child: Text(
                l10n.moTaVanXaTuXacNhan,
                style: AppTextStyles.captionSm,
              ),
            ),
          ],
          if (_ketQua.man == ManQuetAi.aiDu) ...[
            const FlatDivider(),
            FlatSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.sauKhiBatDau, style: AppTextStyles.h3),
                  const SizedBox(height: 10),
                  Text(l10n.moTaSauKhiBatDau, style: AppTextStyles.captionSm),
                ],
              ),
            ),
          ],
        ],
      ),
      bottomBar: _thanhNut(l10n),
    );
  }

  Widget _dongKetLuan(AppLocalizations l10n) {
    final vuong = _ketQua.slotDangVuong;
    final be = vuong == null ? '' : l10n.beThuMay('${vuong.slotIndex}');
    final (String chinh, String? phu) = switch (_ketQua.man) {
      ManQuetAi.dangQuet => (
        _quaHanCho
            ? l10n.khongNhanDuocKetQuaQuet
            : l10n.aiDangQuetNTam('$_soBe', '$_soBe'),
        null,
      ),
      ManQuetAi.aiDu => (l10n.aiXacMinhDuCaNBe('$_soBe'), null),
      ManQuetAi.chuaQuaKiem => (
        l10n.beChuaQuaKiem(be),
        l10n.conNLanChupLai('${vuong?.soLanConLai ?? 0}'),
      ),
      ManQuetAi.hetLanChup => (l10n.aiVanKhongDocDuoc(be), l10n.hetLuotChup),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(chinh, style: AppTextStyles.h3)),
        if (phu != null) ...[
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(phu, style: AppTextStyles.captionSm),
          ),
        ],
      ],
    );
  }

  Widget _thanhNut(AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralLight)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(leMucPhang, 10, leMucPhang, 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: _nut(l10n)),
        ),
      ),
    );
  }

  List<Widget> _nut(AppLocalizations l10n) {
    final vuong = _ketQua.slotDangVuong;
    final be = vuong == null ? '' : l10n.beThuMay('${vuong.slotIndex}');
    final canKy = _ketQua.slotCanTuXacNhan.isNotEmpty;
    return switch (_ketQua.man) {
      ManQuetAi.dangQuet => [
        AppButton(
          text: _quaHanCho ? l10n.taiLaiKetQua : l10n.dangQuetChamCham,
          height: 50,
          enabled: _quaHanCho,
          onTap: _thuLai,
        ),
      ],
      ManQuetAi.aiDu => [
        AppButton(
          text: canKy ? l10n.tuXacNhanVaBatDau : l10n.batDauDichVu,
          height: 50,
          enabled: _ketQua.batDauDuoc,
          dangTai: _dangGoi,
          onTap: _batDau,
        ),
      ],
      ManQuetAi.chuaQuaKiem => [
        AppButton(
          text: l10n.chupLaiBe(be),
          height: 50,
          enabled: vuong != null,
          onTap: () => _chupLai(vuong!),
        ),
      ],
      ManQuetAi.hetLanChup => [
        AppButton(
          text: l10n.toiXacNhanBeDaDeoDu(be),
          height: 50,
          enabled: vuong != null,
          dangTai: _dangGoi,
          onTap: () => _tuXacNhanMotBe(vuong!),
        ),
      ],
    };
  }
}
