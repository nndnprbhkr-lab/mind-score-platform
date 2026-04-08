import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage    = FlutterSecureStorage();
  static const _tokenKey   = 'auth_token';
  static const _userIdKey  = 'auth_user_id';
  static const _nameKey    = 'auth_name';
  static const _emailKey   = 'auth_email';
  static const _isAdminKey = 'auth_is_admin';
  static const _isGuestKey = 'auth_is_guest';
  static const _hasDobKey  = 'auth_has_dob';

  static Future<void> save({
    required String token,
    required String userId,
    required String name,
    required String email,
    required bool isAdmin,
    required bool isGuest,
    required bool hasDob,
  }) async {
    await _storage.write(key: _tokenKey,   value: token);
    await _storage.write(key: _userIdKey,  value: userId);
    await _storage.write(key: _nameKey,    value: name);
    await _storage.write(key: _emailKey,   value: email);
    await _storage.write(key: _isAdminKey, value: isAdmin.toString());
    await _storage.write(key: _isGuestKey, value: isGuest.toString());
    await _storage.write(key: _hasDobKey,  value: hasDob.toString());
  }

  static Future<({String token, String userId, String name, String email, bool isAdmin, bool isGuest, bool hasDob})?> load() async {
    final token      = await _storage.read(key: _tokenKey);
    final userId     = await _storage.read(key: _userIdKey);
    final name       = await _storage.read(key: _nameKey);
    final email      = await _storage.read(key: _emailKey);
    final isAdminStr = await _storage.read(key: _isAdminKey);
    final isGuestStr = await _storage.read(key: _isGuestKey);
    final hasDobStr  = await _storage.read(key: _hasDobKey);
    if (token == null || userId == null || email == null) return null;
    return (
      token: token,
      userId: userId,
      name: name ?? '',
      email: email,
      isAdmin: isAdminStr == 'true',
      isGuest: isGuestStr == 'true',
      hasDob: hasDobStr == 'true',
    );
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
