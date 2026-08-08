import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/ket_qua_vi_tri.dart';
import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn Địa chỉ đã lưu
class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  bool _dangChon = false;
  final Set<String> _daChon = {};

  void _vaoChon(String id) => setState(() {
    _dangChon = true;
    _daChon.add(id);
  });

  void _toggle(String id) => setState(() {
    if (!_daChon.remove(id)) _daChon.add(id);
    if (_daChon.isEmpty) _dangChon = false;
  });

  void _thoatChon() => setState(() {
    _dangChon = false;
    _daChon.clear();
  });

  Future<void> _xoaDaChon() async {
    final l10n = context.l10n;
    final soLuong = _daChon.length;
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.xoaSoDiaChiDaChon(soLuong),
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.itemGap),
              Text(
                l10n.xacNhanXoaDiaChi,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.groupGap),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.huy,
                      outlined: true,
                      onTap: () => context.pop(false),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.itemGap),
                  Expanded(
                    child: AppButton(
                      text: l10n.xoa,
                      onTap: () => context.pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (dongY != true) return;
    final ids = {..._daChon};
    _thoatChon();
    await ref.read(savedAddressesProvider.notifier).xoaNhieu(ids);
  }

  // Thêm mới: mở bản đồ chọn vị trí trước, rồi mới sang form nhập thông tin
  Future<void> _themMoi() async {
    final kq = await context.push<KetQuaViTri>(AppRoutes.locationPicker);
    if (kq == null || !mounted) return;
    if (context.mounted) context.push(AppRoutes.addAddress, extra: kq);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final asyncDanhSach = ref.watch(savedAddressesProvider);
    return PopScope(
      canPop: !_dangChon,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _thoatChon();
      },
      child: AppScreen(
        header: AppScreenHeader(
          title: l10n.diaChiDaLuu,
          onBack: _dangChon ? _thoatChon : null,
          action: _dangChon
              ? IconButton(
                  onPressed: _daChon.isEmpty ? null : _xoaDaChon,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.xoa,
                  color: AppColors.error,
                )
              : null,
        ),
        body: AppRefreshIndicator(
          onRefresh: () => ref.read(savedAddressesProvider.future),
          child: asyncDanhSach.when(
            loading: () => const AppSkeletonList(soThe: 3, caoThe: 92),
            error: (_, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPaddingWide),
                child: Text(
                  l10n.taiDiaChiThatBai,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.captionSm,
                ),
              ),
            ),
            data: (danhSach) => danhSach.isEmpty
                ? _TrongRong(onThem: _themMoi)
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    children: [
                      for (final diaChi in danhSach) ...[
                        _AddressCard(
                          diaChi: diaChi,
                          dangChon: _dangChon,
                          daChon: _daChon.contains(diaChi.id),
                          onChonMacDinh: () => ref
                              .read(savedAddressesProvider.notifier)
                              .chonMacDinh(diaChi.id),
                          onSua: () =>
                              context.push(AppRoutes.addAddress, extra: diaChi),
                          onVaoChon: () => _vaoChon(diaChi.id),
                          onToggle: () => _toggle(diaChi.id),
                        ),
                        const SizedBox(height: AppSpacing.stackGap),
                      ],
                      if (!_dangChon) ...[
                        AppButton(
                          text: l10n.themDiaChiMoi,
                          icon: Icons.add,
                          outlined: true,
                          onTap: _themMoi,
                        ),
                        const SizedBox(height: AppSpacing.stackGap),
                        Text(
                          l10n.ghiChuDiaChiMacDinh,
                          style: AppTextStyles.captionSm,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.diaChi,
    required this.dangChon,
    required this.daChon,
    required this.onChonMacDinh,
    required this.onSua,
    required this.onVaoChon,
    required this.onToggle,
  });

  final SavedAddress diaChi;
  final bool dangChon;
  final bool daChon;
  final VoidCallback onChonMacDinh;
  final VoidCallback onSua;
  final VoidCallback onVaoChon;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final noiBat = dangChon ? daChon : diaChi.isDefault;
    return ButtonSelect(
      selected: noiBat,
      title: diaChi.tenNhan(l10n.nha, l10n.congTy, l10n.khac),
      subtitle: diaChi.diaChiDayDu,
      subtitleColor: AppColors.textPrimary,
      note: diaChi.ghiChu,
      badge: diaChi.isDefault ? const _BadgeMacDinh() : null,
      leading: dangChon
          ? Icon(
              daChon ? Icons.check_box : Icons.check_box_outline_blank,
              color: daChon ? AppColors.accent : AppColors.neutral,
              size: 22,
            )
          : null,
      onTap: dangChon ? onToggle : onChonMacDinh,
      onLongPress: dangChon ? null : onVaoChon,
      trailing: dangChon
          ? null
          : IconButton(
              onPressed: onSua,
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.textSecondary,
              visualDensity: VisualDensity.compact,
            ),
    );
  }
}

// Nhãn Mặc định nền mint
class _BadgeMacDinh extends StatelessWidget {
  const _BadgeMacDinh();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.macDinh,
        style: AppTextStyles.captionSm.copyWith(color: AppColors.primaryColor),
      ),
    );
  }
}

// Danh sách rỗng khi xoá hết địa chỉ
class _TrongRong extends StatelessWidget {
  const _TrongRong({required this.onThem});

  final VoidCallback onThem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingWide),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppColors.neutral,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            Text(l10n.chuaCoDiaChiNao, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.labelGap),
            Text(
              l10n.themDiaChiDauTien,
              textAlign: TextAlign.center,
              style: AppTextStyles.captionSm,
            ),
            const SizedBox(height: AppSpacing.groupGap),
            AppButton(text: l10n.themDiaChi, icon: Icons.add, onTap: onThem),
          ],
        ),
      ),
    );
  }
}
