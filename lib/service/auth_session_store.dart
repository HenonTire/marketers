import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStore {
  AuthSessionStore._();

  static const _accessTokenKey = 'marketers_access_token';
  static const _refreshCookieKey = 'marketers_refresh_cookie';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static String? _accessToken;
  static String? _refreshCookie;
  static bool _restored = false;

  static String? get accessToken => _accessToken;
  static String? get refreshCookie => _refreshCookie;
  static bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  static Future<void> restore() async {
    if (_restored) return;
    _accessToken = await _storage.read(key: _accessTokenKey);
    _refreshCookie = await _storage.read(key: _refreshCookieKey);
    _restored = true;
  }

  static Future<void> saveAccessToken(String token) async {
    _accessToken = token;
    _restored = true;
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Stores only the `refresh_token=name` pair, never the Set-Cookie attributes.
  static Future<void> saveRefreshCookieHeader(String? setCookie) async {
    if (setCookie == null || setCookie.isEmpty) return;
    final refreshCookie = setCookie
        .split(RegExp(r',(?=\s*[^;=]+=)'))
        .map((value) => value.split(';').first.trim())
        .firstWhere((value) => value.startsWith('refresh_token='), orElse: () => '');
    if (refreshCookie.isEmpty) return;
    _refreshCookie = refreshCookie;
    _restored = true;
    await _storage.write(key: _refreshCookieKey, value: refreshCookie);
  }

  static Future<void> clear() async {
    _accessToken = null;
    _refreshCookie = null;
    _restored = true;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshCookieKey);
  }
}
