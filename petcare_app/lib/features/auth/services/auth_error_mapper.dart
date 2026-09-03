import 'package:firebase_auth/firebase_auth.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/features/auth/services/social_auth_service.dart';
import 'package:petcare_app/shared/utils/loi_vai_tro.dart';

// Map mã lỗi backend sang chuỗi hiển thị theo ngôn ngữ đang chọn
String mapAuthError(AppLocalizations l10n, Object error) {
  if (error is LoiEmailDaCoCachKhac) {
    return l10n.loiEmailDaDangNhapCachKhac;
  }
  if (error is FirebaseAuthException) {
    return l10n.loiDangNhapMangXaHoiThatBai;
  }
  final loiVai = moTaLoiVaiTro(l10n, error);
  if (loiVai != null) return loiVai;
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
    case 'THIEU_ANH':
      return l10n.loiThieuAnh;
    case 'NGAY_SINH_KHONG_HOP_LE':
      return l10n.loiNgaySinhKhongHopLe;
    case 'DANG_KY_HET_HAN':
      return l10n.loiDangKyHetHan;
    case 'CHUA_DANG_NHAP':
      return l10n.loiTokenKhongHopLe;
    case 'TAI_KHOAN_KHONG_HOAT_DONG':
      return l10n.loiTaiKhoanKhongHoatDong;
    case 'PHIEN_DA_HET_HIEU_LUC':
      return l10n.loiPhienDaHetHieuLuc;
  }
  return AuthApiService.messageFromError(error) ?? l10n.loiKetNoiMayChu;
}
