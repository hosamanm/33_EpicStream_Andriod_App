import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for storing sensitive data like Auth Tokens or PII.
/// Uses Keystore on Android and Keychain on iOS.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  static const String _tokenKey = 'secure_auth_token';
  static const String _rememberMeEmailKey = 'remember_me_email';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> saveRememberedEmail(String email) async {
    await _storage.write(key: _rememberMeEmailKey, value: email);
  }

  Future<String?> getRememberedEmail() async {
    return await _storage.read(key: _rememberMeEmailKey);
  }

  Future<void> deleteRememberedEmail() async {
    await _storage.delete(key: _rememberMeEmailKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
