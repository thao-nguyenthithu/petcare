import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/wallet/data/wallet_api.dart';
import 'package:petcare_app/features/wallet/data/wallet_error.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/features/wallet/providers/wallet_refresh.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/shared/widgets/vi_blocks.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/chip_chon.dart';

// Ba mức rút nhanh cho đỡ phải gõ
const List<int> _mucNhanh = [500000, 1000000, 2000000];

class SitterWithdrawScreen extends ConsumerStatefulWidget {
  const SitterWithdrawScreen({super.key});

  @override
  ConsumerState<SitterWithdrawScreen> createState() =>
      _SitterWithdrawScreenState();
}

class _SitterWithdrawScreenState extends ConsumerState<SitterWithdrawScreen> {
  final _controller = TextEditingController();

  int _soTien = 0;
  bool _dangGui = false;

  ViNguoiCham get _vi {
    final api = ref.watch(viCuaToiProvider).value;
    return api == null
        ? const ViNguoiCham(
            soDuKhaDung: 0,
            daNhanTrongThang: 0,
            thangHienTai: 1,
            khoanGiuTam: [],
            thuNhapTuanNay: 0,
            cotTuanNay: [],
            chiSoHomNay: 0,
          )
        : viTuApi(context.l10n, api);
  }

  @override
  void initState() {
    super.initState();
    _dat(_mucNhanh.last);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dat(int so) {
    _controller.text = dinhDangTien(so);
    setState(() => _soTien = so);
  }

  TaiKhoanNganHangApi? get _taiKhoan =>
      ref.watch(taiKhoanNhanTienProvider).value;

  bool get _conLuot => (_taiKhoan?.soLuotConLai ?? 1) > 0;

  int get _rutToiThieu => ref.watch(cauHinhNghiepVuProvider).rutToiThieu;

  String? _loi(BuildContext context) {
    final l10n = context.l10n;
    if (!_conLuot) return l10n.loiHetLuotRutHomNay;
    if (_soTien == 0) return null;
    if (_soTien < _rutToiThieu) {
      return l10n.soTienRutToiThieu(dinhDangTien(_rutToiThieu));
    }
    if (_soTien > _vi.soDuKhaDung) return l10n.soTienVuotSoDu;
    return null;
  }

  Future<void> _rut() async {
    final l10n = context.l10n;
    setState(() => _dangGui = true);
    try {
      await ref.read(walletApiProvider).rut(_soTien);
      ref.refreshWalletData(boQua: [viCuaToiProvider]);
      await ref.read(viCuaToiProvider.notifier).taiLai();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.daTaoLenhRut)));
      context.pop();
    } catch (loi) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(moTaLoiVi(context, loi, rutToiThieu: _rutToiThieu)),
        ),
      );
    } finally {
      if (mounted) setState(() => _dangGui = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loi = _loi(context);
    final hopLe = loi == null && _soTien > 0;
    final nganHang = _vi.nganHang;

    return AppScreen(
      header: AppScreenHeader(title: l10n.rutTienVeNganHang),
      bottomBar: BottomActionBar(
        child: FilledButton(
          onPressed: hopLe && !_dangGui ? _rut : null,
          child: Text(l10n.xacNhanRutTien),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.labelGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          _OSoTien(
            controller: _controller,
            soDu: _vi.soDuKhaDung,
            rutToiThieu: _rutToiThieu,
            loi: loi,
            onChanged: (s) => setState(() => _soTien = docSoTien(s) ?? 0),
            onRutToanBo: () => _dat(_vi.soDuKhaDung),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          Row(
            children: [
              for (final muc in _mucNhanh) ...[
                Expanded(
                  child: ChipChon(
                    nhan: '${dinhDangTien(muc)}đ',
                    chon: _soTien == muc,
                    onTap: () => _dat(muc),
                    canGiua: true,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    mauNenChon: AppColors.cardMint,
                    mauChuChon: AppColors.primaryColor,
                  ),
                ),
                if (muc != _mucNhanh.last)
                  const SizedBox(width: AppSpacing.labelGap),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          if (nganHang != null)
            ViCard(
              child: BankAccountCard(
                taiKhoan: nganHang,
                duoi: TextButton(
                  onPressed: () => context.push(AppRoutes.sitterBankAccount),
                  child: Text(l10n.doi),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.stackGap),
          ViCard(
            child: ViMoneyRows(
              dong: <DongHoaDon>[
                (nhan: l10n.soTienRut, tien: _soTien),
                (nhan: l10n.phiChuyen, tien: 0),
              ],
              tong: (nhan: l10n.thucNhanVeNganHang, tien: _soTien),
              mauTong: AppColors.primaryColor,
            ),
          ),
          // Cho biết còn mấy lượt trước khi bấm
          if (_taiKhoan?.soLuotConLai case final conLai?) ...[
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              l10n.conLuotRutTrongNgay(
                '$conLai',
                '${_taiKhoan?.soLuotMoiNgay ?? conLai}',
              ),
              style: AppTextStyles.captionSm,
            ),
          ],
        ],
      ),
    );
  }
}

class _OSoTien extends StatelessWidget {
  const _OSoTien({
    required this.controller,
    required this.soDu,
    required this.rutToiThieu,
    required this.loi,
    required this.onChanged,
    required this.onRutToanBo,
  });

  final TextEditingController controller;
  final int soDu;
  final int rutToiThieu;
  final String? loi;
  final ValueChanged<String> onChanged;
  final VoidCallback onRutToanBo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final coLoi = loi != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(
          color: coLoi ? AppColors.error : AppColors.primaryColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.soTienMuonRut, style: AppTextStyles.captionSm),
          const SizedBox(height: AppSpacing.textGap),
          TextField(
            controller: controller,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            inputFormatters: const [DinhDangTienFormatter()],
            style: AppTextStyles.h1,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              suffixText: 'đ',
              suffixStyle: AppTextStyles.h1,
            ),
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Row(
            children: [
              Expanded(
                child: Text(
                  loi ??
                      l10n.khaDungToiThieu(
                        dinhDangTien(soDu),
                        dinhDangTien(rutToiThieu),
                      ),
                  style: AppTextStyles.captionSm.copyWith(
                    color: coLoi ? AppColors.error : null,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.labelGap),
              InkWell(
                onTap: onRutToanBo,
                child: Text(
                  l10n.rutToanBo,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
