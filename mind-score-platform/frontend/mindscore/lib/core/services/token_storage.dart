import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey  = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _emailKey  = 'auth_email';

  static Future<void> save({
    required String token,
    required String userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey,  token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_emailKey,  email);
  }

  static Future<({String token, String userId, String email})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final token  = prefs.getString(_tokenKey);
    final userId = prefs.getString(_userIdKey);
    final email  = prefs.getString(_emailKey);
    if (token == null || userId == null || email == null) return null;
    return (token: token, userId: userId, email: email);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
  }
}
