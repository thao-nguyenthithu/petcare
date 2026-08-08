import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/notification/data/thong_bao.dart';
import 'package:petcare_app/features/notification/dieu_huong_thong_bao.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/notification/providers/notifications_provider.dart';
import 'package:petcare_app/features/notification/widgets/notification_tile.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Lọc vai bằng tab khi tài khoản mang cả hai vai
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key, this.dangCheDoNcc = false});
  final bool dangCheDoNcc;

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  VaiNhan? _vai;
  bool _chiHienChuaDoc = false;
  bool get _coHaiVai =>
      ref.watch(currentUserProvider).asData?.value.laNguoiCham ?? false;

  VaiNhan? get _vaiDangXem => _coHaiVai ? _vai : VaiNhan.chuNuoi;

  List<ThongBao> _loc(List<ThongBao> nguon) =>
      _chiHienChuaDoc ? nguon.where((n) => !n.daDoc).toList() : nguon;

  void _moTin(ThongBao tin) {
    ref.read(thongBaoCuaToiProvider.notifier).danhDauDaDoc(tin.id);
    moThongBao(
      context,
      tin,
      dangCheDoNcc: widget.dangCheDoNcc,
      tomTatNcc: _coHaiVai
          ? ref.read(tomTatDonNccProvider).asData?.value
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(thongBaoCuaToiProvider);
    return Scaffold(
      body: SafeArea(
        child: switch (async) {
          AsyncData(:final value) => _noiDung(value),
          AsyncError() => Column(
            children: [
              AppScreenHeader(title: l10n.thongBao),
              Expanded(
                child: AppNetworkError(
                  onRetry: () =>
                      ref.read(thongBaoCuaToiProvider.notifier).taiLai(),
                ),
              ),
            ],
          ),
          _ => Column(
            children: [
              AppScreenHeader(title: l10n.thongBao),
              const AppSkeletonList(caoThe: _caoThe),
            ],
          ),
        },
      ),
    );
  }

  Widget _noiDung(List<ThongBao> tatCa) {
    final l10n = context.l10n;
    final vai = _vaiDangXem;
    final cuaVai = tatCa.theoVai(vai);
    final soChuaDoc = cuaVai.where((n) => !n.daDoc).length;
    final canXuLy = _loc(cuaVai.canXuLyNgay);
    final homNay = _loc(cuaVai.homNay);
    final truocDo = _loc(cuaVai.truocDo);
    final notifier = ref.read(thongBaoCuaToiProvider.notifier);

    if (cuaVai.isEmpty) {
      return Column(
        children: [
          AppScreenHeader(title: l10n.thongBao),
          const Spacer(),
          AppEmptyState(
            icon: Icons.notifications_none_rounded,
            title: l10n.chuaCoThongBao,
            message: l10n.moTaChuaCoThongBao,
          ),
          const Spacer(flex: 2),
        ],
      );
    }

    return AppRefreshIndicator(
      onRefresh: notifier.taiLai,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (n) {
          final m = n.metrics;
          if (m.pixels >= m.maxScrollExtent - 200) notifier.taiThem();
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppScreenHeader(
                    title: l10n.thongBao,
                    action: TextButton(
                      onPressed: soChuaDoc == 0 ? null : notifier.danhDauDocHet,
                      child: Text(
                        l10n.docTatCa,
                        style: AppTextStyles.label.copyWith(
                          color: soChuaDoc == 0
                              ? AppColors.textSecondary
                              : AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  if (_coHaiVai)
                    _TabVai(
                      vai: _vai,
                      soChuaDocTheoVai: {
                        for (final k in <VaiNhan?>[
                          null,
                          VaiNhan.chuNuoi,
                          VaiNhan.nguoiCham,
                        ])
                          k: tatCa.theoVai(k).where((n) => !n.daDoc).length,
                      },
                      onChon: (chon) => setState(() => _vai = chon),
                    ),
                  _HangLoc(
                    chiHienChuaDoc: _chiHienChuaDoc,
                    soChuaDoc: soChuaDoc,
                    onDoi: () =>
                        setState(() => _chiHienChuaDoc = !_chiHienChuaDoc),
                  ),
                  const SizedBox(height: AppSpacing.labelGap),
                ],
              ),
            ),
            if (canXuLy.isEmpty && homNay.isEmpty && truocDo.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: AppEmptyState(
                    icon: Icons.done_all_rounded,
                    title: l10n.chuaCoThongBao,
                    message: l10n.moTaChuaCoThongBao,
                  ),
                ),
              ),
            ..._nhom(l10n.canXuLyNgay, canXuLy),
            ..._nhom(l10n.homNay, homNay),
            ..._nhom(l10n.truocDo, truocDo),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.groupGap),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _nhom(String tieuDe, List<ThongBao> items) {
    if (items.isEmpty) return const [];
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.screenPadding,
            AppSpacing.labelGap,
          ),
          child: Text(tieuDe, style: AppTextStyles.h3),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
            child: NotificationTile(
              notification: items[index],
              hienVai: _coHaiVai,
              onTap: () => _moTin(items[index]),
            ),
          ),
        ),
      ),
    ];
  }
}

const double _caoThe = 92;

class _TabVai extends StatelessWidget {
  const _TabVai({
    required this.vai,
    required this.soChuaDocTheoVai,
    required this.onChon,
  });

  final VaiNhan? vai;
  final Map<VaiNhan?, int> soChuaDocTheoVai;
  final ValueChanged<VaiNhan?> onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muc = <(VaiNhan?, String)>[
      (null, l10n.tatCa),
      (VaiNhan.chuNuoi, l10n.chuNuoi),
      (VaiNhan.nguoiCham, l10n.nguoiCham),
    ];
    return DefaultTabController(
      length: muc.length,
      initialIndex: muc.indexWhere((e) => e.$1 == vai),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (i) => onChon(muc[i].$1),
        labelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.label,
        unselectedLabelStyle: AppTextStyles.label,
        indicatorColor: AppColors.primaryColor,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.neutralLight,
        tabs: [
          for (final (khoa, nhan) in muc)
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(nhan),
                  if ((soChuaDocTheoVai[khoa] ?? 0) > 0) ...[
                    const SizedBox(width: AppSpacing.textGap),
                    _ChamDem(so: soChuaDocTheoVai[khoa]!),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChamDem extends StatelessWidget {
  const _ChamDem({required this.so});

  static const double _canh = 18;

  final int so;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _canh,
      height: _canh,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$so',
        style: AppTextStyles.labelSm.copyWith(color: AppColors.textWhite),
      ),
    );
  }
}

class _HangLoc extends StatelessWidget {
  const _HangLoc({
    required this.chiHienChuaDoc,
    required this.soChuaDoc,
    required this.onDoi,
  });

  final bool chiHienChuaDoc;
  final int soChuaDoc;
  final VoidCallback onDoi;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: Row(
        children: [
          FilterChip(
            selected: chiHienChuaDoc,
            onSelected: (_) => onDoi(),
            showCheckmark: false,
            label: Text(l10n.chuaDoc),
          ),
          const Spacer(),
          if (soChuaDoc > 0)
            Text(
              l10n.soMoi('$soChuaDoc'),
              style: AppTextStyles.captionSm.copyWith(color: AppColors.accent),
            ),
        ],
      ),
    );
  }
}
