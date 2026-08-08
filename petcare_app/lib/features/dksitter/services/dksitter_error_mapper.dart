import 'package:dio/dio.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/network/api_error.dart';

// Map mã lỗi hồ sơ NCC sang chuỗi hiển thị theo ngôn ngữ app
String mapSitterProfileError(AppLocalizations l10n, Object error) {
  switch (codeFromError(error)) {
    case 'HO_SO_DA_DUYET':
      return l10n.loiHoSoDaDuyet;
    case 'CCCD_DA_DANG_KY':
      return l10n.loiCccdDaDangKy;
    case 'THIEU_ANH_CCCD':
      return l10n.loiThieuAnhCccd;
    case 'CHUA_CO_HO_SO':
      return l10n.loiChuaCoHoSo;
  }
  if (error is DioException) {
    return messageFromError(error) ?? l10n.loiKetNoiMayChu;
  }
  return l10n.loiTaiAnhCccd;
}
