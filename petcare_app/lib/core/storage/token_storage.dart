import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _accessTokenKey = 'access_token';
  static String? _accessTokenRam;
  static bool _daDocAccessToken = false;

  Future<void> saveAccessToken(String accessToken) {
    _datAccessTokenRam(accessToken);
    return _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() async {
    if (_daDocAccessToken) return _accessTokenRam;
    _datAccessTokenRam(await _storage.read(key: _accessTokenKey));
    return _accessTokenRam;
  }

  Future<void> clearTokens() async {
    _datAccessTokenRam(null);
    await _storage.delete(key: _accessTokenKey);
  }

  static void _datAccessTokenRam(String? token) {
    _accessTokenRam = token;
    _daDocAccessToken = true;
  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
