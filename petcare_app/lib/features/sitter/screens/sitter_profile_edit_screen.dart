import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/sitter/data/sitter_profile.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/shared/widgets/locked_field.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_avatar_picker.dart';
import 'package:petcare_app/features/sitter/widgets/profile/sitter_photos_section.dart';
import 'package:petcare_app/shared/utils/date_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_loading_overlay.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/bottom_action_bar.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Màn Sửa trang cá nhân NCC
class SitterProfileEditScreen extends ConsumerStatefulWidget {
  const SitterProfileEditScreen({super.key});

  @override
  ConsumerState<SitterProfileEditScreen> createState() =>
      _SitterProfileEditScreenState();
}

class _SitterProfileEditScreenState
    extends ConsumerState<SitterProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _bioController = TextEditingController();
  final _sdtController = TextEditingController();
  bool _daNap = false;
  bool _dangUpAvatar = false;
  String _tenGoc = '';
  String _bioGoc = '';
  String _sdtGoc = '';

  @override
  void dispose() {
    _tenController.dispose();
    _bioController.dispose();
    _sdtController.dispose();
    super.dispose();
  }

  // Nạp dữ liệu ban đầu vào các ô
  void _napLan1(SitterProfile p) {
    _tenController.text = p.fullName;
    _bioController.text = p.bio ?? '';
    _sdtController.text = p.phone ?? '';
    _tenGoc = _tenController.text;
    _bioGoc = _bioController.text;
    _sdtGoc = _sdtController.text;
    _daNap = true;
  }

  // Chọn ảnh đại diện và tải lên ngay
  Future<void> _chonAvatar() async {
    final l10n = context.l10n;
    setState(() => _dangUpAvatar = true);
    try {
      if (await ref.read(sitterMeProvider.notifier).chonVaDoiAvatar()) {
        ref.invalidate(currentUserProvider);
      }
    } catch (_) {
      _thongBao(l10n.luuThatBai);
    } finally {
      if (mounted) setState(() => _dangUpAvatar = false);
    }
  }

  // Chọn ảnh thư viện và tải lên ngay
  Future<void> _themAnh() async {
    final l10n = context.l10n;
    final kq = await showAppLoading(
      context,
      ref.read(sitterMeProvider.notifier).chonVaThemAnh,
    );
    switch (kq) {
      case KetQuaThemAnh.dayAnh || KetQuaThemAnh.motPhan:
        _thongBao(l10n.daDatToiDaAnh('$maxSitterPhotos'));
      case KetQuaThemAnh.loi:
        _thongBao(l10n.luuThatBai);
      case KetQuaThemAnh.thanhCong || KetQuaThemAnh.huy:
        break;
    }
  }

  // avatar và ảnh đã tải lên ngay lúc chọn
  Future<void> _luu() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    try {
      await ref
          .read(sitterMeProvider.notifier)
          .luuHoSo(
            fullName: _tenController.text.trim(),
            bio: _bioController.text.trim(),
            phone: _sdtController.text.trim(),
          );
      ref.invalidate(currentUserProvider);
      // Lưu xong thoát về màn view
      if (mounted) context.pop();
    } catch (_) {
      _thongBao(l10n.luuThatBai);
    }
  }

  void _thongBao(String noiDung) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(noiDung)));
  }

  // Có thay đổi văn bản chưa lưu
  bool get _coThayDoi =>
      _tenController.text.trim() != _tenGoc.trim() ||
      _bioController.text.trim() != _bioGoc.trim() ||
      _sdtController.text.trim() != _sdtGoc.trim();

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(sitterMeProvider);
    final p = async.value;
    if (!_daNap && p != null) _napLan1(p);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _thoat();
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppScreenHeader(title: l10n.suaTrangCaNhan, onBack: _thoat),
              const AppDongKe(),
              Expanded(
                child: p == null
                    ? Center(
                        child: async.hasError
                            ? Text(l10n.khongTaiDuocDuLieu)
                            : const CircularProgressIndicator(),
                      )
                    : _form(l10n, p),
              ),
              if (p != null) _thanhLuu(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(AppLocalizations l10n, SitterProfile p) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.stackGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          SitterAvatarPicker(
            name: _tenController.text,
            avatarUrl: p.avatarUrl,
            dangUp: _dangUpAvatar,
            onDoi: _chonAvatar,
          ),
          const SizedBox(height: AppSpacing.blockGap),
          _Nhan(l10n.hoVaTen),
          const SizedBox(height: AppSpacing.itemGap),
          _ONhap(
            controller: _tenController,
            hint: l10n.nhapHoVaTen,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.vuiLongNhapHoTen : null,
          ),
          const SizedBox(height: AppSpacing.groupGap),
          _Nhan(l10n.gioiThieuBanThan),
          const SizedBox(height: AppSpacing.itemGap),
          _ONhap(
            controller: _bioController,
            hint: l10n.hintGioiThieu,
            minLines: 4,
            maxLines: 6,
            maxLength: 500,
          ),
          const SizedBox(height: AppSpacing.groupGap),
          SitterPhotosSection(anh: p.photos, onThem: _themAnh),
          const SizedBox(height: AppSpacing.blockGap),

          // Nhóm thông tin cá nhân (chỉ đọc)
          Text(l10n.thongTinCaNhan, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.stackGap),
          LockedField(
            nhanTrong: true,
            label: l10n.email,
            value: p.email ?? l10n.chuaCapNhat,
            verified: p.email != null,
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _Nhan(l10n.soDienThoai),
          const SizedBox(height: AppSpacing.itemGap),
          _ONhap(
            controller: _sdtController,
            hint: l10n.nhapSoDienThoai,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
          ),
          const SizedBox(height: AppSpacing.itemGap),
          LockedField(
            nhanTrong: true,
            label: l10n.ngaySinh,
            value: p.dateOfBirth == null
                ? l10n.chuaCapNhat
                : dinhDangNgay(p.dateOfBirth!),
            khoa: true,
          ),
          const SizedBox(height: AppSpacing.itemGap),
          LockedField(
            nhanTrong: true,
            label: l10n.gioiTinh,
            value: _gioiTinh(l10n, p.gender),
            khoa: true,
          ),
        ],
      ),
    );
  }

  Widget _thanhLuu(AppLocalizations l10n) {
    return BottomActionBar(
      child: AppButton(
        text: l10n.luuTrangCaNhan,
        icon: Icons.check,
        onTapAsync: _luu,
      ),
    );
  }

  static String _gioiTinh(AppLocalizations l10n, String? g) => switch (g) {
    'MALE' => l10n.gioiTinhNam,
    'FEMALE' => l10n.gioiTinhNu,
    'OTHER' => l10n.gioiTinhKhac,
    _ => l10n.chuaCapNhat,
  };
}

// Nhãn của một trường
class _Nhan extends StatelessWidget {
  const _Nhan(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.label);
}

// Ô nhập trực tiếp
class _ONhap extends StatelessWidget {
  const _ONhap({
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder vien(Color mau, double rong) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      borderSide: BorderSide(color: mau, width: rong),
    );
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: vien(AppColors.neutral, 1),
        focusedBorder: vien(AppColors.primaryColor, 1.5),
        errorBorder: vien(AppColors.error, 1),
        focusedErrorBorder: vien(AppColors.error, 1.5),
      ),
    );
  }
}
