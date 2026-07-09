import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocaleStorage {
  static const _keyLanguageCode = 'language_code';

  final FlutterSecureStorage _storage;

  const LocaleStorage([this._storage = const FlutterSecureStorage()]);

  Future<void> saveLanguageCode(String languageCode) =>
      _storage.write(key: _keyLanguageCode, value: languageCode);

  Future<String?> readLanguageCode() => _storage.read(key: _keyLanguageCode);
}
