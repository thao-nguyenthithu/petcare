import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/services/push_service.dart';
import 'package:petcare_app/core/storage/locale_storage.dart';

final savedLanguageCodeProvider = Provider<String?>((ref) => null);

final localeStorageProvider = Provider<LocaleStorage>(
  (ref) => const LocaleStorage(),
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final saved = ref.watch(savedLanguageCodeProvider);
    return Locale(saved ?? 'vi');
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await ref.read(localeStorageProvider).saveLanguageCode(languageCode);
    await PushService.instance.doiNgonNgu(languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
