import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/core/utils/validators.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_text_box.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/locked_field.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';
import 'package:petcare_app/features/auth/providers/profile_refresh.dart';

const double _duongKinhAvatar = 88;
const int _tuoiToiThieu = 16;

// Màn Chỉnh sửa hồ sơ của chủ nuôi
class OwnerProfileEditScreen extends ConsumerStatefulWidget {
  const OwnerProfileEditScreen({super.key});

  @override
  ConsumerState<OwnerProfileEditScreen> createState() =>
      _OwnerProfileEditScreenState();
}

class _OwnerProfileEditScreenState
    extends ConsumerState<OwnerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _sdtController = TextEditingController();
  final _ngaySinhController = TextEditingController();

  bool _daNap = false;
  bool _dangUpAvatar = false;
  DateTime? _ngaySinh;
  String _tenGoc = '';
  String _sdtGoc = '';
  DateTime? _ngaySinhGoc;

  @override
  void dispose() {
    _tenController.dispose();
    _sdtController.dispose();
    _ngaySinhController.dispose();
    super.dispose();
  }

  // Nạp dữ liệu ban đầu vào các ô, chỉ một lần
  void _napLan1(CurrentUser u) {
    _daNap = true;
    _tenController.text = u.fullName;
    _sdtController.text = u.phone ?? '';
    _ngaySinh = u.dateOfBirth;
    _ngaySinhController.text = u.dateOfBirth == null
        ? ''
        : ngayThangNam(u.dateOfBirth!);
    _tenGoc = _tenController.text;
    _sdtGoc = _sdtController.text;
    _ngaySinhGoc = _ngaySinh;
  }

  bool get _laNguoiCham =>
      ref.watch(currentUserProvider).asData?.value.laNguoiCham ?? false;

  bool get _coThayDoi =>
      _tenController.text.trim() != _tenGoc.trim() ||
      _sdtController.text.trim() != _sdtGoc.trim() ||
      _ngaySinh != _ngaySinhGoc;

  Future<void> _chonNgaySinh() async {
    final homNay = homNayVn();
    final chon = await showDatePicker(
      context: context,
      initialDate:
          _ngaySinh ?? DateTime(homNay.year - 20, homNay.month, homNay.day),
      firstDate: DateTime(homNay.year - 100),
      lastDate: DateTime(homNay.year - _tuoiToiThieu, homNay.month, homNay.day),
    );
    if (chon == null || !mounted) return;
    setState(() {
      _ngaySinh = chon;
      _ngaySinhController.text = ngayThangNam(chon);
    });
  }

  Future<void> _thoat() async {
    if (!_coThayDoi) {
      if (mounted) context.pop();
      return;
    }
    final l10n = context.l10n;
    final dongY = await showConfirmDialog(
      context,
      icon: Icons.exit_to_app_rounded,
      title: l10n.thoatKhongLuuTitle,
      message: l10n.thoatKhongLuuMoTa,
      confirmLabel: l10n.thoatKhongLuu,
      danger: true,
    );
    if (dongY && mounted) context.pop();
  }

  Future<void> _doiAvatar() async {
    final chon = await chonMotAnh();
    if (!mounted) return;
    if (chon.quaNang) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.loiAnhQuaNang('$mbAnhToiDa'))),
      );
      return;
    }
    final bytes = chon.anh;
    if (bytes == null) return;
    setState(() => _dangUpAvatar = true);
    try {
      await AuthApiService().uploadAvatar(bytes);
      ref.refreshProfileData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.luuThatBai)));
      }
    } finally {
      if (mounted) setState(() => _dangUpAvatar = false);
    }
  }

  Future<void> _luu() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_coThayDoi) {
      context.pop();
      return;
    }
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ten = _tenController.text.trim();
    final sdt = _sdtController.text.trim();
    try {
      await AuthApiService().capNhatHoSo(
        fullName: ten == _tenGoc.trim() ? null : ten,
        phone: sdt == _sdtGoc.trim() ? null : sdt,
        dateOfBirth: _ngaySinh == _ngaySinhGoc
            ? null
            : (_ngaySinh == null ? '' : ngayIso(_ngaySinh!)),
      );
      ref.refreshProfileData();
      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.capNhatHoSoThanhCong)),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_loiLuu(l10n, e) ?? l10n.luuThatBai)),
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.luuThatBai)));
    }
  }

  String? _loiLuu(AppLocalizations l10n, DioException e) {
    final data = e.response?.data;
    if (data is! Map) return null;
    return data['code'] == 'PHONE_ALREADY_USED'
        ? l10n.loiSoDienThoaiDaSuDung
        : data['message'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(currentUserProvider);
    if (async.asData?.value case final u? when !_daNap) _napLan1(u);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _thoat();
      },
      child: AppScreen(
        backgroundColor: AppColors.surface,
        header: Column(
          children: [
            AppScreenHeader(title: l10n.chinhSuaHoSo, onBack: _thoat),
            const AppDongKe(),
          ],
        ),
        body: switch (async) {
          AsyncData(:final value) => _form(value),
          AsyncError() => AppNetworkError(
            onRetry: () => ref.invalidate(currentUserProvider),
          ),
          _ => const AppSkeletonList(soThe: 5, caoThe: 64),
        },
        bottomBar: async.hasValue
            ? BottomActionBar(
                child: AppButton(text: l10n.luuThayDoi, onTapAsync: _luu),
              )
            : null,
      ),
    );
  }

  Widget _form(CurrentUser u) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.blockGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    UserAvatar(
                      name: _tenController.text,
                      imageUrl: u.avatarUrl,
                      size: _duongKinhAvatar,
                    ),
                    if (_dangUpAvatar)
                      const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.itemGap),
                InkWell(
                  onTap: _dangUpAvatar ? null : _doiAvatar,
                  child: Text(
                    l10n.doiAnh,
                    style: AppTextStyles.label.copyWith(
                      color: _dangUpAvatar
                          ? AppColors.textSecondary
                          : AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.blockGap),
          AppFieldLabel(l10n.hoVaTen),
          const SizedBox(height: AppSpacing.labelGap),
          AppTextBox(
            controller: _tenController,
            hint: l10n.nhapHoVaTen,
            inputFormatters: [
              LengthLimitingTextInputFormatter(soKyTuHoTenToiDa),
            ],
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.vuiLongNhapHoTen : null,
          ),
          const SizedBox(height: AppSpacing.stackGap),
          AppFieldLabel(l10n.ngaySinh),
          const SizedBox(height: AppSpacing.labelGap),
          if (_laNguoiCham) ...[
            LockedField(
              value: switch (ref.watch(sitterMeProvider).asData?.value) {
                SitterProfile(dateOfBirth: final d?) => ngayThangNam(d),
                _ => l10n.chuaCapNhat,
              },
              verified: true,
            ),
            const SizedBox(height: AppSpacing.labelGap),
            Text(l10n.ngaySinhKhoaVaiNcc, style: AppTextStyles.captionSm),
          ] else
            AppTextBox(
              controller: _ngaySinhController,
              hint: l10n.chonNgaySinh,
              readOnly: true,
              onTap: _chonNgaySinh,
              duoi: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.stackGap),
          AppFieldLabel(l10n.soDienThoai),
          const SizedBox(height: AppSpacing.labelGap),
          AppTextBox(
            controller: _sdtController,
            hint: l10n.nhapSoDienThoai,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? null
                : Validators(l10n).phoneNumber(v),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          AppFieldLabel(l10n.email),
          const SizedBox(height: AppSpacing.labelGap),
          LockedField(
            value: u.email ?? l10n.chuaCapNhat,
            verified: u.emailVerified,
          ),
        ],
      ),
    );
  }
}
