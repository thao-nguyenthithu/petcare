import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';

// Map mã lỗi backend sang chuỗi hiển thị theo ngôn ngữ đang chọn
String mapAuthError(AppLocalizations l10n, Object error) {
  if (error is FirebaseAuthException) {
    return error.code == 'account-exists-with-different-credential'
        ? l10n.loiEmailDaDangNhapCachKhac
        : l10n.loiDangNhapMangXaHoiThatBai;
  }
  switch (AuthApiService.codeFromError(error)) {
    case 'EMAIL_ALREADY_USED':
      return l10n.loiEmailDaSuDung;
    case 'PHONE_ALREADY_USED':
      return l10n.loiSoDienThoaiDaSuDung;
    case 'USER_NOT_FOUND':
      return l10n.loiTaiKhoanKhongTonTai;
    case 'EMAIL_ALREADY_VERIFIED':
      return l10n.loiEmailDaXacMinh;
    case 'OTP_INVALID':
      return l10n.loiMaOtpKhongDung;
    case 'OTP_EXPIRED':
      return l10n.loiMaOtpHetHan;
    case 'OTP_COOLDOWN':
      return l10n.loiGuiLaiOtpQuaSom;
    case 'OTP_LOCKED':
      return l10n.loiOtpBiKhoa(AuthApiService.metaInt(error, 'minutes') ?? 5);
    case 'INVALID_CREDENTIALS':
      return l10n.loiThongTinDangNhap;
    case 'EMAIL_NOT_VERIFIED':
      return l10n.loiEmailChuaXacMinh;
    case 'SOCIAL_NOT_CONFIGURED':
      return l10n.loiMangXaHoiChuaCauHinh;
    case 'INVALID_SOCIAL_TOKEN':
      return l10n.loiTokenMangXaHoi;
    case 'SOCIAL_NO_EMAIL':
      return l10n.loiMangXaHoiThieuEmail;
    case 'RESET_TOKEN_INVALID':
      return l10n.loiPhienDatLaiHetHan;
  }
  return AuthApiService.messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
