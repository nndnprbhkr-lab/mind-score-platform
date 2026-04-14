// Persistent, secure storage for the authenticated user's session data.
//
// Uses flutter_secure_storage to write credentials to the platform keychain
// (iOS Keychain / Android Keystore) so they survive app restarts.
//
// All writes and reads are performed individually per key rather than as a
// single blob, which makes partial updates (e.g. only refreshing hasDob)
// efficient and avoids overwriting unrelated fields.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Provides static helpers for reading and writing the current user's session
/// to the platform's secure credential store.
///
/// The stored fields mirror [AuthState]:
///   - [_tokenKey]   — JWT access token for authenticated API calls.
///   - [_userIdKey]  — UUID of the authenticated user.
///   - [_nameKey]    — Display name shown in the UI.
///   - [_emailKey]   — Email address (may be synthetic for guest sessions).
///   - [_isAdminKey] — Whether the user has the admin role.
///   - [_isGuestKey] — Whether this is a temporary guest session.
///   - [_hasDobKey]  — Whether a date of birth has been recorded (gates
///                     the MindScore cognitive assessment).
class TokenStorage {
  // Non-instantiable — all members are static.
  TokenStorage._();

  static const _storage    = FlutterSecureStorage();
  static const _tokenKey   = 'auth_token';
  static const _userIdKey  = 'auth_user_id';
  static const _nameKey    = 'auth_name';
  static const _emailKey   = 'auth_email';
  static const _isAdminKey = 'auth_is_admin';
  static const _isGuestKey = 'auth_is_guest';
  static const _hasDobKey  = 'auth_has_dob';

  /// Persists all session fields to the secure store.
  ///
  /// Called after every successful authentication (login, register, guest
  /// login) and whenever [hasDob] changes after a DOB update.
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

  /// Reads all session fields from the secure store.
  ///
  /// Returns `null` if no valid session exists (i.e. [_tokenKey] or
  /// [_userIdKey] or [_emailKey] is absent), which is the unauthenticated state.
  ///
  /// Boolean fields default to `false` if their stored string is absent.
  static Future<({
    String token,
    String userId,
    String name,
    String email,
    bool isAdmin,
    bool isGuest,
    bool hasDob,
  })?> load() async {
    final token      = await _storage.read(key: _tokenKey);
    final userId     = await _storage.read(key: _userIdKey);
    final name       = await _storage.read(key: _nameKey);
    final email      = await _storage.read(key: _emailKey);
    final isAdminStr = await _storage.read(key: _isAdminKey);
    final isGuestStr = await _storage.read(key: _isGuestKey);
    final hasDobStr  = await _storage.read(key: _hasDobKey);

    if (token == null || userId == null || email == null) return null;

    return (
      token:   token,
      userId:  userId,
      name:    name ?? '',
      email:   email,
      isAdmin: isAdminStr == 'true',
      isGuest: isGuestStr == 'true',
      hasDob:  hasDobStr == 'true',
    );
  }

  /// Deletes all stored session fields.
  ///
  /// Called on logout — results in [load] returning `null` and the router
  /// redirecting to the login screen.
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
