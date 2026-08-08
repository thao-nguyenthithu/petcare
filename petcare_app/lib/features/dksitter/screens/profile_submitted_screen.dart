import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/dksitter/data/yeu_cau_sua_ho_so.dart';
import 'package:petcare_app/features/dksitter/providers/dksitter_provider.dart';
import 'package:petcare_app/features/dksitter/services/dksitter_api_service.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/success_badge.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

// Màn kết quả hồ sơ NCC: chờ duyệt, hoặc lời nhắn sửa của quản trị viên
class ProfileSubmittedScreen extends ConsumerStatefulWidget {
  const ProfileSubmittedScreen({super.key});

  @override
  ConsumerState<ProfileSubmittedScreen> createState() =>
      _ProfileSubmittedScreenState();
}

class _ProfileSubmittedScreenState
    extends ConsumerState<ProfileSubmittedScreen> {
  late Future<YeuCauSuaHoSo?> _yeuCau;
  bool _dangNap = false;

  @override
  void initState() {
    super.initState();
    _taiLai();
  }

  void _taiLai() {
    _yeuCau = DkSitterApiService().getMine().then(YeuCauSuaHoSo.tuHoSo);
  }

  Future<void> _suaHoSo() async {
    setState(() => _dangNap = true);
    try {
      await ref.read(dkSitterProvider.notifier).napHoSoDaGui();
      if (!mounted) return;
      context.push(AppRoutes.sitterPersonalInfo);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.loiKetNoiMayChu)));
    } finally {
      if (mounted) setState(() => _dangNap = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<YeuCauSuaHoSo?>(
          future: _yeuCau,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return AppNetworkError(onRetry: () => setState(_taiLai));
            }
            return _noiDung(snapshot.data);
          },
        ),
      ),
    );
  }

  Widget _noiDung(YeuCauSuaHoSo? yeuCau) {
    final l10n = context.l10n;
    final canSua = yeuCau != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          Center(child: canSua ? const _HuyBadge() : const SuccessBadge()),
          const SizedBox(height: 32),
          Text(
            switch (yeuCau?.loai) {
              LoaiYeuCauSua.boSung => l10n.hoSoCanBoSung,
              LoaiYeuCauSua.tuChoi => l10n.hoSoChuaDuocDuyet,
              null => l10n.daGuiHoSo,
            },
            textAlign: TextAlign.center,
            style: AppTextStyles.h1,
          ),
          const SizedBox(height: 14),
          Text(
            canSua ? l10n.suaLaiRoiGuiLai : l10n.hoSoDangXemXet,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 24),
          AppCard(
            nen: AppColors.cardMint,
            vien: false,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset('assets/icons/paw.svg', width: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: canSua
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.yeuCauTuQuanTri,
                              style: AppTextStyles.label,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              yeuCau.lyDo ?? '',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          l10n.trongLucChoDungChuNuoi,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
          if (canSua)
            AppButton(
              text: l10n.suaHoSo,
              height: 56,
              enabled: !_dangNap,
              dangTai: _dangNap,
              onTap: _suaHoSo,
            )
          else
            AppButton(
              text: l10n.veTrangChu,
              height: 56,
              onTap: () => context.go(AppRoutes.home),
            ),
          if (canSua) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(
                  l10n.veTrangChu,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HuyBadge extends StatelessWidget {
  const _HuyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.neutralLight,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.assignment_late_outlined,
          size: 56,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
