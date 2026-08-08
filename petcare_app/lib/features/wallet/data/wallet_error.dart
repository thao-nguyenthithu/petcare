import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/network/api_error.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

String moTaLoiVi(BuildContext context, Object loi, {required int rutToiThieu}) {
  final l10n = context.l10n;
  return switch (codeFromError(loi)) {
    'DUOI_MUC_RUT_TOI_THIEU' => l10n.soTienRutToiThieu(
      dinhDangTien(rutToiThieu),
    ),
    'VUOT_SO_DU' => l10n.soTienVuotSoDu,
    'CHUA_LIEN_KET_NGAN_HANG' => l10n.chuaLienKetTaiKhoan,
    'DA_PHAN_HOI' => l10n.daPhanHoiKhieuNai,
    'QUA_HAN_PHAN_HOI' => l10n.quaHanPhanHoiKhieuNai,
    _ => messageFromError(loi) ?? l10n.khongTaiDuocDuLieu,
  };
}
