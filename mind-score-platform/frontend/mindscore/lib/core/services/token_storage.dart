import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage   = FlutterSecureStorage();
  static const _tokenKey  = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey  = 'auth_email';
  static const _isAdminKey = 'auth_is_admin';

  static Future<void> save({
    required String token,
    required String userId,
    required String email,
    required bool isAdmin,
  }) async {
    await _storage.write(key: _tokenKey,   value: token);
    await _storage.write(key: _userIdKey,  value: userId);
    await _storage.write(key: _emailKey,   value: email);
    await _storage.write(key: _isAdminKey, value: isAdmin.toString());
  }

  static Future<({String token, String userId, String email, bool isAdmin})?> load() async {
    final token   = await _storage.read(key: _tokenKey);
    final userId  = await _storage.read(key: _userIdKey);
    final email   = await _storage.read(key: _emailKey);
    final isAdminStr = await _storage.read(key: _isAdminKey);
    if (token == null || userId == null || email == null) return null;
    return (token: token, userId: userId, email: email, isAdmin: isAdminStr == 'true');
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
