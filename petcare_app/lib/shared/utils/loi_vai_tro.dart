import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/network/api_error.dart';

String? moTaLoiVaiTro(AppLocalizations l10n, Object error) =>
    switch (codeFromError(error)) {
      'CHUA_LA_NCC' => l10n.loiChuaLaNcc,
      'NCC_CHUA_DUOC_DUYET' => l10n.loiHoSoNccChuaDuyet,
      'TAI_KHOAN_NCC_BI_KHOA' => l10n.loiTaiKhoanNccBiKhoa,
      _ => null,
    };
