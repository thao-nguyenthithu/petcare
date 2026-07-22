import 'package:petcare_app/core/l10n/generated/app_localizations.dart';

String thoiGianTuongDoi(AppLocalizations l10n, int soPhutTruoc) {
  if (soPhutTruoc < 60) return l10n.truocSoPhut('$soPhutTruoc');
  final soGio = soPhutTruoc ~/ 60;
  if (soGio < 24) return l10n.truocSoGio('$soGio');
  return l10n.truocSoNgay('${soGio ~/ 24}');
}

String thoiGianConLai(AppLocalizations l10n, int soPhutConLai) {
  if (soPhutConLai < 60) return l10n.conXphut(soPhutConLai);
  final soGio = soPhutConLai ~/ 60;
  if (soGio < 24) return l10n.conXgio(soGio);
  return l10n.conXngay(soGio ~/ 24);
}
