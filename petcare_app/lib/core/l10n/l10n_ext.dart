import 'package:flutter/widgets.dart';
import 'package:petcare_app/core/l10n/generated/app_localizations.dart';

// Gọi bản dịch gọn trong widget: context.l10n.tiepTuc
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
