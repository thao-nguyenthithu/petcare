import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/notification/data/mock_notification_data.dart';
import 'package:petcare_app/features/notification/widgets/notification_tile.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';

// Màn Thông báo Tất cả Chưa đọc, chia nhóm Hôm nay và Trước đó
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _chiHienChuaDoc = false;

  final Set<String> _vuaDocThem = {};

  bool _daDoc(MockNotification n) => n.daDoc || _vuaDocThem.contains(n.id);

  int get _soChuaDoc => MockNotification.tatCa.where((n) => !_daDoc(n)).length;

  List<MockNotification> _loc(List<MockNotification> nguon) =>
      _chiHienChuaDoc ? nguon.where((n) => !_daDoc(n)).toList() : nguon;

  void _docTatCa() {
    setState(() {
      _vuaDocThem.addAll(MockNotification.tatCa.map((n) => n.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trong = MockNotification.tatCa.isEmpty;
    final canXuLy = _loc(MockNotification.canXuLyNgay);
    final homNay = _loc(MockNotification.homNay);
    final truocDo = _loc(MockNotification.truocDo);
    return Scaffold(
      body: SafeArea(
        child: trong
            ? Column(
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
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppScreenHeader(
                          title: l10n.thongBao,
                          action: TextButton(
                            onPressed: _soChuaDoc == 0 ? null : _docTatCa,
                            child: Text(
                              l10n.docTatCa,
                              style: AppTextStyles.label.copyWith(
                                color: _soChuaDoc == 0
                                    ? AppColors.textSecondary
                                    : AppColors.accent,
                              ),
                            ),
                          ),
                        ),
                        _HangLoc(
                          chiHienChuaDoc: _chiHienChuaDoc,
                          soChuaDoc: _soChuaDoc,
                          onChon: (chuaDoc) =>
                              setState(() => _chiHienChuaDoc = chuaDoc),
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
                  ..._nhom(l10n.canXuLy, canXuLy),
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

  List<Widget> _nhom(String tieuDe, List<MockNotification> items) {
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
              daDocGhiDe: _daDoc(items[index]),
            ),
          ),
        ),
      ),
    ];
  }
}

class _HangLoc extends StatelessWidget {
  const _HangLoc({
    required this.chiHienChuaDoc,
    required this.soChuaDoc,
    required this.onChon,
  });

  final bool chiHienChuaDoc;
  final int soChuaDoc;
  final ValueChanged<bool> onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          Material(
            color: AppColors.surface,
            shape: const StadiumBorder(),
            elevation: 2,
            shadowColor: AppColors.shadow,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.textGap),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MucLoc(
                    chu: l10n.tatCa,
                    dangChon: !chiHienChuaDoc,
                    onTap: () => onChon(false),
                  ),
                  _MucLoc(
                    chu: l10n.chuaDoc,
                    dangChon: chiHienChuaDoc,
                    onTap: () => onChon(true),
                  ),
                ],
              ),
            ),
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

class _MucLoc extends StatelessWidget {
  const _MucLoc({
    required this.chu,
    required this.dangChon,
    required this.onTap,
  });

  static const Duration _thoiLuong = Duration(milliseconds: 200);

  final String chu;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _thoiLuong,
      curve: Curves.easeOut,
      decoration: ShapeDecoration(
        color: dangChon ? AppColors.primaryColor : Colors.transparent,
        shape: const StadiumBorder(),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.blockGap,
              vertical: AppSpacing.labelGap,
            ),
            child: AnimatedDefaultTextStyle(
              duration: _thoiLuong,
              curve: Curves.easeOut,
              style: AppTextStyles.label.copyWith(
                color: dangChon ? AppColors.textWhite : AppColors.textPrimary,
              ),
              child: Text(chu),
            ),
          ),
        ),
      ),
    );
  }
}
