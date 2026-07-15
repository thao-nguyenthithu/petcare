import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';

/// Map mã lỗi backend sang chuỗi hiển thị theo ngôn ngữ đang chọn của app
String mapAuthError(AppLocalizations l10n, Object error) {
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
  }
  return AuthApiService.messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
