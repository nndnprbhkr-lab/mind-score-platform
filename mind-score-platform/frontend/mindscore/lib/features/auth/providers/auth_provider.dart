// Authentication state management for the MindScore app.
//
// Uses Riverpod's StateNotifier pattern to model the authenticated user session.
// On startup, AuthNotifier attempts to restore a persisted session from
// TokenStorage so the user does not need to log in again after an app restart.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/auth_models.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/token_storage.dart';

// ─── AuthState ────────────────────────────────────────────────────────────────

/// Immutable snapshot of the current authentication state.
///
/// All UI that depends on auth (navigation guards, profile display, feature
/// gating) should watch [authProvider] and read from this state.
class AuthState {
  /// Whether the user is currently authenticated (has a valid token).
  final bool isAuthenticated;

  /// Whether the user has the `admin` role and may access the admin panel.
  final bool isAdmin;

  /// Whether this is a temporary guest session (no email, limited features).
  final bool isGuest;

  /// Whether the server has a date of birth on record for this user.
  ///
  /// The MindScore cognitive assessment requires age-band normalisation, so
  /// users without a DOB are prompted to provide one before starting it.
  final bool hasDob;

  /// Server-assigned UUID for the authenticated user.
  final String? userId;

  /// Display name shown in the app header and profile screen.
  final String? name;

  /// Email address used for login (may be synthetic for guest sessions).
  final String? email;

  /// JWT access token sent in `Authorization: Bearer` headers.
  final String? token;

  /// `true` while an async auth operation (login, register) is in progress.
  final bool isLoading;

  /// Non-null when the last auth operation produced an error.
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.isGuest = false,
    this.hasDob = false,
    this.userId,
    this.name,
    this.email,
    this.token,
    this.isLoading = false,
    this.error,
  });

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// Note: [error] is NOT preserved by default when `null` is passed — pass
  /// `error: null` explicitly to clear a previous error.
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isAdmin,
    bool? isGuest,
    bool? hasDob,
    String? userId,
    String? name,
    String? email,
    String? token,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isAdmin:         isAdmin         ?? this.isAdmin,
      isGuest:         isGuest         ?? this.isGuest,
      hasDob:          hasDob          ?? this.hasDob,
      userId:          userId          ?? this.userId,
      name:            name            ?? this.name,
      email:           email           ?? this.email,
      token:           token           ?? this.token,
      isLoading:       isLoading       ?? this.isLoading,
      error:           error,
    );
  }
}

// ─── AuthNotifier ─────────────────────────────────────────────────────────────

/// Manages authentication state and exposes all auth operations.
///
/// On construction, [_restoreSession] is called to rehydrate state from
/// [TokenStorage], enabling seamless app restarts without re-login.
///
/// All public methods follow the pattern:
///   1. Set `isLoading: true, error: null`.
///   2. Call the API.
///   3. On success: persist credentials, update state.
///   4. On failure: set `error` with a user-friendly message.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _restoreSession();
  }

  /// Attempts to restore a previous session from secure storage.
  ///
  /// If a saved token is found, the state is populated immediately so the
  /// router can redirect to the dashboard without showing the login screen.
  /// This is called once in the constructor and is not part of the public API.
  Future<void> _restoreSession() async {
    final saved = await TokenStorage.load();
    if (saved != null) {
      state = AuthState(
        isAuthenticated: true,
        isAdmin:  saved.isAdmin,
        isGuest:  saved.isGuest,
        hasDob:   saved.hasDob,
        userId:   saved.userId,
        name:     saved.name,
        email:    saved.email,
        token:    saved.token,
      );
    }
  }

  /// Applies a successful [AuthResponse] to state.
  ///
  /// Extracted to avoid duplication across login, register, and guest login.
  void _applyResponse(AuthResponse response) {
    state = AuthState(
      isAuthenticated: true,
      isAdmin:  response.isAdmin,
      isGuest:  response.isGuest,
      hasDob:   response.hasDob,
      userId:   response.userId,
      name:     response.name,
      email:    response.email,
      token:    response.token,
    );
  }

  /// Authenticates an existing user with [email] and [password].
  ///
  /// On success, the JWT token is persisted and the state transitions to
  /// authenticated.  On failure, [AuthState.error] is set with a message.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.login,
        LoginRequest(email: email, password: password).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token:   response.token,
        userId:  response.userId,
        name:    response.name,
        email:   response.email,
        isAdmin: response.isAdmin,
        isGuest: response.isGuest,
        hasDob:  response.hasDob,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  /// Registers a new user account with the given credentials.
  ///
  /// [dateOfBirth] and [domicile] are optional but collecting DOB at
  /// registration enables MindScore access immediately without a follow-up
  /// prompt.
  Future<void> register(
    String name,
    String email,
    String password, {
    DateTime? dateOfBirth,
    String? domicile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.register,
        RegisterRequest(
          name:        name,
          email:       email,
          password:    password,
          dateOfBirth: dateOfBirth,
          domicile:    domicile,
        ).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token:   response.token,
        userId:  response.userId,
        name:    response.name,
        email:   response.email,
        isAdmin: response.isAdmin,
        isGuest: response.isGuest,
        hasDob:  response.hasDob,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  /// Creates a temporary guest session under the given display [name].
  ///
  /// Guests can complete assessments and view results within a session but
  /// cannot access persistent history or reports.  Providing [dateOfBirth]
  /// enables the MindScore assessment immediately.
  Future<void> guestLogin(String name, {DateTime? dateOfBirth}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final json = await ApiClient.post(
        ApiConstants.guestLogin,
        GuestLoginRequest(name: name, dateOfBirth: dateOfBirth).toJson(),
      );
      final response = AuthResponse.fromJson(json);
      await TokenStorage.save(
        token:   response.token,
        userId:  response.userId,
        name:    response.name,
        email:   response.email,
        isAdmin: response.isAdmin,
        isGuest: response.isGuest,
        hasDob:  response.hasDob,
      );
      _applyResponse(response);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Unexpected error. Try again.');
    }
  }

  /// Submits the user's [dateOfBirth] to the server and updates the local
  /// session so [hasDob] becomes `true`.
  ///
  /// This is called when a user (typically a guest or a user who skipped DOB
  /// at registration) attempts to start the MindScore assessment for the
  /// first time.
  Future<void> updateDob(DateTime dateOfBirth) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await ApiClient.patch(
        ApiConstants.userMe,
        {'dateOfBirth': dateOfBirth.toIso8601String()},
        auth: true,
      );
      state = state.copyWith(isLoading: false, hasDob: true);
      await TokenStorage.save(
        token:   state.token!,
        userId:  state.userId!,
        name:    state.name ?? '',
        email:   state.email ?? '',
        isAdmin: state.isAdmin,
        isGuest: state.isGuest,
        hasDob:  true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to save date of birth.');
    }
  }

  /// Clears all stored credentials and resets state to unauthenticated.
  ///
  /// The router's redirect guard detects `isAuthenticated == false` and
  /// navigates to the login screen.
  Future<void> logout() async {
    await TokenStorage.clear();
    state = const AuthState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

/// Global Riverpod provider for [AuthNotifier].
///
/// Any widget that needs to read or react to authentication state should
/// `watch` or `read` this provider:
/// ```dart
/// final auth = ref.watch(authProvider);
/// if (!auth.isAuthenticated) context.go(AppRoutes.login);
/// ```
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (_) => AuthNotifier(),
);
