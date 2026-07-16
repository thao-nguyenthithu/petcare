import 'package:petcare_app/core/l10n/generated/app_localizations.dart';

class Validators {
  final AppLocalizations l10n;

  const Validators(this.l10n);

  String? email(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.vuiLongNhapEmail;
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value.trim())) return l10n.emailKhongHopLe;
    return null;
  }

  String? password(String? value) {
    if (value == null || value.isEmpty) return l10n.vuiLongNhapMatKhau;
    if (value.length < 6) return l10n.toiThieu6KyTu;
    return null;
  }

  /// So khớp với mật khẩu đã nhập ở ô trước
  String? confirmPassword(String? value, String password) {
    if (value != password) return l10n.matKhauKhongKhop;
    return null;
  }

  String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.vuiLongNhapHoTen;
    return null;
  }

  String? notEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.khongDuocDeTrong;
    return null;
  }

  String? citizenId(String? value) {
    if (value == null || value.trim().isEmpty) return l10n.khongDuocDeTrong;
    if (!RegExp(r'^\d{12}$').hasMatch(value.trim())) {
      return l10n.cccdKhongHopLe;
    }
    return null;
  }

  String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.vuiLongNhapSoDienThoai;
    }
    final pattern = RegExp(r'^(0|\+84)[35789]\d{8}$');
    if (!pattern.hasMatch(value.trim())) return l10n.soDienThoaiKhongHopLe;
    return null;
  }
}
